<#
.SYNOPSIS
    Get all users and members from all sharepoint sites in a tenant
.DESCRIPTION
    Need a Global admin account to run this script.
    It's limited to the account that owns the sites you want to access.
    TODO: Can you solve access or check access?
.PARAMETER tenant
    Your tenant name ([tenantname].onmicrosoft.com)

.EXAMPLE
    . .\Get-SPOSiteUsers.ps1
.NOTES
    FileName:    Get-SPOSiteUsers.ps1
    Author:      Daniel Kåven
    Contact:     @DKaaven
    Created:     2022-03-30
    Updated:     2022-03-30
    Version history:
    1.0.0 - (2022-03-30) Script created -> Dosn't work properly yet
#>

function Get-SPOSiteUsers {
    [CmdletBinding()]    

    Param(
        [Parameter(Mandatory=$false, Position=0)]
        [validateNotNullOrEmpty()]
        [string]$tenant
    )

    Begin {
        # Check if Powershell 5 is used
        if ($PSEdition -eq "Core") {
            Write-Error "This script requires Powershell 5. Please run 'powershell' and run script again" -Category InvalidOperation
            Exit 1
        }

        # Importing the necessary modules
        try {
            Import-Module Microsoft.Online.SharePoint.PowerShell -DisableNameChecking -ErrorAction Stop
        }
        catch {
            Write-Error "Please install the Microsoft.Online.SharePoint.PowerShell module" -Category InvalidOperation
            exit 1
        }

        # Setting the variables if missing
        if (!$tenant) {
            $tenant = Read-Host "What is your tenant name?"
        }
        $AdminURL = "https://$tenant-admin.sharepoint.com/"

        # Connecting to the tenant
        try {
            Write-Output "Connecting to $($AdminURL)..."
            # Connect-SPOService -Url $AdminUrl
        }
        catch [System.Exception] {
            Write-Error $_.Exception.Message
            Throw "Could not connect to $tenant-admin.sharepoint.com"
        }
    }
    Process {
        # Create Export Directory
        $ExportDir = "~\SPOExport\"
        if (!(Test-Path $ExportDir)) {
            New-Item -Path $ExportDir -ItemType Directory
        }

        # Getting all the site urls
        $SPOSites = Get-SPOSite -Limit ALL
        Write-Output "Found $($SPOSites.Count) sites"

        # Itterate through all the sites 
        foreach ($site in $SPOSites) {
            # Remove special characters from the site title
            $pattern = '_*(\[.*?\]|\(.*?\))_*'
            $siteTitle = $site.Title
            $siteTitle = $siteTitle -replace $pattern, ""
            $Filename = $siteTitle + ".csv"
            $ExportFile = $ExportDir + $Filename
            Get-SPOUser -Site $site.Url -Limit ALL | Select-Object DisplayName, LoginName, UserType, IsSiteAdmin  | Export-CSV $ExportFile -NoTypeInformation -Encoding UTF8
        }
    }
    End {
        Write-Output "Disconnecting from $($AdminURL)..."
        Disconnect-SPOService

        Write-Output "Files saved in $($ExportDir)"
    }
}
Get-SPOSiteUsers