<#
.SYNOPSIS
    Generate a random password 8-256 characters, optional AlphaNumeric or SQLCompliant.
.DESCRIPTION
    This is a useful for many functions, such as azure apps.
.PARAMETER Length
    Define length of the password, 8-256 characters. Default is 64.

.PARAMETER Compliancy
    Choose if AlphaNumeric or SQLCompliant

.EXAMPLE
    Get-RandomPassword 32
    Get-RandomPassword 64 Alphanumeric
    Get-RandomPassword 128 SQLCompliant

.NOTES
    FileName:    Get-RandomPassword.ps1
    Author:      Daniel Kåven
    Contact:     @DKaaven
    Created:     2022-04-30
    Updated:     2022-04-30
    Version history:
    1.0.0 - (2022-04-30) Script created
    1.1.0 - (2023-02-07) Fixed AlphaNumeric and SQLCompliant
#>

function Get-RandomPassword {
    param (
        [CmdletBinding(PositionalBinding=$false)]
        [Parameter(Position=0)]
        [ValidateRange(8, 256)]
        [int] $Length = 64,
        [Parameter(Position=1)]
        [validateset("AlphaNumeric", "SQLCompliant")]
        [string]$Compliancy
    )

    Switch ($Compliancy){
        "AlphaNumeric" {
            $Characters = [char]65..[char]90 # A..Z
            $Characters += [char]97..[char]122 # a..z
            $Characters += [char]48..[char]57 # 0..9
        }
        "SQLCompliant" {
            $Characters = [char]65..[char]90 # A..Z
            $Characters += [char]97..[char]122 # a..z
            $Characters += [char]48..[char]57 # 0..9
            $Characters += [char]33 #!
            $Characters += [char]35..[char]37 # #$%    
        }
        default {
            $Characters = [char]65..[char]90 # A..Z
            $Characters += [char]97..[char]122 # a..z
            $Characters += [char]48..[char]57 # 0..9
            $Characters += [char]33..[char]47 # !"#&%'()*+,-./
        }
    }
       
    $Password = @()
    For ($i = 0; $i -lt $Length; $i++) {
    $Password += $Characters | Get-Random
    }
    return -join $Password
    
}

