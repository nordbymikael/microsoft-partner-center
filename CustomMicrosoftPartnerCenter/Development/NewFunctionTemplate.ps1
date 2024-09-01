function Verb-Object {
    #REQUIRES -Version 4.0
    #REQUIRES -Modules Microsoft.PowerShell.Utility

    <#
    .SYNOPSIS
    Easy description of the function

    .DESCRIPTION
    Advanced description of the function

    .PARAMETER parametername
    Description of the parameter

    .PARAMETER parametername
    Description of the parameter

    .PARAMETER parametername
    Description of the parameter

    .PARAMETER parametername
    Description of the parameter

    .INPUTS
    Inputs of the function

    .OUTPUTS
    Outputs of the function

    .LINK
    Online version: url

    .NOTES
    Advanced explanation of the code flow

    .EXAMPLE
    Cmdlet -parameter "parameter"
    Text

    .EXAMPLE
    Cmdlet -parameter "parameter"
    Text
    #>
    
    [CmdletBinding(
        ConfirmImpact = "High",
        DefaultParameterSetName = "ParameterSetName",
        HelpUri = "https://github.com/nordbymikael/microsoft-partner-center#verb-object",
        SupportsPaging = $false,
        SupportsShouldProcess = $true,
        PositionalBinding = $true
    )]
    
    param (
        [Parameter(Mandatory = $true, ParameterSetName = "ParameterSetName", ValueFromPipeline = $true)]
        [Parameter(Mandatory = $true, ParameterSetName = "ParameterSetName", ValueFromPipeline = $true)]
        [ValidatePattern('^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}-[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$')]
        [ValidateScript({
            Confirm-AdminRelationshipExistence -AdminRelationshipId $_
        })]
        [System.String]$adminRelationshipId,

        [Parameter(Mandatory = $true, ParameterSetName = "ParameterSetName")]
        [ValidatePattern("^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$")]
        [ValidateScript({
            
        })]
        [System.String]$GuidFormat
    )
    
    begin
    {
        Confirm-AccessTokenExistence
    }

    process
    {
        
    }

    end
    {

    }
}
