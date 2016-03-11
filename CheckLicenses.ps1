$host.ui.RawUI.WindowTitle = "Check Licenses"

Import-Module MSOnline 
$Cred = Import-Clixml $env:file02\users\awinnett\Documents\MyO365Creds.xml
Connect-MsolService -Credential $Cred

$ErrorActionPreference = 'silentlycontinue'

while ($userEmail -ne "q") {
        $userEmail = Read-Host -Prompt "Please enter user's email address (or 'q' to exit)"

        if ($userEmail -ne "q") {
            $checkLicenses = (Get-MsolUser -UserPrincipalName $userEmail).Licenses.ServiceStatus
            $checkLicenses
            if ($checkLicenses -eq $null) {
                Write-Warning "The user does not exist."
                }
        }
}