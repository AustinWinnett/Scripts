$host.ui.RawUI.WindowTitle = "Weekly Update"

$updateList = @()

"Press enter on an empty item to end the loop."

$updateItem = "string"

while ($updateItem -ne "") {
    
    $number = $updateList.Count + 1

    $updateItem = Read-Host -Prompt "Item $number"
    
    if ($updateItem -ne "") {

        $updateList += "-" + $updateItem

    }

}

$items = $updateList -join "`n"

$emailTemplate = @"
David,

Here are some things I've been working on this week:

$items

Austin

"@

$emailTemplate

$Server = "outlook.office365.com"
$From = "awinnett@mbts.edu"
$To = "dmeyer@mbts.edu"
$Subject = "Weekly Update"
$Body = $emailTemplate
$smtpUserName = "awinnett" # This could be also in e-mail address format
$smtpPassword = "Yetevennow-212"
$smtpDomain = "mbts.edu"

$ready = Read-Host -Prompt "Ready to send? (y/n)"

if ($ready -eq "y") {
    $Outlook = New-Object -ComObject Outlook.Application
    $Mail = $Outlook.CreateItem(0)
    $Mail.To = $To
    $Mail.Subject = $Subject
    $Mail.Body = $Body
    $Mail.Send()
    Read-Host -Prompt "Email was sent.  Press enter to finish"
} else {
    Read-Host -Prompt "Email was not sent.  Press enter to finish"
}