<#
.SYNOPSIS
    This script returns candidate words for the New York Times Spelling Bee puzzle.

.DESCRIPTION
    The New York Times Spelling Bee puzzle specifies seven letters each day
    that must be used to construct words. Words can contain only those letters. 
    This script finds all words from a dictionary that contain some combination 
    of those letters and groups them by word length. 

.PARAMETER RequiredLetters
    The seven letters used for the day's puzzle.

.EXAMPLE
    Example of how to use the script:
    ./get-matching-words.ps1 -RequiredLetters ABCDEFG

.NOTES
    Additional notes about the script.

    Version:        1.0
    Author:         Doron Chosnek
    Creation Date:  April 14, 2024
    Last Modified:  April 14, 2024

    Copyright:      © 2024 Doron Chosnek. All rights reserved.

    License:        MIT License
    You are free to copy, modify, and distribute this script with attribution under the terms of the MIT License.
    See the LICENSE file for details, or visit https://opensource.org/licenses/MIT.

.LINK
    https://www.nytimes.com/puzzles/spelling-bee
#>


# there is one mandatory parameter: the letters for the day's puzzle
param (
    [Parameter(Mandatory=$true)]
    [string]$Center,
    [Parameter(Mandatory=$true)]
    [string]$Outer
)

$RequiredLetters = $Outer + $Center

# save words that contain only letters in $RequiredLetters using regex 
# lookahead to ensure the word contains the center letter
$filtered_words = Get-Content 'dictionary.txt' | Where-Object { 
    $_ -match "^(?=.*${Center})[${RequiredLetters}]+$" 
}

# group words by length and display those groups on the screen
$grouped_words = $filtered_words | Group-Object -Property { $_.Length }
foreach ($group in $grouped_words) {
    Write-Output "Words with $($group.Name) characters:"
    $group.Group | Write-Output
    Write-Output ""  # Adds an empty line for better readability
}

# find the pangram (words that contain all 7 letters)
foreach ($word in $filtered_words) {
    $flag = $true
    foreach ($digit in 0..6) {
        if ($word -notmatch $RequiredLetters[$digit]) { $flag = $false }
    }
    if ($flag) { Write-Host "panagram: $($word)" }
}

Write-Host "`nFound $($filtered_words.Count) words.`n"