function Clear-TeamsCache {
    <#
.SYNOPSIS
    Clear Microsoft Teams cache files
.DESCRIPTION
    Closes Micrsoft Teams, Deletes Cache Files and restart Teams again.

    Note: This script is delivered as is with no warranty.
    The script is tested, but use is still at your own risk.
    
.PARAMETER ListFolders
    (Optional) Lists all folders in the cache directory, but will not restart teams or delete anything.

.PARAMETER Hard
    (Optional) Deletes all Microsoft Teams related settings files. (Default = False)
    This option enables -DeleteFolders and -IgnoreFolders.

.PARAMETER Force
    (Optional) Ignore the "confirm to delete" prompt. (Default = False)

.PARAMETER DeleteFolders
    (Optional) Requires -Hard. List of folders to delete, this will only delete folders in the list.

.PARAMETER IgnoreFolders
    (Optional) Requires -Hard. List of folders to ignore, all other folders will be deleted.

.PARAMETER Wait
    (Optional) Increase the wait time from closing teams to deleting files. (Default = 5)
    Increase this for slow systems or if you get an error that the script can't delete files.

.EXAMPLE
    Clear-TeamsCache -ListFolders
    Clear-TeamsCache -Force
    Clear-TeamsCache -Wait 10
    Clear-TeamsCache -Hard -DeleteFolders AC, LocalCache
    Clear-TeamsCache -Hard -IgnoreFolders Settings, SystemAppData
    Clear-TeamsCache -Hard -IgnoreFolders Settings -Force -Wait 10
    
.NOTES
    FileName:    Clear-TeamsCache.ps1
    Author:      Daniel Kåven
    Contact:     @DKaaven
    Created:     2022-03-30
    Updated:     2024-07-25
    Version history:
    1.0.0 - (2022-03-30) Script created
    2.0.0 - (2024-07-25) Updated for New teams and added functionality
#>

    param (
        [alias("Hard")]
        [switch]$hardReset = $false,

        [alias("ListFolders")]
        [switch]$folderList = $false,

        [alias("DeleteFolders")]
        [string[]]$deleteFoldersList = @(),

        [alias("IgnoreFolders")]
        [string[]]$ignoreFoldersList = @(),

        [alias("Force")]
        [switch]$forceSkip = $false,

        [alias("Wait")]
        [int]$waiting = 5
    )
    # Return a list of folders
    if ($folderList -eq $true) {
        Write-Output "Here are the list of folders in your Root Teams Cache directory, used with Clear-TeamsCache -Hard:"
        Write-Output "___________________________________________________________"
        $deleteFoldersList = Get-ChildItem -Directory "$env:LOCALAPPDATA\Packages\MSTeams_8wekyb3d8bbwe\" | Where-Object { $_.PSIsContainer } | Foreach-Object { $_.Name }
        return $deleteFoldersList
    }
    else {
        if ($hardReset -eq $true) {
            # List of folders to delete, if none is specified, add all to list
            if ($deleteFoldersList.count -eq 0) {
                Write-Host "Finding folders to delete" -ForegroundColor Yellow
                Start-Sleep -Seconds 1
                $deleteFoldersList = Get-ChildItem -Directory "$env:LOCALAPPDATA\Packages\MSTeams_8wekyb3d8bbwe\" | Where-Object { $_.PSIsContainer } | Foreach-Object { $_.Name }
            }
    
            if ($ignoreFoldersList.count -gt 0) {
                foreach ($folder in $deleteFoldersList) {
                    if ($ignoreFoldersList -contains $folder) {
                        $deleteFoldersList = $deleteFoldersList | ? { $_ -ne $folder }
                    }
                }
            }
        
            $deleteCount = $deleteFoldersList.count
            Write-Host "$deleteCount folders will be deleted." -ForegroundColor Blue
        }

        # Create a Force function to hide promt
        if ($forceSkip -eq $true) {
            $clearCache = "Y"
        }
        else {
            $clearCache = Read-Host "Do you want to delete the Teams Cache (Y/N)?"
            $clearCache = $clearCache.ToUpper()    
        }

        # Close Microsoft Teams
        if ($clearCache -eq "Y") {
            Write-Host "Stopping Teams Process" -ForegroundColor Yellow

            try {
                Get-Process -ProcessName ms-teams -ErrorAction SilentlyContinue | Stop-Process -Force
                Start-Sleep -Seconds $waiting
                Write-Host "Teams Process Sucessfully Stopped" -ForegroundColor Green
            }
            catch [System.Exception] {
                Write-Error $_.Exception.Message
            }
            
            # Clear cache (soft delete)
            if ($hardReset -eq $false) {
                Write-Host "Clearing Teams Cache" -ForegroundColor Yellow
                try {
                    $path = $env:LOCALAPPDATA + "\Packages\MSTeams_8wekyb3d8bbwe\LocalCache\Microsoft\MSTeams"
                    if (Test-Path $path) {
                        Get-ChildItem -Path $path | Remove-Item -Confirm:$false -Recurse -Force
                    }
                }
                catch [System.Exception] {
                    Write-Error $_.Exception.Message
                }
                Write-Host "Cleanup Complete... Launching Teams" -ForegroundColor Green
                Start-Process ms-teams            
            }
            elseif ($hardReset -eq $true) {
                Write-Host "Clearing Teams Cache" -ForegroundColor Yellow
            
                $count = 0
                $percentTotal = $deleteFoldersList.Count
            
                foreach ($folder in $deleteFoldersList) {
                    $count += 1
                    $percent = ($count / $percentTotal) * 100
                    try {
                        $path = $env:LOCALAPPDATA + "\Packages\MSTeams_8wekyb3d8bbwe\" + $folder
                        if ((Test-Path $path) -and ($folder -notin $ignoreFoldersList)) {
                            Get-Item -Path $path | Remove-Item -Confirm:$false -Recurse -Force
                            Write-Progress "Deleted $folder" -PercentComplete $percent
                            Start-Sleep -Seconds 1
                        }
                    }
                    catch [System.Exception] {
                        Write-Error $_.Exception.Message
                    }
                }
                Write-Host "Cleanup Complete... Launching Teams" -ForegroundColor Green
                Start-Process ms-teams
            }
        }
        else {
            Write-Host "Skipping Cache Cleanup" -ForegroundColor Blue
        }
    }
}
