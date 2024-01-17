function Connect-ThreatLocker {
    <#
        .SYNOPSIS
            Sets up the ThreatLockerContext object which will save the connection details for other functions.
        .DESCRIPTION
            The returned ThreatLocker object will also be stored in the module's ThreatLockerContext variable. This
            allows it to be used by other functions in this module.
        .EXAMPLE
            Connect-ThreatLocker

            Prompts for access token interactively and uses the default URI.
        .EXAMPLE
            Connect-ThreatLocker -BaseUri "https://betaportalapi.a.threatlocker.com" -AccessToken $secureAccessToken

            Connects to a custom URI using saved access token.
    #>
    [CmdletBinding()]
    [OutputType([System.Void])]
    param (
        # REST server base URI.
        [ValidatePattern('/$')]
        [Uri]
        $BaseUri = "https://portalapi.g.threatlocker.com/portalApi/",

        # Leave this blank to prompt interactively
        [Security.SecureString]
        $AccessToken
    )

    process {
        if (-not $AccessToken) {
            if ((Get-Clipboard) -match '^[a-f0-9]{64}') {
                Write-Host "Using access token in clipboard"
                $AccessToken = Get-Clipboard | ConvertTo-SecureString -AsPlainText -Force
            } else {
                $javascript = "copy(('; ' + document.cookie).split('; ThreatLockerAuthorization=').pop().split(';')[0])"
                $prompt = "`nPaste into console on ${BaseUri}: `n$javascript`n`nAccessToken"
                Set-Clipboard $javascript
                $AccessToken = Read-Host -AsSecureString -Prompt $prompt
            }
        }
        $Script:ThreatLockerContext = [ThreatLockerContext]@{
            BaseUri = $BaseUri
            Session = New-Object Microsoft.PowerShell.Commands.WebRequestSession
            AccessToken = $AccessToken
        }
        if ($Script:ThreatLockerContext.AccessTokenPlain() -notmatch '^[a-f0-9]{64}') {
            Write-Warning 'Possible issue with access token - not matching expected length.'
        }
    }
}
