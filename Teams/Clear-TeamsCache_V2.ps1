<#
.SYNOPSIS
    Clear teams cache files
.DESCRIPTION
    Close Teams, Backup relevant files and folders, Delete Cache and restart Teams again.
    This script let you choose files and folders in line 33 and 35.

    !Note -Force parameter will also delete backup-folder.

    This script will keep custom Backgrounds and settings such as Dark Mode and 
.PARAMETER -Force
    Don't promt and runs the script and removes the backup-folder after.
.EXAMPLE
    . .\Clear-TeamsCache_V2.ps1
    Clear-TeamsCache
    Clear_TeamsCache -Force
.NOTES
    FileName:    Clear-TeamsCache.ps1
    Author:      Daniel Kåven
    Contact:     @DKaaven
    Created:     2022-03-30
    Updated:     2022-03-30
    Version history:
    1.0.0 - (2022-03-30) Script created
    2.0.0 - (2023-03-13) Redesigned script to delete all but the chosen list
#>

function Clear-TeamsCache {
    param (
        [alias("Force")]
        [Parameter(Position=0)]
        [switch]$ForceSkip = $false
    )

    # List of folders to keep
    $folders = @("Backgrounds", "logs")
    # List of files to keep
    $files = @("desktop-config.json", "Preferences", "settings.json")
    # Get current Date-Time
    $timestamp = Get-Date -Format "yyyy-MM-dd_HHmmss"
    $TeamsFolder = $env:APPDATA + "\Microsoft\teams\"

    # Create a Force function to hide promt
    if ($ForceSkip -eq $true) {
        $ClearCache = "Y"
    }
    else {
        $ClearCache = Read-Host "Do you want to delete the Teams Cache (Y/N)?"
        $ClearCache = $ClearCache.ToUpper()    
    }

    if ($ClearCache -eq "Y"){
        Write-Host "Stopping Teams Process" -ForegroundColor Yellow
        try{
            Get-Process -ProcessName Teams | Stop-Process -Force
            Start-Sleep -Seconds 3
            Write-Host "Teams Process Sucessfully Stopped" -ForegroundColor Green
        }
        catch [System.Exception] {
        Write-Error $_.Exception.Message
        
        }
        
        #Create Backup Folder
        $BackupFolder = "TeamsBackup_" + $timestamp
        Write-Host "Creating a backup" -ForegroundColor Yellow
        New-Item -Path ".\$Backupfolder" -ItemType Directory | Out-Null
        
        $count = 0
        $percentTotal = $folders.Count + $files.Count
        
        foreach ($folder in $folders){
            $count += 1
            $percent = ($count / $percentTotal) * 100
            try {
                $path = $TeamsFolder + $folder
                if (Test-Path $path) {
                    Copy-Item -Path $path -Confirm:$false -Destination $BackupFolder
                    Write-Progress "Copied $folder" -PercentComplete $percent
                    Start-Sleep -s 0.5
                }
            }
            catch [System.Exception] {
                Write-Error $_.Exception.Message
            }
        }
        foreach ($file in $files){
            $count += 1
            $percent = ($count / $percentTotal) * 100
            try {
                $path = $TeamsFolder + $file
                if (Test-Path $path) {
                    Copy-Item -Path $path -Confirm:$false -Destination $BackupFolder
                    Write-Progress "Copied $file" -PercentComplete $percent
                    Start-Sleep -s 0.5
                }
            }
            catch [System.Exception] {
                Write-Error $_.Exception.Message
            }
        }
        
        Write-Host "Restoring Files..." -ForegroundColor Blue
        #Delete All Cache Files
        Get-ChildItem -Path $TeamsFolder | Remove-Item -Confirm:$false -Recurse
        #Restore Backup
        Get-ChildItem -Path $BackupFolder | Copy-Item -Confirm:$false -Destination $TeamsFolder
        
        Write-Host "Cleanup Complete, launching Teams." -ForegroundColor Green
        Start-Process -File "$($env:USERProfile)\AppData\Local\Microsoft\Teams\Update.exe" -ArgumentList '--processStart "Teams.exe"'

        #Check to delete Backup-Folder
        $DeleteBackup = Read-Host "Do you want to delete the backup-folder (Y/N)"
        $DeleteBackup = $DeleteBackup.ToUpper()    
        if ($DeleteBackup -eq "Y"){
            Remove-Item $BackupFolder -Confirm:$false -Recurse
        }
        if ($ForceSkip -eq "Y"){
            Remove-Item $BackupFolder -Confirm:$false -Recurse
        }
    }
    else {
        Write-Host "Skipping Cache Cleanup" -ForegroundColor Blue
    }
}

Clear-TeamsCache