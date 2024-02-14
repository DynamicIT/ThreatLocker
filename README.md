# ThreatLocker
Connect to ThreatLocker's new Portal API with PowerShell.

## Overview
Basic wrapper for ThreatLocker's new Portal API. Most endpoints are unimplemented, but what's available is already very helpful (e.g. cloning an existing app control policy into another org).

### General
- [x] Authenticate with Username, Password & MFA.
- [x] Authenticate with SSO accounts (extract auth token from browser).
- [x] List organizations.
- [x] Create new organizations.
- [x] List groups.
- [x] List computers.
- [x] Auto completion for org/group/computers, with cache.
- [ ] Change computer status / maintenance
- [ ] Report on computer status to identify old or out of date machines.

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
