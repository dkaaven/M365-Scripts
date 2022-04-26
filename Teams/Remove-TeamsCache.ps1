# Inspired by: https://lazyadmin.nl/powershell/microsoft-teams-uninstall-reinstall-and-cleanup-guide-scripts/#:~:text=Press%20Windows%20key%20%2B%20R.%20Type%20%25appdata%25%20and,script%20below%20to%20remove%20the%20Microsoft%20Teams%20Cache.

function Clear-TeamsCache {
    param (
        [alias("Force")]
        [Parameter(Position=0)]
        [switch]$ForceSkip = $false
    )

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

        $folders = @("blob_storage", "databases", "cache", "gpucache", "Indexeddb", "Local Storage", "tmp")
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