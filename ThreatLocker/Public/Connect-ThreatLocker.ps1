function Connect-ThreatLocker {
    <#
        .SYNOPSIS
            Sets up the ThreatLockerContext object which will save the connection details for other functions.
        .DESCRIPTION
            The connection context will be stored in the module's ThreatLockerContext variable. This allows it to be
            used by other functions in this module. It can be retrieved by the user with Get-ThreatLockerContext.
        .EXAMPLE
            Connect-ThreatLocker

            Prompts for access token with instructions to retrieve from a browser.
        .EXAMPLE
            Connect-ThreatLocker -BaseUri "https://betaportalapi.a.threatlocker.com" -AccessToken $secureAccessToken

            Connects to a custom URI using saved access token.
    #>
    [CmdletBinding(DefaultParameterSetName="InstanceName")]
    [OutputType([System.Void])]
    param (
        # ThreatLocker Portal's instance name/letter.
        [Parameter(ParameterSetName="InstanceName")]
        [String]
        $Instance = "g",

        # Full portal API URI, including base path. Useful for working with a custom URI like https://betaportalapi.*
        [Parameter(ParameterSetName="CustomBaseUri")]
        [Uri]
        $BaseUri = "https://portalapi.$Instance.threatlocker.com/portalApi/",

        # Authentication token used to access ThreatLocker. When this is left blank, it will prompt interactively
        # with instructions to extract from the browser. This is the only way to get a token if you're using SSO.
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
