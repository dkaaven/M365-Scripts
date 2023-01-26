<#
.SYNOPSIS
    Clear teams cache files
.DESCRIPTION
    Close Teams, Delete Cache and restart Teams again

.PARAMETER tenant
    Clear-TeamsCache -Force

.EXAMPLE
    . .\Clear-TeamsCache.ps1
.NOTES
    FileName:    Clear-TeamsCache.ps1
    Author:      Daniel Kåven
    Contact:     @DKaaven
    Created:     2022-03-30
    Updated:     2022-03-30
    Version history:
    1.0.0 - (2022-03-30) Script created
#>

function Clear-TeamsCache {
    param (
        [alias("Force")]
        [Parameter(Position=0)]
        [switch]$ForceSkip = $false
    )

    # List of folders to delete
    $folders = @("blob_storage", "databases", "cache", "gpucache", "Indexeddb", "Local Storage", "tmp")

    # Create a Force function to hide promt
    if ($ForceSkip -eq $true) {
        $ClearCache = "Y"
    }
    else {
        $clearCache = Read-Host "Do you want to delete the Teams Cache (Y/N)?"
        $clearCache = $clearCache.ToUpper()    
    }

    if ($clearCache -eq "Y"){
        Write-Host "Stopping Teams Process" -ForegroundColor Yellow

        try{
            Get-Process -ProcessName Teams | Stop-Process -Force
            Start-Sleep -Seconds 3
            Write-Host "Teams Process Sucessfully Stopped" -ForegroundColor Green
        }
        catch [System.Exception] {
            Write-Error $_.Exception.Message
        }
        

        Write-Host "Clearing Teams Disk Cache" -ForegroundColor Yellow

        $count = 0
        $percentTotal = $folders.Count

        foreach ($folder in $folders){
            $count += 1
            $percent = ($count / $percentTotal) * 100
            try {
                $path = $env:APPDATA + "\Microsoft\teams\" + $folder
                if (Test-Path $path) {
                    Get-ChildItem -Path $path | Remove-Item -Confirm:$false -Recurse
                    Write-Progress "Deleted $folder" -PercentComplete $percent
                    Start-Sleep -s 1
                }
            }
            catch [System.Exception] {
                Write-Error $_.Exception.Message
            }
        }
        Write-Host "Cleanup Complete... Launching Teams" -ForegroundColor Green
        Start-Process -File "$($env:USERProfile)\AppData\Local\Microsoft\Teams\Update.exe" -ArgumentList '--processStart "Teams.exe"'
    }
    else {
        Write-Host "Skipping Cache Cleanup" -ForegroundColor Blue
    }
}

Clear-TeamsCache