<#
.SYNOPSIS
    Make an API call and save an excel file to current directory.
.DESCRIPTION
    This is an exampel code and shouldn't be used in production.
.PARAMETER Filename (mandatory)
    Set filename for the file, excluding ".xlsx"
.PARAMETER ApiQuery
    If not set it uses a standard query for testing

.LINK
    Import Excel:   https://www.powershellgallery.com/packages/ImportExcel/7.4.1

.EXAMPLE
    ApiToExcel MyResults

.EXAMPLE
    ApiToExcel BoredResult https://www.boredapi.com/api/activity 

.NOTES
    FileName:    ExcelToBlob.ps1
    Author:      Daniel Kåven
    Contact:     @DKaaven
    Created:     2022-04-14
    Updated:     2022-04-14
    Version history:
    1.0.0 - (2022-03-25) Script created
#>
# Source Blob-storage https://docs.microsoft.com/en-us/azure/storage/blobs/blob-powershell
function ApiToExcel {
    [CmdletBinding()]   

    Param(
        [Parameter(Position=0, Mandatory=$false)]
        [String]$Filename = "Export-" + (Get-Random -Minimum 1000 -Maximum 9999),
        [Parameter(Position=1, Mandatory=$false)]
        [String]$ApiQuery = "http://universities.hipolabs.com/search?country=Norway"
    )
    Begin {
        $module = "ImportExcel"
        Import-Module $module
        if (!(Get-Module -Name $module)) {
            Write-Error -Message "This requires a module. Please run `"Install-Module -Name $module`" and restart terminal to continue." -Category NotInstalled
            Start-Sleep -s 30
            Exit
        Import-Module -Name $Module
        }
    }
    Process {
        #Connect to API
        Try {
            Invoke-RestMethod -Uri $ApiQuery | Export-Excel .\$Filename.xlsx
            return ".\$Filename.xlsx"
            Write-Host "$Filename.xlsx created successfully" -ForegroundColor Green
        }
        catch [System.Exception] {
            Write-Error -Message $_.Exception.Message
        }
    }
}

<#
.SYNOPSIS
    Upload a File to an Azure Blob Storage
.DESCRIPTION
    This is an exampel code and shouldn't be used in production.
.PARAMETER input1

.PARAMETER input2

.LINK
    blob:           https://docs.microsoft.com/en-us/azure/storage/blobs/blob-powershell
    az:             https://docs.microsoft.com/en-us/powershell/azure/install-az-ps?view=azps-7.4.0

.EXAMPLE
    Get-Item C:\file.xlsx | ExcelToBlob
.NOTES
    FileName:    ExcelToBlob.ps1
    Author:      Daniel Kåven
    Contact:     @DKaaven
    Created:     2022-04-14
    Updated:     2022-04-14
    Version history:
    1.0.0 - (2022-03-25) Script created
#>
# Source Blob-storage https://docs.microsoft.com/en-us/azure/storage/blobs/blob-powershell

function FileToBlob {
    [CmdletBinding()]   

    Param(
        [Parameter(ValueFromPipeline)]
        [ValidateNotNullOrEmpty]
        $File
    )

    Begin {
        #Import configurations
        $Config = Get-Content -Path .\config.json -Raw | ConvertFrom-Json

        # Import Module
        $module = "Az"
        Import-Module $module
        if (!(Get-Module -Name $module)) {
            Write-Error -Message "This requires a module. Please run `"Install-Module -Name $module`" and restart terminal to continue." -Category NotInstalled
            Start-Sleep -s 30
            Exit 1
        }
        Import-Module -Name $Module

        #region - Connect to Azure
        try {
            Connect-AzAccount
        }
        catch [System.Exception] {
            Write-Host $_.Exception.Message
            Start-Sleep -s 30
            Exit 1
        }
        #endregion

        #Get Credentials
        # $account = Get-AzStorageAccount -ResourceGroupName $Config.Azure.ResourceGroupName -Name $Config.Azure.AccountName
        # $account.Location
        # $account.Sku
        # $account.Kind

        #Create a context object using Azure AD credentials
        $ctx = New-AzStorageContext -StorageAccountName $Config.Azure.AccountName -UseConnectedAccount
    }
    Process {
        #Upload a single named file
        Set-AzStorageBlobContent -File $Filename -Container $Config.Azure.ContainerName -Context $ctx
    }
    End {
        Disconnect-AzConnect
    }
}

