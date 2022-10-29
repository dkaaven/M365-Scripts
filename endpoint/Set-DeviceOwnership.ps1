<#
.SYNOPSIS
    Change owner of a device.
.DESCRIPTION
     
.PARAMETER ObjectId
    The Object Id of the unit you want to change owenership over
.PARAMETER upn
    The email address of the new owen
.EXAMPLE
    . .\Set-DeviceOwnership.ps1
    Set-DeviceOwnership -ObjectId <ObjectId -upn <OwnerId>
.NOTES
    Inspired by:    https://blog.matrixpost.net/change-owner-for-azure-ad-joined-windows-10-devices/
    FileName:    Set-DeviceOwnership.ps1
    Author:      Daniel Kåven
    Contact:     @DKaaven
    Created:     2022-09-01
    Updated:     2022-09-01
    Version history:
    1.0.0 - (2022-09-01) Script created
#>

function Set-DeviceOwnership {
    [CmdletBinding()]    

    Param(
        [Parameter(Position=0)]
        [string]$ObjectId,
        [Parameter(Position=1)]
        [string]$upn 
    )

    #region - Get information
    if ($null -eq $ObjectId) {
        $ObjectId = Read-Host "Enter the Device ObjectId"
    }
    if ($null -eq $upn) {
        $ObjectId = Read-Host "Enter the User Principal Name"
    }
    $NewOwner = Get-AzureADUser -SearchString $upn
    $NewOwnerName = $NewOwner.DisplayName
    $NewOwnerId = $NewOwner.ObjectId

    $OldOwner = Get-AzureADDeviceRegisteredOwner -ObjectId $ObjectId
    $OldownerName = $OldOwner.Displayname
    $OldOwnerId = $OldOwner.ObjectId
    #endregion

    #region - Promt user for confirmation
    Write-Host "The following changes will be made:" -ForegroundColor Blue
    Write-Host "Device ObjectId: $ObjectId"
    Write-Host "Old Owner: $OldownerName"
    Write-Host "New Owner: $NewOwnerName"

    $Title = "Do you want to set new owners?"
    $Info = "This can be reversed by running the command 'Set-DeviceOwnership -ObjectId $ObjectId -upn $OldOwnerId'"
    $options = [System.Management.Automation.Host.ChoiceDescription[]] @("&Yes", "&No")
    [int]$defaultchoice = 1
    $opt = $host.UI.PromptForChoice($Title, $Info, $Options, $defaultchoice)
    switch($opt) {
        0 {
            # adding the new owner to the device where ObjectId is the object id from the device you want to change and RefObjecteID is the object id from the new user and owner.
            Add-AzureADDeviceRegisteredOwner -ObjectId $ObjectId -RefObjectId $NewOwnerId

            # remove the existing/old owner from the device where ObjectID is the object id from the device you want to change and OwnerId the object id from the existing/old user.
            Remove-AzureADDeviceRegisteredOwner -ObjectId $ObjectId -OwnerId $OldOwnerId

            Write-Host "Device ownership changed from $OldownerName to $NewOwnerName" -ForegroundColor Green
        }
        1 {
            Write-Warning "No changes made."
        }

    }
}