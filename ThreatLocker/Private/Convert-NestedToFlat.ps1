function Convert-NestedToFlat {
    param (
        # Name of property to recurse into
        [Parameter(Mandatory)]
        $Property,

        [Parameter(ValueFromPipeline)]
        [PSObject]
        $InputObject
    )
    process {
        $InputObject
        if ($Property -in $InputObject.PSObject.Properties.Name) {
            foreach ($child in $InputObject.$Property) {
                Convert-NestedToFlat -Property $Property -InputObject $child
            }
        }
    }
}
