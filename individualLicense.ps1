#--------Connect to Office 365--------

Import-Module ActiveDirectory

"Signing in as awinnett@mbts.edu..."

Import-Module MSOnline 
$Cred = Import-Clixml $env:file02\users\awinnett\Documents\MyO365Creds.xml
Connect-MsolService -Credential $Cred

$upn = Read-Host -Prompt "What is the user's email address?"

#--------License package that you want to assign to the student--------

$server = 'MidwesternBa:STANDARDWOFFPACK_IW_STUDENT'

$MyLicenseAssignmentOption = New-MsolLicenseOptions -AccountSkuId $server -DisabledPlans MCOSTANDARD

$ErrorActionPreference = 'stop'

$successfulUsers = @()

$error = $false

$moveUser = $upn -replace "@.*" -replace ".*u"

try {
    
    Set-MsolUser -UserPrincipalName $_.UserPrincipalName -usagelocation “US”
    }
catch {
    Write-Warning "$upn does not currently have an Office 365 account.";
    $error = $true
    }

if (!$error) {
    try {
        Set-MsolUserLicense -UserPrincipalName $upn -AddLicenses “$server” -LicenseOptions $MyLicenseAssignmentOption
        Get-ADUser $moveUser | Move-ADObject -TargetPath 'ou=Active Student Accounts,ou=New Student Accounts,dc=MBTS,dc=EDU'
        }
    catch {
        Write-Warning "$upn already has licenses assigned.";
        }
    }

$ErrorActionPreference = 'silentlycontinue'

Read-Host -Prompt "The process has completed. Pat yourself on the back, and press enter to exit."