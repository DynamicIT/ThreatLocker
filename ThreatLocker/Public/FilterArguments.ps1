function FilterArguments {
    <#
        .SYNOPSIS
            Helper function for argument completers. Filters pipeline input and outputs vald CompletionResult objects.
        .DESCRIPTION
            This function needs to be public for it to work :(
    #>
    param (
        [Parameter(Mandatory, Position = 1)]
        [AllowEmptyString()]
        [String]
        $WordToComplete,

        [Parameter(ValueFromPipeline)]
        [Object]
        $InputObject
    )
    begin {
        $WordToComplete = $WordToComplete.Trim("`"'")
        $parameterValue = [Management.Automation.CompletionResultType]::ParameterValue
    }
    process {
        if ($InputObject -like "$WordToComplete*") {
            [Management.Automation.CompletionResult]::new("'$InputObject'", $InputObject, $parameterValue, $InputObject)
        }
    }
}
