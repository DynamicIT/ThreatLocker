# ThreatLocker
Connect to ThreatLocker's new Portal API with PowerShell.

## Overview
Basic wrapper for ThreatLocker's new Portal API. Most endpoints are unimplemented, but what's available is already very helpful (e.g. cloning an existing app control policy into another org).

## Examples
```powershell
Connect-ThreatLocker -Instance g

$allComputers = Get-ThreatLockerOrg | Get-ThreatLockerComputerDetail
$allComputers | ForEach-Object {
    ConvertTo-Json -Depth 5 -Compress -InputObject $_
} | Set-Content "allComputers_$( Get-Date -Format FileDateTime ).jsonl"

$cutoffDate = (Get-Date).AddDays(-45)
if ($PSVersionTable.PSEdition -eq 'Desktop') {
    # we will use string comparison for dates in PowerShell 5.1
    $cutoffDate = $cutoffDate.ToUniversalTime().ToString('yyyy-MM-ddTHH:MM:ssZ')
}
$inactiveComputers = $allComputers | ?{ $_.lastCheckin -lt $cutoffDate -and $_.dateAdded -lt $cutoffDate }

$inactiveAcPolicies = $inactiveComputers | Get-ThreatLockerACPolicy
$inactiveAcPolicies | ForEach-Object {
    ConvertTo-Json -Depth 5 -Compress -InputObject $_
} | Set-Content "inactivePolicy_$( Get-Date -Format FileDateTime ).jsonl"

$inactivePath = "inactiveComputers_$( Get-Date -Format FileDateTime ).csv"
$inactiveComputers | Select-Object computerName, computerId, organization, lastCheckin | Sort-Object lastCheckin | Export-Csv $inactivePath
Write-Host "Please send $inactivePath to ThreatLocker support to process."
```

## Roadmap

### General
- [x] Authenticate with ThreatLocker API Users.
- [x] Authenticate with Username, Password & MFA.
- [x] Authenticate with SSO accounts (extract auth token from browser).
- [x] List organizations.
- [x] Create new organizations.
- [x] List groups.
- [x] List computers.
- [x] Auto completion for org/group/computers, with cache.
- [ ] Change computer status / maintenance
- [x] Report on computer status to identify old or out of date machines.

### Application Control
- [x] List and search AppControl Policies
- [x] List and search AppControl Applications
- [x] Get files for existing applications, with search
- [ ] Edit ring fencing for existing policies.
- [ ] Edit other policy settings.
- [x] Clone an existing policy into another org or group.
- [ ] ???

### Storage Control
- [x] List and search Storage Control Policies
- [x] List Storage Control Devices
- [ ] Edit policy settings.
- [x] Clone an existing policy into another org or group.
- [ ] ???

### Network Control
- [ ] ???


