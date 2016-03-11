$host.ui.RawUI.WindowTitle = "Check 365 User Existence"

#--------Connect to Active Directory--------

Import-Module ActiveDirectory

#--------Export users from New Student Accounts OU to CSV--------

"Exporting AD list to CSV...(may take around 20 seconds)"

Get-ADUser -Filter * -SearchBase 'ou=New Student Accounts,dc=MBTS,dc=EDU' -Properties * | ?{$_.DistinguishedName -notmatch ‘ou=Active Student Accounts,ou=New Student Accounts,dc=MBTS,dc=EDU’-and $_.DistinguishedName -notmatch ‘ou=TestAccounts,ou=New Student Accounts,dc=MBTS,dc=EDU'-and $_.DistinguishedName -notmatch ‘ou=MISC ACCOUNTS,ou=New Student Accounts,dc=MBTS,dc=EDU’} | sort UserPrincipalName | select UserPrincipalName | Export-Csv  "c:\scripts\checkExists.csv" -NoTypeInformation

"Signing in as awinnett@mbts.edu..."

Import-Module MSOnline 
$Cred = Import-Clixml $env:file02\users\awinnett\Documents\MyO365Creds.xml
Connect-MsolService -Credential $Cred

"Using previously selected file to gather UserPrincipalNames..."

#--------Variable that holds AD-CSV file that was created above (I guess this isn't neeeded, but whatever)--------

$path = "c:\scripts\checkExists.csv"

$ErrorActionPreference = 'stop'


#--------CSV import command and mailbox creation loop--------

import-csv $path | foreach {$i=0} {

$user = $_ -replace ".*=" -replace "}.*"

$error = $false



try {
    
    Get-MsolUser -UserPrincipalName $_.UserPrincipalName
    }
catch {
    $error = $true
    }

if ($error) {
    Write-Host "$user --------------- DOES NOT EXIST" -ForegroundColor Cyan; $i++
}

Start-Sleep -Milliseconds 1000 

}

Remove-Item c:\scripts\checkExists.csv

Read-Host -Prompt "Welp, there you have it"