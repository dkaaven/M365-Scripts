<#
.SYNOPSIS
    Connect to any customers domain as a partner.
.DESCRIPTION
    This script is a collection of login functions that can be used to connect to any customers domain as a partner.
    
.PARAMETER service
    Toggle through the services you can connect to.

.PARAMETER domain
    What domain to connect to.

.EXAMPLE
    Connect-Service MicrosoftTeams mydomain.com

.NOTES
    FileName:    Connect-Service.ps1
    Author:      Daniel Kåven
    Contact:     @DKaaven
    Created:     2022-03-25
    Updated:     2022-03-25
    Version history:
    1.0.0 - (2022-03-25) Script created
#>

# Inspired by: https://seanmcavinue.net/2020/11/19/using-delegated-access-permissions-in-powershell-to-manage-all-microsoft-365-services/

function Get-TenantId {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true, Position=0, HelpMessage="The domain name of the tenant")]
        [String]$domain
    )
    $request = Invoke-WebRequest -Uri https://login.windows.net/$domain/.well-known/openid-configuration
    $data = ConvertFrom-Json $request.Content
    return $Data.token_endpoint.split('/')[3]
}

function Install-Requirements {
    param (
        [parameter(Mandatory = $true, ValueFromRemainingArguments, HelpMessage = "Modules required")]
        [ValidateNotNullOrEmpty()]
        [psobject[]]$Modules
    )

    # Install required modules for script execution
    foreach ($Module in $Modules) {
        try {
            $CurrentModule = Get-InstalledModule -Name $Module -ErrorAction Stop | Out-Null
            if (!$CurrentModule) {
                $LatestModuleVersion = (Find-Module -Name $Module -ErrorAction Stop).Version
                if ($LatestModuleVersion -gt $CurrentModule.Version) {
                    Update-Module -Name $Module -Force -ErrorAction Stop -Confirm:$false
                }
            }
        }
        catch [System.Exception] {
            try {
                # Install NuGet package provider
                Install-PackageProvider -Name NuGet -Force -ErrorAction SilentlyContinue
        
                # Install current missing module
                Install-Module -Name $Module -Scope CurrentUser -Force -ErrorAction Stop -Confirm:$false
            }
            catch [System.Exception] {
                Write-Warning -Message "An error occurred while attempting to install $Module module."
                Write-Error -Message "Error message: $($_.Exception.Message)" -Category NotInstalled
            }
        }
        Import-Module -Name $Module
    }
}
function Get-PSversion {
    [CmdletBinding()]    

    Param(
        [Parameter(Mandatory=$true, Position=0)]
        [ValidateSet("Core","Desktop")]
        [string]$version
    )

    if ($PSEdition -ne $version) {
        return $false
    }
    else {
        return $true
    }
 
}

function Connect-Service {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true, Position=0, HelpMessage="The command to execute")]
        [validateset("MicrosoftTeams", "MSOnline", "Exchange","Security", "AzureAD")]
        [String]$service,
        [Parameter(Mandatory=$true, Position=1, HelpMessage="Customers Domain")]
        [String]$domain
        )

    # Get customers TenantId
    $TenantId = Get-TenantId -domain $domain
    #endregion        

    #region - List of services and connectscripts

    $services = @()
    while (!$service) {
        Write-Host "Choose one of the following services:" -ForegroundColor Green
        foreach ($service in $services) {
            Write-Output "* $service"
        }
        while ($service -ne $services) {
        $service = Read-Host "Service: "
        }
    }
    switch ($service){
        "MicrosofTeams" {
            Install-Requirements("MicrosoftTeams")
            try {
                Write-Host "Connecting to Microsoft Teams..." -foregroundcolor Yellow
                Connect-MicrosoftTeams -tenantId $TenantId
                Write-Host "Connected to Microsoft Teams" -ForegroundColor Green
                Write-Output ""
                Write-Output "Commands: https://docs.microsoft.com/en-us/powershell/module/teams/"
                $disconnect = "Disconnect-MicrosoftTeams"
            }
            catch [System.Exception] {
                Write-Host $_.Exception.Message
                exit 1
            }

        }
        "MSOnline" {
            Install-Requirements("MSOnline")
            Try {
                Connect-MsolService
                Write-Host "Connected to MSOnline" -ForegroundColor Green
                Write-Output "To use this service, you need to add this to the end of the command:"
                Write-Output "-TenantId $TenantId"
                Write-Output ""
                Write-Output "Commands: https://docs.microsoft.com/en-us/powershell/module/msonline/"
                $disconnect = "Disconnect-MsolService"
            }
            catch [System.Exception] {
                Write-Host $_.Exception.Message
                exit 1
            }
        }
        "Exchange" {
            $PSVersion = Get-PSversion -version "Desktop"
            if ($PSVersion -eq $false) {
                Write-Warning "Exchange is not supported on PowerShell Core"
                powershell
            }
            Install-Requirements("ExchangeOnlineManagement")
            try {
                Connect-ExchangeOnline -DelegatedOrganization $domain
                Write-Host "Connected to Exchange" -ForegroundColor Green
                $disconnect = "Disconnect-ExchangeOnline"
            }
            catch [System.Exception] {
                Write-Host $_.Exception.Message
                Start-Sleep -s 15
                exit 1
            }
        }
        "AzureAD" {
            $PSVersion = Get-PSversion -version "Desktop"
            if ($PSVersion -eq $false) {
                Write-Warning "AzureAD is not supported on PowerShell Core"
                powershell                
            }
            Install-Requirements("AzureADPreview")
            try {
                Connect-AzureAD -TenantId $TenantId
                Write-Host "Connected to AzureAD" -ForegroundColor Green
                Write-Output ""
                Write-Output "Commands: https://docs.microsoft.com/en-us/powershell/module/azuread"
                $disconnect = "Disconnect-AzureAD"
            }
            catch [System.Exception] {
                Write-Host $_.Exception.Message
                exit 1
            }
        }
        "Security" {
            Install-Requirements("ExchangeOnlineManangement")
            try {
                Connect-IPPSSession -DelegatedOrganization $domain
                Write-Host "Connected to Security & Compliance" -ForegroundColor Green
                $disconnect = "Disconnect-ExchangeOnline"
            }
            catch [System.Exception] {
                Write-Host $_.Exception.Message
                exit 1
            }
        }
    }
    #endregion

    Write-Host "Remember to disconnected from the service" -ForegroundColor Green
    Write-Output ""
    Write-Output $disconnect
    Write-Output ""

}
