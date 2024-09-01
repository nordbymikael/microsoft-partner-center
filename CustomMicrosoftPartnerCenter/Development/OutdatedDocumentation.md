#### New-CMPCAccessToken
Description: Authenticates and returns an access token (Bearer token) using an app registration with a client secret. The token will contain all the admin consented API permissions on the app registration. Provide your own values using the attributes, or read the *Preparation* to understand how to provide standard values for the attributes by using the "...\CustomMicrosoftPartnerCenter\Variables\authentication.ps1" file.

Parameters:
- tenantId [String] [*Optional / Mandatory*] (provide the Tenant ID in which the app registration exists)
- clientId [String] [*Optional / Mandatory*] (provide the Client ID or Application ID associated with your app registration)
- clientSecret [String] [*Optional / Mandatory*] (provide the client secret associated with your app registration)

Example 1: Obtain an access token by using the attributes
```powershell
$accessToken = New-CMPCAccessToken -tenantId "GUID" -clientId "GUID" -clientSecret "GUID"
```
*Response: A JSON Web Token (JWT) as a string*

Example 2: Obtain an access token by preparing standard values for the attributes
```powershell
# In the "...\CustomMicrosoftPartnerCenter\Variables\Configuration.ps1" file, specify the correct values for the variables
$accessToken = New-CMPCAccessToken
```
*Response: A JSON Web Token (JWT) as a string*

#### Get-CMPCAdminRelationship
Description: Returns a Powershell object with either only the general admin relationship info, or all admin relationship info (the general admin relationship info, access assignments info, operations info and requests info). Choose between returning info about only one specific relationship or all the existing relationships.

Parameters:
- **accessToken** [String] [*Mandatory*] (retrieve the access token by using the New-CMPCAccessToken function, and provide it as a parameter for authorization purposes)
- **adminRelationshipId** [String] [*Optional*] (provide the admin relationship ID to return information about only one specific admin relationship, or leave the parameter empty to return information about all the existing admin relationships)
- **extendedInformation** [Switch] [*Optional*] (you can choose to include all info by activating the switch, or include only the general info by not specifying the switch (if you retrieve extended information about all the existing admin relationships, the time to complete the command may be significant))

Example 1: Retrieve extended information about only one specific admin relationship
```powershell
$accessToken = New-CMPCAccessToken -tenantId "GUID" -clientId "GUID" -clientSecret "GUID"
$adminRelationship = Get-CMPCAdminRelationship -accessToken $accessToken -adminRelationshipId "GUID-GUID" -extendedInformation
```
*Response: A Powershell object with the following format*
```powershell
$adminRelationship = @{
    "@" = ... # A Powershell object with general info
    AccessAssignments = ... # A Powershell object with access assignments info
    Operations = ... # A Powershell object with operations info
    Requests = ... # A Powershell object with requests info
}
```

Example 2: Retrieve extended information about all existing admin relationships
```powershell
$accessToken = New-CMPCAccessToken -tenantId "GUID" -clientId "GUID" -clientSecret "GUID"
$adminRelationship = Get-CMPCAdminRelationship -accessToken $accessToken -extendedInformation
```
*Response: An array with the following format*
```powershell
$adminRelationships = @(
    @{
        "@" = ... # A Powershell object with general info of one admin relationship
        AccessAssignments = ... # A Powershell object with access assignments info of one admin relationship
        Operations = ... # A Powershell object with operations info of one admin relationship
        Requests = ... # A Powershell object with requests info of one admin relationship
    },
    @{
        "@" = ... # A Powershell object with general info of another admin relationship
        AccessAssignments = ... # A Powershell object with access assignments info of another admin relationship
        Operations = ... # A Powershell object with operations info of another admin relationship
        Requests = ... # A Powershell object with requests info of another admin relationship
    },
    ...
)
```