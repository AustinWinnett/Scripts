$host.ui.RawUI.WindowTitle = "Get Credentials"

#--------- Connect to AD ---------

Import-Module ActiveDirectory

#--------- Ask email type ---------

$emailType = Read-Host -Prompt "Old or new email?"

if ($emailType -eq "new") {

    #--------- Type in student's name ---------

    $findUser = '*' + $(Read-Host -Prompt "Please enter the name of the user") + '*'

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

    #--------- Type password, sets password ---------

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

    $plainPassword | Clip

    #$plainPassword = (Read-Host -Prompt "Provide New Password")

    $newPassword = ConvertTo-SecureString $plainPassword –asplaintext –force 

    Set-ADAccountPassword -identity $user -NewPassword $newPassword -Reset

    #--------- Gets the user's actual name for the email ---------

    $getName = Get-ADUser -identity $user -Properties name, givenname | Select-Object name, givenname

    $userName = $getName.givenname

    $fullName = $getName.name

    $newPassword = ConvertFrom-SecureString $newPassword

} else {
    
    $userName = Read-Host -Prompt "Please enter first name of student"
    $user = Read-Host -Prompt "Please enter username"
    $plainPassword = Read-Host -Prompt "Provide new password"
}

#--------- Asks for email type and if Blackboard's needed ---------

if ($emailType -eq "new") {

    $emailAddress = $user + "@mbts.edu"
    $email = "http://365.mbts.edu"

} else {

    $emailAddress = $user + "@student.mbts.edu"
    $email = "http://mail.student.mbts.edu"

 }

$blackboard = Read-Host -Prompt "Are Blackboard credentials needed? (y/n)"

#--------- Puts the email together and copies it to clipboard ---------

$emailAndPortalEmail = @"
$userName,

These are the credentials for your student email and portal:

Username (Email): $emailAddress
Username (Portal): $user
Password for both: $plainPassword

You can access them at the following addresses:

Email: $email
Portal: https://portal.mbts.edu/student/login.asp

Please let me know if you have any other questions!

Austin
"@

$allCredentialsEmail = @"
$userName,

These are the credentials for your student email, portal, and Blackboard:

Username (Email): $emailAddress
Username (Portal/Blackboard): $user
Password for all: $plainPassword

You can access them at the following addresses:

Email: $email
Portal: https://portal.mbts.edu/student/login.asp
Blackboard: https://online.mbts.edu/

Please let me know if you have any other questions!

Austin
"@

if ($blackboard -eq "y") {

    $allCredentialsEmail | Clip

} else {

    $emailAndPortalEmail | Clip

}

$endScript = Read-Host -Prompt "The password for $fullName ($user) has been reset and credentials copied to clipboard.  Press enter to finish"

#--------- Changes things for Glen, if necessary ---------

if (($endScript -eq "g") -and ($blackboard -ne "y")) {

$emailAndPortalEmail = @"
$userName,

Glen Higgins told me that you need your login information.  These are the credentials for your student email and portal:

Username (Email): $emailAddress
Username (Portal): $user
Password for both: $plainPassword

You can access them at the following addresses:

Email: $email
Portal: https://portal.mbts.edu/student/login.asp

Please let me know if you have any other questions!
"@

$emailAndPortalEmail | Clip

Read-Host -Prompt "Copied the email for Glen.  Press enter to finish"

}

#--------- Changes things for Glen, if necessary ---------

if (($endScript -eq "g") -and ($blackboard -eq "y")) {

$allCredentialsEmail = @"
$userName,

Glen Higgins told me that you need your login information.  These are the credentials for your student email, portal, and Blackboard:

Username (Email): $emailAddress
Username (Portal/Blackboard): $user
Password for all: $plainPassword

You can access them at the following addresses:

Email: $email
Portal: https://portal.mbts.edu/student/login.asp
Blackboard: https://online.mbts.edu/

Please let me know if you have any other questions!

Austin
"@

$allCredentialsEmail | Clip

Read-Host -Prompt "Copied the email for Glen.  Press enter to finish"

}

#--------- Short credentials, no Blackboard ---------

if (($endScript -eq "short") -and ($blackboard -ne "y")) {

$emailAndPortalEmail = @"

Username (Email): $emailAddress
Username (Portal): $user
Password for both: $plainPassword
"@

$emailAndPortalEmail | Clip

Read-Host -Prompt "Copied the email for short credentials.  Press enter to finish"

}
 
#----- Short credentials, w/ Blackboard ----------

if (($endScript -eq "short") -and ($blackboard -eq "y")) {

$allCredentialsEmail = @"
Username (Email): $emailAddress
Username (Portal/Blackboard): $user
Password for all: $plainPassword
"@

$allCredentialsEmail | Clip

Read-Host -Prompt "Copied the email for short credentials.  Press enter to finish"

}