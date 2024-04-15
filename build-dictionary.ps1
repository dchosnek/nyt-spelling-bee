<#
.SYNOPSIS
    This script builds a text dictionary of English words with no special characters.

.DESCRIPTION
    This script builds a dictionary for use with The New York Times Spelling 
    Bee puzzle, so all words are have a minimum length of four and contain no
    no-alpha characters (no spaces, dashes, punctuation, etc.). Additionally,
    the dictionary excludes words that have more than seven unique characters
    since the NYT puzzle only specifies seven letters each day.

.EXAMPLE
    Example of how to use the script:
    ./build-dictionary.ps1

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
    https://www.kaggle.com/datasets/dfydata/the-online-plain-text-english-dictionary-opted

.LINK
    https://www.nytimes.com/puzzles/spelling-bee
#>

$words = @{}

# regex pattern to capture text between <B> and </B>
$pattern = '<B>(.*?)</B>'

foreach ($letter in 'a'..'z') {

    # retrieve the dictionary for each letter of the alphabet
    $uri = "https://www.mso.anu.edu.au/~ralph/OPTED/v003/wb1913_$($letter).html"
    $response = Invoke-WebRequest -Uri $uri

    # retrieve all matches
    $found = $response.Content | Select-String -Pattern $pattern -AllMatches

    # process each match IF any matches were found
    if ($found -and $found.Count -gt 0) {

        # this variable should contain many Matches, and for each match we
        # need the first group (the part of the match that is in the parenthesis
        # of the $pattern)
        $found.Matches | ForEach-Object {
            $myword = $_.Groups[1].Value.ToUpper()

            # the word must be at least 4 characters and not have non-alpha characters
            if ( $myword.Length -ge 4 -and $myword -notmatch '\W' ) {

                # only save words that have less than 8 UNIQUE characters
                $size = ($myword.ToCharArray() | Select-Object -Unique).Length
                if ( $size -lt 8 ) {
                    $words[$myword] = $true
                }

            }

        }
    }    
}

$words.Keys | Sort-Object | Set-Content 'dictionary.txt'

Write-Host "Created a dictionary with $($words.Keys.Count) words."
