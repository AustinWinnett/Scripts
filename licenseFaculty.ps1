Import-Module MSOnline
Connect-MsolService

$server = 'MidwesternBa:STANDARDWOFFPACK_IW_FACULTY'

$upn = Read-Host -Prompt "Enter faculty email address"

Set-MsolUser -UserPrincipalName $upn -usagelocation “US”
Set-MsolUserLicense -UserPrincipalName $upn -AddLicenses “$server”

Read-Host -Prompt "If no errors were given, then the $upn has been licensed."