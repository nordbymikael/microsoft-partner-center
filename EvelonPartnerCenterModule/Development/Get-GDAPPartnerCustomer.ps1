function Get-GDAPPartnerCustomer {
    param (
        [Parameter(Mandatory = $true)] [string]$accessToken,
        [Parameter(Mandatory = $false)] [string]$tenantId = "NotDefined",
        [Parameter(Mandatory = $false)] [string]$tenantName = "NotDefined",
        [Parameter(Mandatory = $false)] [string]$domain = "NotDefined",
        [Parameter(Mandatory = $false)] [switch]$exportAsJSON,
        [Parameter(Mandatory = $false)] [switch]$exportAsCSV,
        [Parameter(Mandatory = $false)] [string]$csvDelimiter = ";",
        [Parameter(Mandatory = $false)] [string]$exportPath = "NotDefined",
        [Parameter(Mandatory = $false)] [string]$totalResults = 10000
    )
    
    <#if ((Convert-JWTToken -accessToken $accessToken) -ne "Success")
    {
        Write-Verbose -Message "The access token has insufficient permissions."
        Write-Error -Message "The access token has insufficient permissions."
        return
    }#>
    
    if ($exportPath -eq "")
    {
        Write-Verbose -Message "The export path cannot be an empty string."
        Write-Error -Message "The export path cannot be an empty string."
        return
    }

    if ((Export-PreCheck -exportPath $exportPath -exportAsJSON $exportAsJSON -exportAsCSV $exportAsCSV) -ne "Success")
    {
        Write-Verbose -Message "Something went wrong while checking the validity of the export parameters."
        Write-Error -Message "Something went wrong while checking the validity of the export parameters."
        return
    }

    Write-Verbose -Message "Defining the header variable."

    $headers = @{
        Authorization = "Bearer $($accessToken)"
        <#
        Required to retrieve a result in Postman:
        Host = <calculated when request is sent>
        #>
    }

    try {
        Write-Verbose -Message "Retrieving all customers information."
        $allPartnerCustomers = Invoke-RestMethod -Uri "https://api.partnercenter.microsoft.com/v1/customers?size=$($totalResults)" -Method "Get" -Headers $headers -ErrorAction "Stop"

        if ($tenantId -ne "NotDefined")
        {
            if ($allPartnerCustomers.PSObject.Properties.Value.id -contains $tenantId)
            {
                Write-Verbose -Message "Returning customer information on Tenant Id `"$($tenantId)`"."
                $selectedObject = ($allPartnerCustomers.items | Where-Object id -eq $tenantId)
            }
            else
            {
                Write-Verbose -Message "The specified tenant does not belong to any customer."
                Write-Error -Message "The specified tenant does not belong to any customer."
                return
            }
        }
        elseif ($tenantName -ne "NotDefined")
        {
            if ($allPartnerCustomers.PSObject.Properties.Value.companyProfile.companyName -contains $tenantName)
            {
                Write-Verbose -Message "Returning customer information on Tenant name `"$($tenantName)`"."
                $selectedObject = ($allPartnerCustomers.items.companyProfile | Where-Object companyName -eq $tenantName)
                $selectedObject = $allPartnerCustomers.items | Where-Object id -eq $selectedObject.tenantId
            }
            else
            {
                Write-Verbose -Message "The specified Tenant name does not belong to any customer."
                Write-Error -Message "The specified Tenant name does not belong to any customer."
                return
            }
        }
        elseif ($domain -ne "NotDefined")
        {
            if ($allPartnerCustomers.PSObject.Properties.Value.companyProfile.domain -contains $domain)
            {
                Write-Verbose -Message "Returning customer information on domain `"$($domain)`"."
                $selectedObject = ($allPartnerCustomers.items.companyProfile | Where-Object domain -eq $tenantName)
                $selectedObject = $allPartnerCustomers.items | Where-Object id -eq $selectedObject.tenantId
            }
            else
            {
                Write-Verbose -Message "The specified domain does not belong to any customer."
                Write-Error -Message "The specified domain does not belong to any customer."
                return
            }
        }
        else {
            Write-Verbose "No parameters specified. Returning every customer."
            $selectedObject = $allPartnerCustomers
        }
    }
    catch {
        # Recommended to retrieve Access Token directly from the "Network" tab in the browser, because I still did not figure out how to retrieve an access token for https://api.partnercenter.microsoft.com/
        Write-Verbose -Message "Something went wrong while trying to retrieve customer information. The access token is most likely invalid for managing https://api.partnercenter.microsoft.com/."
        Write-Error -Message "Something went wrong while trying to retrieve customer information. The access token is most likely invalid for managing https://api.partnercenter.microsoft.com/."
        return
    }

    try {
        Export-Result -objectToExport $selectedObject -exportPath $exportPath -csvDelimiter $csvDelimiter -exportAsJSON $exportAsJSON -exportAsCSV $exportAsCSV -ErrorAction "Stop"
    }
    catch {
        Write-Verbose -Message "Something went wrong while exporting the result."
        Write-Error -Message "Something went wrong while exporting the result."
        return $selectedObject
    }

    return $selectedObject
}
