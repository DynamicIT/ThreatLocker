@{
    Manifest = $null
    ImportFrom = @("Classes", "Enums", "Public", "Private")
    CertificatePath = $null
    TimestampServer = 'http://timestamp.sectigo.com'
    MergeWithScripts = @(".\Scripts\*.ps1")
    RemoveScriptsToProcess = $true
}
