<#
.SYNOPSIS
    Check what Powershell Version you are using
.DESCRIPTION
    This script checks your Powershell Version and returns true or false.    

.PARAMETER version "Core or Desktop"
    - Desktop is up to version 5
    - Core is version 6 and up

.EXAMPLE
    Check if you are using Core
    Get-PSVersion Core

    Check if you are using Desktop
    Get-PSVersion Desktop

.NOTES
    FileName:    Get-PSversion.psm1
    Author:      Daniel Kåven
    Contact:     @DKaaven
    Created:     2022-03-25
    Updated:     2022-03-25
    Version history:
    1.0.0 - (2022-03-25) Script created
#>

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