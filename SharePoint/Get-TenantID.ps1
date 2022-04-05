<#
.SYNOPSIS
    Get tenant ID from domain
.DESCRIPTION
    A function to extract tenant ID from domain
.PARAMETER domain
    The domain name
.EXAMPLE
    . .\Get-TenantID.ps1
    Get-TenantID contoso.com
.NOTES
    FileName:    Get-TenantID.ps1
    Author:      Daniel Kåven
    Contact:     @DKaaven
    Created:     2022-04-05
    Updated:     2022-04-05
    Version history:
    1.0.0 - (2022-04-05) Script created
#>
function Get-TenantID {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true, Position=0, HelpMessage="The domain name of the tenant")]
        [String]$domain
    )
    $request = Invoke-WebRequest -Uri https://login.windows.net/$domain/.well-known/openid-configuration
    $data = ConvertFrom-Json $request.Content
    return $Data.token_endpoint.split('/')[3]
}