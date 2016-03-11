$host.ui.RawUI.WindowTitle = "Extension Attribute Editor"

Import-Module ActiveDirectory

# Get all users in the TestAccounts OU.
$TestUsers = Get-ADUser -Filter * -SearchBase "ou=TestAccounts,ou=New Student Accounts,dc=MBTS,dc=EDU"
# Iterate the users and update extenstionAttribute15 in AD.

$i=0
foreach($TestUser in $TestUsers)
{
    # Update properties.
    $TestUser.extensionAttribute15 = $null
    # Update the user data in AD using the Instance parameter of Set-ADUser.
    Set-ADUser -Instance $TestUser
    $i++
    Write-Progress -activity “Updating accounts...” -status “Status: ” -PercentComplete (($i / $TestUsers.count)*100)
}