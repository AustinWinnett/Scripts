while ($continue -ne "n") {

$rand = new-object System.Random
$symbol = "@","-","&"
$words = import-csv c:\scripts\dict.csv
$word1 = ($words[$rand.Next(0,$words.Count)]).Word
$word2 = ($words[$rand.Next(0,$words.Count)]).Word
$word3 = ($words[$rand.Next(0,$words.Count)]).Word
$sym = ($symbol[$rand.Next(0,$symbol.Count)])

$num = New-Object  System.Random

$continue = "y"

$password = ($word1.substring(0,1).toupper()+$word1.substring(1).tolower() + $word2.substring(0,1).toupper()+$word2.substring(1).tolower() + $sym + $num.next(1,99))

Write-Host $password -ForegroundColor Cyan

$password | Clip

$continue = Read-Host -Prompt "Continue? (y/n)"

}