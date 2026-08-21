$minuteAdded = @{}
$possibleMatches = @{}
Measure-Command {
$allComputers | %{ $minuteAdded[$_.dateAdded.ToString('yyyy-MM-dd HH:mm')] = $_ }
foreach ($comp in $allComputers) {
    if ($comp.lastCheckin -gt (Get-Date).AddHours(-1)) {
        continue
    }
    $matching = $allComputers | Where-Object {
        $_.lastCheckin -lt $comp.dateAdded.AddMinutes(5) -and $_.lastCheckin -gt $comp.dateAdded.AddMinutes(-5)
    }

    if ($matching) {
        $possibleMatches[$comp.computerId] = $matching
    }
}

}



$minuteAdded = @{}
$allComputers | Where-Object dateAdded -lt (Get-Date).AddHours(-1) | ForEach-Object {
    $key = $_.dateAdded.ToString('yyyy-MM-dd HH:mm')
    if ($minuteAdded.ContainsKey($key)) {
        $minuteAdded[$key] += $_
    } else {
        $minuteAdded[$key] = @($_)
    }
}

Measure-Command {
$possibleMatches = @{}
foreach ($comp in $allComputers) {
    if (-not $comp.lastCheckin) {
        continue
    }
    $matching = foreach ($offset in -5..5) {
        $key = $comp.lastCheckin.AddMinutes($offset).ToString('yyyy-MM-dd HH:mm')
        if ($minuteAdded.Contains($key)) {
            $minuteAdded[$key]
        }
    }


    #$matching = $allComputers | Where-Object {
    #    $_.lastCheckin -lt $comp.dateAdded.AddMinutes(5) -and $_.lastCheckin -gt $comp.dateAdded.AddMinutes(-5)
    #}

    if ($matching) {
        $possibleMatches[$comp.computerId] = $matching
    }
}

}



Measure-Command {
$possibleMatches = foreach ($comp in $allComputers) {
    if (-not $comp.lastCheckin) {
        continue
    }
    foreach ($offset in -5..5) {
        $key = $comp.lastCheckin.AddMinutes($offset).ToString('yyyy-MM-dd HH:mm')
        foreach ($match in $minuteAdded[$key]) {
            if ($match.organizationId -eq $comp.organizationId) {
                [PSCustomObject]@{
                    NewName = $comp.computerName
                    NewId = $comp.computerId
                    NewDateAdded = $comp.dateAdded
                    NewLastCheckin = $comp.lastCheckin
                    NewIP = $comp.lastCheckinIPAddress

                    MatchName = $match.computerName
                    MatchId = $match.computerId
                    MatchDateAdded = $match.dateAdded
                    MatchLastCheckin = $match.lastCheckin
                    MatchIP = $match.lastCheckinIPAddress
                }
            }
        }
    }
}

}

$possibleMatches | ft -auto
