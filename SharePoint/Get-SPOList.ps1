<#
.SYNOPSIS
    Export a information from a sharepoint list
.DESCRIPTION
    Need a Global admin account to run this script.
    Account need to have the permission to read the list.
    In addition the script need to approved as an app.

.PARAMETER ListUrl
    Your Sharepoint list (https://[tenant].sharepoint.com/sites/[sitename]]/Lists/[listname]]/AllItems.aspx)

.EXAMPLE
    . .\Get-SPOList.ps1
.NOTES
    Source:      https://github.com/pnp/powershell
    Commandlets: https://pnp.github.io/powershell/cmdlets/Add-PnPAlert.html
    Manual:      https://pnp.github.io/powershell/articles/authentication.html
    FileName:    Get-SPOList.ps1
    Author:      Daniel Kåven
    Contact:     @DKaaven
    Created:     2022-04-01
    Updated:     2022-04-01
    Version history:
    0.5.0 - (2022-04-01) Script created -> Dosn't work properly yet
#>

function Get-SPOList {
    [CmdletBinding()]    

    Param(
        [Parameter(Mandatory=$true, Position=0)]
        [validateNotNullOrEmpty()]
        [string]$ListUrl
        )

    Begin {
        # Importing the necessary modules
        try {
            Import-Module PnP.PowerShell
        }
        catch {
            Write-Error "Please install the `"PnP.PowerShell`" module" -Category InvalidOperation
            exit 1
        }
        # Get variables from url
        $objurl = [system.uri]$ListUrl
        $domain = $objurl.Authority
        $url = "https://$domain"
        $site = $ListUrl
        $site -replace '/[^/]+$'
        $site -replace '/[^/]+$'
        Write-Output "$site"
        # $tenant = $domain.Split(".") |Select-Object -First 1
        $listname = $ListUrl.split("/") | Select-Object -Last 2 | Select-Object -First 1
        # $listname = $listname.Replace("%20", " ")


        # Connecting to the tenant
    try {
            Write-Output "Connecting to $domain"
            Connect-PnPOnline -Url $site -Interactive
        }
        catch [System.Exception] {
            Write-Error $_.Exception.Message
            Throw "Could not connect to $domain"
        }
    }
    Process {
        Write-Output "Site: $($site)"
        Write-Output "Getting list `"$($listname)`"..."
        Get-PnPList | Where-Object {$_.Hidden -eq $false}
        Get-PnPListItem -List $listname
    }
    End {
        # Write-Output "Disconnecting from $($tenant)..."
        # Disconnect-PnPOnline
    }
}

Get-SPOList -ListUrl https://renroros.sharepoint.com/sites/RRMicrosoft365/Lists/Dagens%20Tips/AllItems.aspx?env=WebViewListx