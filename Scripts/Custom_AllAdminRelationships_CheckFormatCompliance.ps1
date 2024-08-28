[System.String]$tenantId = ""
[System.String]$clientId = ""
[System.String]$clientSecret = ""



####################################################################################################
# Define the variables above and run the script
####################################################################################################

Import-Module CustomMicrosoftPartnerCenter
Connect-CMPC -tenantId $tenantId -clientId $clientId -clientSecret $clientSecret



Disconnect-CMPC
