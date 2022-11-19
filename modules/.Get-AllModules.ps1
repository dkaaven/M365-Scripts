function Get-AllModules {
    $Modules = Get-ChildItem -Path . -Filter '*.psm1'
    foreach ($Module in $Modules) {
        try {
            Import-Module $Module
            $ModuleName = $Module.Name.Split(".")[0]
            Write-Output "Imported: $ModuleName"
        }
        catch {
            Write-warning -Message "$ModuleName couldn't be imported."
            Write-Output "Filename: $Module"
        }
    }
}
Get-AllModules
