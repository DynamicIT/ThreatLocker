function Connect-ThreatLocker {
    <#
        .SYNOPSIS
            Sets up the ThreatLockerContext object which will save the connection details for other functions.
        .DESCRIPTION
            The connection context will be stored in the module's ThreatLockerContext variable. This allows it to be
            used by other functions in this module. It can be retrieved by the user with Get-ThreatLockerContext.
        .EXAMPLE
            Connect-ThreatLocker -AccessToken (Read-Host -AsSecureString -Prompt "Token")

            Connects to default instance (g) and prompts for an access token or api key.
        .EXAMPLE
            Connect-ThreatLocker -BaseUri "https://betaportalapi.a.threatlocker.com" -AccessToken $secureAccessToken

            Connects to a custom URI using a pre-saved for an access token or api key.
        .EXAMPLE
            Connect-ThreatLocker -Instance 'a'

            Authenticate with username & password + MFA against instance 'a'.
        .EXAMPLE
            Connect-ThreatLocker -UseBrowser

            Prompts for with instructions to retrieve an access token from the client's browser. Required for SSO.
    #>
    [CmdletBinding(DefaultParameterSetName="Instance-UsernameAndPassword")]
    [OutputType([System.Void])]
    param (
        # ThreatLocker Portal's instance name/letter.
        [Parameter(ParameterSetName="Instance-UseBrowser")]
        [Parameter(ParameterSetName="Instance-UsernameAndPassword")]
        [Parameter(ParameterSetName="Instance-AccessToken")]
        [String]
        $Instance = "g",

        # Full portal API URI, including base path. Useful for working with a custom URI like https://betaportalapi.*
        [Parameter(ParameterSetName="BaseUri-UseBrowser", Mandatory)]
        [Parameter(ParameterSetName="BaseUri-UsernameAndPassword", Mandatory)]
        [Parameter(ParameterSetName="BaseUri-AccessToken", Mandatory)]
        [Uri]
        $BaseUri = "https://portalapi.$Instance.threatlocker.com/portalApi/",

        # When using SSO, it's not possible to authenticate directly in PowerShell. Use this to prompt with
        # instructions to extract a valid token from the browser's cookie store.
        [Parameter(ParameterSetName="Instance-UseBrowser", Mandatory)]
        [Parameter(ParameterSetName="BaseUri-UseBrowser", Mandatory)]
        [Alias('SSO')]
        [Switch]
        $UseBrowser,

        # Provide a credential object with the username and password for username+password authentication.
        [Parameter(ParameterSetName="Instance-UsernameAndPassword")]
        [Parameter(ParameterSetName="BaseUri-UsernameAndPassword")]
        [PSCredential]
        $Credential,

        # Inactivity timeout in minutes. Only used when requesting an access token with username & password auth.
        [Parameter(ParameterSetName="Instance-UsernameAndPassword")]
        [Parameter(ParameterSetName="BaseUri-UsernameAndPassword")]
        [Int]
        $InactivityTimeout = 240,

        # Provide an auth token to access ThreatLocker. It should be either:
        #   1. a static API key generated for a ThreatLocker "API User"; or
        #   2. a short-term access token saved from an interactive user authentication (e.g. same type from -UseBrowser)
        [Parameter(ParameterSetName="Instance-AccessToken", Mandatory)]
        [Parameter(ParameterSetName="BaseUri-AccessToken", Mandatory)]
        [Security.SecureString]
        $AccessToken
    )

    process {
        $ctx = [ThreatLockerContext]@{
            BaseUri = $BaseUri
            Session = New-Object Microsoft.PowerShell.Commands.WebRequestSession
        }

        if ($PSCmdlet.ParameterSetName -like '*-AccessToken') {
            $ctx.AccessToken = $AccessToken

        } elseif ($PSCmdlet.ParameterSetName -like '*-UseBrowser') {
            if ((Get-Clipboard) -match '^[a-f0-9]{64}') {
                Write-Host "Using access token found in clipboard"
                $ctx.AccessToken = Get-Clipboard | ConvertTo-SecureString -AsPlainText -Force
            } else {
                $javascript = "copy(('; ' + document.cookie).split('; ThreatLockerAuthorization=').pop().split(';')[0])"
                $prompt = "`nPaste into console on ${BaseUri}: `n$javascript`n`nAccessToken"
                Set-Clipboard $javascript
                $ctx.AccessToken = Read-Host -AsSecureString -Prompt $prompt
            }

        } elseif ($PSCmdlet.ParameterSetName -like '*-UsernameAndPassword') {
            if (-not $Credential) {
                $Credential = Get-Credential -Message "ThreatLocker account details. Username 'api' for API users."
            }
            if ($Credential.UserName -eq 'api') {
                $ctx.AccessToken = $Credential.Password
            } else {
                $utf8 = [System.Text.Encoding]::UTF8
                $authTokenInsertSplat = @{
                    Method = 'POST'
                    Uri = $ctx.FullUri('AuthToken/AuthTokenInsert')
                    ContentType = "application/json"
                    Body = ConvertTo-Json -Compress -InputObject @{
                        timeout = $InactivityTimeout
                        username = $Credential.UserName
                        password = [Convert]::ToBase64String($utf8.GetBytes($Credential.GetNetworkCredential().Password))
                    }
                }
                $authTokenInsert = Invoke-RestMethod @authTokenInsertSplat
                [ValidatePattern('^\d{6}$')]$mfaCode = Read-Host -Prompt 'Provide MFA Code'
                $authTokenInsert.mfacode = $mfaCode
                $authTokenVerifyCodeSplat = @{
                    Method = 'POST'
                    Uri = $ctx.FullUri('AuthToken/AuthTokenVerifyCode')
                    ContentType = "application/json"
                    Body = ConvertTo-Json -Compress -InputObject $authTokenInsert
                }
                $authTokenVerifyCode = Invoke-RestMethod @authTokenVerifyCodeSplat
                $ctx.AccessToken = ConvertTo-SecureString -AsPlainText -Force $authTokenVerifyCode.authTokenId
            }
        } else {
            Write-Error "Unexpected ParameterSet: '$( $PsCmdlet.ParameterSetName )'"
        }

        $Script:ThreatLockerContext = $ctx

        if ($ctx.AccessTokenPlain() -notmatch '^[a-f0-9]{64}$') {
            Write-Warning 'Possible issue with access token - not matching expected length or format.'
        }
    }
}
