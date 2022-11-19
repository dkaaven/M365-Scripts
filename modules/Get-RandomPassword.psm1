<#
.SYNOPSIS
    Generate a password to use.
.DESCRIPTION
    This is a useful for many functions, such as azure apps.
.PARAMETER Length
    Define length of the password, 8-256 characters. Default is 64.

.PARAMETER OnlyAlphaNumeric
    If set to $true, only alphanumeric characters are allowed. Default is $false.

.PARAMETER SQLCompliant
    If set to $true, the password will be returned in SQL compliant format. Default is $false.

.EXAMPLE
    Get-RandomPassword - Length: 8
.NOTES
    FileName:    Get-RandomPassword.ps1
    Author:      Daniel Kåven
    Contact:     @DKaaven
    Created:     2022-04-30
    Updated:     2022-04-30
    Version history:
    1.0.0 - (2022-04-30) Script created
#>

function Get-RandomPassword {
    param (
        [Parameter(Position=0)]
        [ValidateRange(8, 256)]
        [int] $Length = 64,
        [Parameter]
        [switch]$OnlyAlphaNumeric,
        [Parameter]
        [switch]$SQLCompliant
    )

    # Ascii characters to use
    $Characters = [char]65..[char]90 # A..Z
    $Characters += [char]97..[char]122 # a..z
    $Characters += [char]48..[char]57 # 0..9
    # Adding characters if needed
    if ($SQLCompliant.isPresent) {
        if ($OnlyAlphaNumeric.isPresent) {
            $Characters += [char]33..[char]47 # !"#$%&'()*+,-./
        }
    }

    $Password = @()
    For ($i = 0; $i -lt $Length; $i++) {
    $Password += $Characters | Get-Random
    }
    return -join $Password
    
}

