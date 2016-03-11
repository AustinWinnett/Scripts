$host.ui.RawUI.WindowTitle = "Password Changer"

#--------- Connect to AD ---------

Import-Module ActiveDirectory

#--------- Type in student's name ---------

$findUser = '*' + $(Read-Host -Prompt "Please enter the name of the user") + '*'

if ($findUser -ne "*old*") {

#--------- Displays the student(s) name and email, in case there are multiple ---------

Get-ADuser -f {(Name -like $findUser)} | Select-Object Name, UserPrincipalName | Sort-Object Name

$Searcher = [ADSISearcher]"(name=$findUser)"
$Results = $Searcher.FindOne()

While ($Results -eq $Null) {
    $findUser = '*' + $(Read-Host -Prompt "User does not exist.  Please try again") + '*'
    Get-ADuser -f {(Name -like $findUser)} | Select-Object Name, UserPrincipalName | Sort-Object Name
    $Searcher = [ADSISearcher]"(name=$findUser)"
    $Results = $Searcher.FindOne()
    Continue
    }

#--------- If there is only one result, it is copied to clipboard here ---------

$singleUser = Get-ADuser -f {(Name -like $findUser)} | Select-Object UserPrincipalName

if ($singleUser.count -lt 2) {

    $singleUser = $singleUser -replace "@{UserPrincipalName=" -replace "@mbts.edu}"

    $user = $singleUser

    Read-Host -Prompt "Continue for $user"

} else {

    #--------- Enter in the username for verification, with NO ENDING ---------

    $user = Read-Host -Prompt "Please enter username"

}

$SearcherUsername = [ADSISearcher]"(SamAccountName=$user)"
$ResultsUsername = $SearcherUsername.FindOne()

While ($ResultsUsername -eq $Null) {
    $user = Read-Host -Prompt "User does not exist.  Please try again"
    $SearcherUsername = [ADSISearcher]"(SamAccountName=$user)"
    $ResultsUsername = $SearcherUsername.FindOne()
    Continue
    }

#--------- Generates random password, sets password ---------

$okay = "n"

while ($okay -eq "n") {
$rand = new-object System.Random
$symbol = "@","-","&"
$words = import-csv c:\scripts\dict.csv
$word1 = ($words[$rand.Next(0,$words.Count)]).Word
$word2 = ($words[$rand.Next(0,$words.Count)]).Word
$word3 = ($words[$rand.Next(0,$words.Count)]).Word
$sym = ($symbol[$rand.Next(0,$symbol.Count)])
$num = New-Object  System.Random

$password = ($word1.substring(0,1).toupper()+$word1.substring(1).tolower() + $word2.substring(0,1).toupper()+$word2.substring(1).tolower() + $sym + $num.next(1,99))

Write-Host $password -ForegroundColor Cyan

$okay = Read-Host -Prompt "Okay? (y/n)"

if (($okay -ne "c") -and ($okay -ne "y") -and ($okay -ne "")) {
    $password = $okay
}

}

$plainPassword = $password

#$plainPassword = (Read-Host -Prompt "Provide New Password")

$newPassword = ConvertTo-SecureString $plainPassword –asplaintext –force 

Set-ADAccountPassword -identity $user -NewPassword $newPassword -Reset

#--------- Gets the user's actual name for the email ---------

$getName = Get-ADUser -identity $user -Properties name, givenname | Select-Object name, givenname

$userName = $getName.givenname

$fullName = $getName.name

$newPassword = ConvertFrom-SecureString $newPassword

#--------- Puts the email together and copies it to clipboard ---------

$passwordEmail = @"
$userName,

I have reset your password to $plainPassword for your email and portal.  Please let me know if you have any other questions.

Austin
"@

$passwordEmail | Clip

$endScript = Read-Host -Prompt "The password for $fullName ($user) has been reset.  Press enter to finish"

#--------- Changes things for Blackboard, if necessary ---------

if ($endScript -eq "bb") {

$passwordEmail = @"
$userName,

I have reset your password to $plainPassword for your email, portal, and Blackboard.  Please let me know if you have any other questions.

Austin
"@

$passwordEmail | Clip

$endScript = Read-Host -Prompt "Copied the email for Blackboard.  Press enter to finish"

}

#--------- Changes things for Rio, if necessary ---------

if ($endScript -eq "rio") {

$passwordEmail = @"
Rio,

I have reset $userName's password to $plainPassword for their email and portal.  Please let me know if you have any other questions.

Austin
"@

$passwordEmail | Clip

$endScript = Read-Host -Prompt "Copied the email for Rio.  Press enter to finish"

}

#--------- Changes things for Rio and Blackboard, if necessary ---------

if ($endScript -eq "rio bb") {

$passwordEmail = @"
Rio,

I have reset $userName's password to $plainPassword for their email, portal, and Blackboard.  Please let me know if you have any other questions.

Austin
"@

$passwordEmail | Clip

$endScript = Read-Host -Prompt "Copied the email for Rio and Blackboard.  Press enter to finish"

}



} else {

$firstName = Read-Host -Prompt "Enter the student's first name"


#--------- Generates random password, sets password ---------

$okay = "n"

while ($okay -eq "n") {
$rand = new-object System.Random
$symbol = "@","-","&"
$words = import-csv c:\scripts\dict.csv
$word1 = ($words[$rand.Next(0,$words.Count)]).Word
$word2 = ($words[$rand.Next(0,$words.Count)]).Word
$word3 = ($words[$rand.Next(0,$words.Count)]).Word
$sym = ($symbol[$rand.Next(0,$symbol.Count)])
$num = New-Object  System.Random

$password = ($word1.substring(0,1).toupper()+$word1.substring(1).tolower() + $word2.substring(0,1).toupper()+$word2.substring(1).tolower() + $sym + $num.next(1,99))

Write-Host $password -ForegroundColor Cyan

$okay = Read-Host -Prompt "Okay? (y/n)"

if (($okay -ne "c") -and ($okay -ne "y") -and ($okay -ne "")) {
    $password = $okay
}

}

$plainPassword = $password

#$plainPassword = (Read-Host -Prompt "Provide New Password")

#--------- Puts the email together and copies it to clipboard ---------

$passwordEmail = @"
$firstName,

I have reset your password to $plainPassword for your email and portal.  Please let me know if you have any other questions.

Austin
"@

$passwordEmail | Clip

$endScript = Read-Host -Prompt "The password for $firstName has been reset.  Press enter to finish"

#--------- Changes things for Blackboard, if necessary ---------

if ($endScript -eq "bb") {

$passwordEmail = @"
$firstName,

I have reset your password to $plainPassword for your email, portal, and Blackboard.  Please let me know if you have any other questions.

Austin
"@

$passwordEmail | Clip

$endScript = Read-Host -Prompt "Copied the email for Blackboard.  Press enter to finish"

}

#--------- Changes things for Rio, if necessary ---------

if ($endScript -eq "rio") {

$passwordEmail = @"
Rio,

I have reset $firstName's password to $plainPassword for their email and portal.  Please let me know if you have any other questions.

Austin
"@

$passwordEmail | Clip

$endScript = Read-Host -Prompt "Copied the email for Rio.  Press enter to finish"

}

#--------- Changes things for Rio and Blackboard, if necessary ---------

if ($endScript -eq "rio bb") {

$passwordEmail = @"
Rio,

I have reset $firstName's password to $plainPassword for their email, portal, and Blackboard.  Please let me know if you have any other questions.

Austin
"@

$passwordEmail | Clip

$endScript = Read-Host -Prompt "Copied the email for Rio and Blackboard.  Press enter to finish"

}



}