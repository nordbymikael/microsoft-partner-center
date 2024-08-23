Import-Module "$($env:USERPROFILE)\private-repositories\microsoft-partner-center\CustomMicrosoftPartnerCenter\CustomMicrosoftPartnerCenter.psm1"
Remove-Module CustomMicrosoftPartnerCenter
$accessToken = New-CMPCAccessToken -tenantId "72465188-6db8-4510-ba33-40392d5db724" -clientId "56fe70e2-69c1-41a3-80b9-66912b0a4a76" -clientSecret "GZk8Q~RaZvYbdQLUfaejuqE40vQc8aODbi7qwcvh"
