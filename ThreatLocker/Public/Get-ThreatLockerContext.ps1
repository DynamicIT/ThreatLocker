function Get-ThreatLockerContext {
    <#
        .SYNOPSIS
            Allows the user to retrieve the ThreatLockerContext object created when using Connect-ThreatLocker
        .EXAMPLE
            $ThreatLockerContext = Get-ThreatLockerContext
    #>
    [CmdletBinding()]
    [OutputType('ThreatLockerContext')]
    param ()
    process {
        if (-not $Script:ThreatLockerContext) {
            Write-Error 'ThreatLockerContext object not found. Try connecting with "Connect-ThreatLocker" first.'
        }
        return $Script:ThreatLockerContext
    }
}
