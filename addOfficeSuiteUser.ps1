$host.ui.RawUI.WindowTitle = "Add Office Suite User"

#--------Connect to Office 365--------
Import-Module MSOnline 
$Cred = Import-Clixml $env:file02\users\awinnett\Documents\MyO365Creds.xml
Connect-MsolService -Credential $Cred

#--------Asks questions about user--------
$firstName = Read-Host -Prompt "Please enter user's first name"
$lastName = Read-Host -Prompt "Please enter user's last name"
$displayName = $firstName + " " + $lastName
Write-Host "Display Name set to $displayName" -ForegroundColor Cyan
$upn = Read-Host -Prompt "Please enter username (without @mbts.edu)"
$emailAddress = $upn + "@mbts.edu"
Write-Host "Email Address set as $emailAddress" -ForegroundColor Cyan

#--------Sets up password for user--------
$upnNumbers = $upn.substring($upn.length - 5, 5)
$password = $password = $upnNumbers + "@" + $firstName.substring(0,1).ToLower() + $lastName.substring(0,1).ToUpper()
Write-Host "Password set to $password" -ForegroundColor Cyan

#--------Chooses the licensing options-------
$server = 'MidwesternBa:STANDARDWOFFPACK_IW_STUDENT'
$officeLicense = New-MsolLicenseOptions -AccountSkuId $server -DisabledPlans MCOSTANDARD, SWAY, YAMMER_EDU, SHAREPOINTWAC_EDU, SHAREPOINTSTANDARD_EDU, EXCHANGE_S_STANDARD

#---------Creates the user-------------
New-MsolUser -DisplayName $displayName -FirstName $firstName -LastName $lastName -UserPrincipalName $emailAddress -UsageLocation "US" -LicenseAssignment $server -LicenseOptions $officeLicense -Password $password

#--------- Puts the email together and copies it to clipboard ---------
$officeEmail = @"
$firstName,

In order to set you up to download Microsoft Office Suite, I have set up an Office 365 account for you.  All you will be able to do with this account is download Microsoft Office Suite.  Please go to https://portal.office.com/OLS/MySoftware.aspx and login with the following credentials:

Username: $emailAddress
Password: $password

After this, just follow the instructions on the screen, and you should be set.  Let me know if you have any other questions!

Austin
"@

$officeEmail | Clip

"An Office 365 account for $displayName ($upn) has been created."
Read-Host -Prompt "The email has been copied to the clipboard.  Press enter to finish"