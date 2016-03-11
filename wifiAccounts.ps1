$host.ui.RawUI.WindowTitle = "Wifi Account"

$usernameList = @()

"Press enter on an empty item to end the loop."

$username = "string"

while ($username -ne "") {
    
    $number = $usernameList.Count + 1

    $username = Read-Host -Prompt "Username $number"
    
    if ($username -ne "") {

        $usernameList += "Username " + $number + ": " + $username

    }

}

$items = $usernameList -join "`n"

$studentName = Read-Host -Prompt "Enter the student's first name"

if ($usernameList.Count -eq 1) {
    $password = "Password: mbts1234"
    $intro = "Here is the username and password for your WiFi:"
} elseif ($usernameList.Count -eq 2) {
    $password = "Password for both: mbts1234"
    $intro = "Here are the usernames and password for your WiFi:"
} else {
    $password = "Password for all: mbts1234"
    $intro = "Here are the usernames and password for your WiFi:"
}

$emailTemplate = @"
$studentName,

$intro

$items
$password

Please let me know if you have any other questions.

Austin

"@

$emailTemplate | Clip

Read-Host -Prompt "The email has been copied to the clipboard"