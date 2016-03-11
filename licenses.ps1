$host.ui.RawUI.WindowTitle = "Assign Licenses to AD Users"

#--------Connect to Office 365--------

#Import-Module MSOnline

#--------Connect to Active Directory--------

Import-Module ActiveDirectory

#--------Export users from New Student Accounts OU to CSV--------

"Exporting AD list to CSV...(may take around 20 seconds)"

Get-ADUser -Filter * -SearchBase 'ou=New Student Accounts,dc=MBTS,dc=EDU' -Properties * | ?{$_.DistinguishedName -notmatch ‘ou=Active Student Accounts,ou=New Student Accounts,dc=MBTS,dc=EDU’-and $_.DistinguishedName -notmatch ‘ou=TestAccounts,ou=New Student Accounts,dc=MBTS,dc=EDU'-and $_.DistinguishedName -notmatch ‘ou=MISC ACCOUNTS,ou=New Student Accounts,dc=MBTS,dc=EDU’} | sort UserPrincipalName | select UserPrincipalName | Export-Csv  "c:\scripts\ADUsersCSV\ADusers.csv" -NoTypeInformation

"Signing in as awinnett@mbts.edu..."

Import-Module MSOnline 
$Cred = Import-Clixml $env:file02\users\awinnett\Documents\MyO365Creds.xml
Connect-MsolService -Credential $Cred

"Using previously selected file to gather UserPrincipalNames..."

#--------Variable that holds AD-CSV file that was created above (I guess this isn't neeeded, but whatever)--------

$path = "c:\scripts\ADUsersCSV\ADusers.csv"

#--------License package that you want to assign to the student--------

$server = 'MidwesternBa:STANDARDWOFFPACK_IW_STUDENT'

$MyLicenseAssignmentOption = New-MsolLicenseOptions -AccountSkuId $server -DisabledPlans MCOSTANDARD

$ErrorActionPreference = 'stop'

$successfulUsers = @()

#--------CSV import command and mailbox creation loop--------

import-csv $path | foreach {$i=0} {

$user = $_ -replace ".*=" -replace "}.*"

$errorMsg = $false

$moveUser = $user -replace "@mbts.edu"

try {
    
    Set-MsolUser -UserPrincipalName $_.UserPrincipalName -usagelocation “US”
    }
catch {
    Write-Warning "$user does not currently have an Office 365 account."; $i++
    $errorMsg = $true
    }

if (!$errorMsg) {

    try {
        Set-MsolUserLicense -UserPrincipalName $_.UserPrincipalName -AddLicenses “$server” -LicenseOptions $MyLicenseAssignmentOption
        $successfulUsers += $user
        Get-ADUser $moveUser | Move-ADObject -TargetPath 'ou=Active Student Accounts,ou=New Student Accounts,dc=MBTS,dc=EDU'
        }
    catch {
        Write-Warning "$user already has licenses assigned."
        $successfulUsers += "!$user"
        Get-ADUser $moveUser | Move-ADObject -TargetPath 'ou=Active Student Accounts,ou=New Student Accounts,dc=MBTS,dc=EDU'; $i++
        }
    }

Start-Sleep -Milliseconds 1000 

}

$ErrorActionPreference = 'silentlycontinue'

$date = Get-Date -UFormat "%m-%d-%Y"

#--------Result report on licenses assigned to imported users--------

if (Test-Path "c:\scripts\results\users-$date.csv") {
    
    $newUsers = @()

    $joinedCSV = Import-csv "c:\scripts\results\users-$date.csv" -header "UPN"

    $i = 0
    foreach ($user in $successfulUsers) {

        $newUser = New-Object PsObject -Property @{ UPN = $successfulUsers[$i] }
        $newUsers += $newUser

        $i++

    }

    $joinedCSV += $newUsers

    $joinedCSV | export-csv "c:\scripts\results\users-$date.csv" -NoTypeInformation -force
    
} else {

    if ($successfulUsers.count -gt 1) {
        $successfulUsers
        $successfulUsers | ConvertFrom-CSV | export-csv "c:\scripts\results\users-$date.csv" -NoTypeInformation
    }  elseif ($successfulUsers.count -eq 1) {
        $successfulUsers += "---"
        $successfulUsers | ConvertFrom-CSV | export-csv "c:\scripts\results\users-$date.csv" -NoTypeInformation
    } else {
        Write-Host "No users were licensed."
    }

}

#import-csv $path | Get-MSOLUser | out-gridview

#--------Rename ADusers.csv file so it doesn't get in the way later--------

if (Test-Path "c:\scripts\ADUsersCSV\ADusers-$date.csv") {

    rename-item -path c:\scripts\ADUsersCSV\ADusers.csv -newname ADusers-$date-2.csv

} else { 

    rename-item -path c:\scripts\ADUsersCSV\ADusers.csv -newname ADusers-$date.csv

}

#Read-Host -Prompt "The process has completed. Pat yourself on the back, and press enter to exit."