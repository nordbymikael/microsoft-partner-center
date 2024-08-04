# Documentation

## Preparation

### Dependencies on other modules
The module has no dependencies on other PowerShell modules, and the cmdlets are based on REST APIs provided by Microsoft.

### Access token and API permissions
To use the module, you will use the New-CMPCAccessToken cmdlet to obtain an access token which will be used by the other cmdlets.
The module requires the "DelegatedAdminRelationship.ReadWrite.All" API permission in the access token to function.
The New-CMPCAccessToken cmdlet also uses a client secret to authenticate.

Follow the steps below to create an app registration with the correct API permissions and the client secret:
1. Sign in to Entra admin center at least as an Application Administrator
2. Browse to "Identity -> Applications -> App registrations"
3. Click on "New registration" and provide the following information
Name = Give the app registration an appropriate name
Supported account types = Accounts in this organizational directory only ({tenant name} only - Single tenant)
4. Click on "Register" to create the app registration
5. Open the new app registration if it was not automatically opened, and browse to "Overview"
Note the "Application (client) ID"
Note the "Directory (tenant) ID"
6. Browse to "Manage -> Certificates & secrets -> Client secrets"
7. Click on "New client secret" and provide an appropriate description and a desired expiration period
8. Click on "Add" to create the client secret
Note the "Value" next to the secret, it won't appear in the portal again
9. Browse to "Manage -> API permissions"
10. Click on "Add a permission" and select the "Microsoft Graph" API under "Microsoft APIs"
11. Choose "Application permissions" and choose the "DelegatedAdminRelationship.ReadWrite.All" API permission
12. Click in "Add permissions" to select the API permission
13. After clicking on "Add permissions" in the previous step, remain on the same window and click on "Grant admin consent for {tenant name}"

### [Optional] Module variables
In the module source files, navigate to the "...\CustomMicrosoftPartnerCenter\Variables" folder.

#### Authentication
In the authentication.ps1 file, you can save the values for your Tenant ID, Client ID and the Client secret in the variables.
You should know what values to put in the variables if you have followed the whole preparation process.
It is strongly recommended to use Azure Key Vault and return the values into the variables from Key Vault, rather than paste the values as plain text directly into the variables.
If you specify the variables in the authentication.ps1 file, you won't need to specify the Tenant ID, Client ID and the Client secret every time you obtain a new access token.
Alternatively, you can leave the variables in "authentication.ps1" empty and provide all the associated parameters manually when you call the New-CMPCAccessToken cmdlet.

#### Admin relationship configuration
In the adminRelationship.ps1, you can save values for your admin relationship configuration.
Some examples are the standard name of the admin relationship, the standard duration or lifetime of the admin relationship, as well as the auto extend duration.
If you specify the values for the variables, you won't need to specify the parameters each time you create a new admin relationship using the New-CMPCAdminRelationship cmdlet.
If you leave these variables empty, you have to specify them each time using the associated cmdlet paramenters when you call the New-CMPCAdminRelationship.ps1 cmdlet.

#### Standarization of the admin relationship structure
The $CMPC_GDAPAccess variable in the adminRelationship.ps1 file is a JSON object which contains all the built-in Entra roles that can be associated with admin relationships.
If you specify any security groups 
Note that not all Entra built-in roles in the Microsoft's list of RBAC roles can be associated with admin relationships, and some roles may have limitations.
Some important limitations to consider are that roles granting access to Business Applications (Power BI, Power Platform and Dynamics 365) and SharePoint, might not work properly because these capabilities are still experimental in Microsoft Partner Center.
In addition, if you choose to include the Global Administrator role in the admin relationship, you will not be able to enable auto extention for the relationship.

## How to use the module

### Import the module
Specify the full file path to the CustomMicrosoftPartnerCenter.psm1 file when importing the module, as shown in the command below.
Import-Module -FullyQualifiedName "...\CustomMicrosoftPartnerCenter.psm1"

### Cmdlet documentation

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
# In the "...\CustomMicrosoftPartnerCenter\Variables\authentication.ps1" file, specify the correct values for the variables
$accessToken = New-CMPCAccessToken
```
*Response: A JSON Web Token (JWT) as a string*

#### Get-CMPCAdminRelationship
Description: Returns a PowerShell object with either only the general admin relationship info, or all admin relationship info (the general admin relationship info, access assignments info, operations info and requests info). Choose between returning info about only one specific relationship or all the existing relationships.

Parameters:
- **accessToken** [String] [*Mandatory*] (retrieve the access token by using the New-CMPCAccessToken cmdlet, and provide it as a parameter for authorization purposes)
- **adminRelationshipId** [String] [*Optional*] (provide the admin relationship ID to return information about only one specific admin relationship, or leave the parameter empty to return information about all the existing admin relationships)
- **extendedInformation** [Switch] [*Optional*] (you can choose to include all info by activating the switch, or include only the general info by not specifying the switch (if you retrieve extended information about all the existing admin relationships, the time to complete the command may be significant))

Example 1: Retrieve extended information about only one specific admin relationship
```powershell
$accessToken = New-CMPCAccessToken -tenantId "GUID" -clientId "GUID" -clientSecret "GUID"
$adminRelationship = Get-CMPCAdminRelationship -accessToken $accessToken -adminRelationshipId "GUID-GUID" -extendedInformation
```
*Response: A PowerShell object with the following format*
```powershell
$adminRelationship = @{
    "@" = ... # A PowerShell object with general info
    AccessAssignments = ... # A PowerShell object with access assignments info
    Operations = ... # A PowerShell object with operations info
    Requests = ... # A PowerShell object with requests info
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
        "@" = ... # A PowerShell object with general info of one admin relationship
        AccessAssignments = ... # A PowerShell object with access assignments info of one admin relationship
        Operations = ... # A PowerShell object with operations info of one admin relationship
        Requests = ... # A PowerShell object with requests info of one admin relationship
    },
    @{
        "@" = ... # A PowerShell object with general info of another admin relationship
        AccessAssignments = ... # A PowerShell object with access assignments info of another admin relationship
        Operations = ... # A PowerShell object with operations info of another admin relationship
        Requests = ... # A PowerShell object with requests info of another admin relationship
    },
    ...
)
```

#### Cmdlet
Description: 

Parameters:
- **** [] [*Optional / Mandatory*] ()
- **** [] [*Optional / Mandatory*] ()
- **** [] [*Optional / Mandatory*] ()

Example 1: 
```powershell
some code
```

Example 2: 
```powershell
some code
```

Response: 

#### Cmdlet
Description: 

Parameters:
- **** [] [*Optional / Mandatory*] ()
- **** [] [*Optional / Mandatory*] ()
- **** [] [*Optional / Mandatory*] ()

Example 1: 
```powershell
some code
```

Example 2: 
```powershell
some code
```

Response: 

#### Cmdlet
Description: 

Parameters:
- **** [] [*Optional / Mandatory*] ()
- **** [] [*Optional / Mandatory*] ()
- **** [] [*Optional / Mandatory*] ()

Example 1: 
```powershell
some code
```

Example 2: 
```powershell
some code
```

Response: 

#### Cmdlet
Description: 

Parameters:
- **** [] [*Optional / Mandatory*] ()
- **** [] [*Optional / Mandatory*] ()
- **** [] [*Optional / Mandatory*] ()

Example 1: 
```powershell
some code
```

Example 2: 
```powershell
some code
```

Response: 

#### Cmdlet
Description: 

Parameters:
- **** [] [*Optional / Mandatory*] ()
- **** [] [*Optional / Mandatory*] ()
- **** [] [*Optional / Mandatory*] ()

Example 1: 
```powershell
some code
```

Example 2: 
```powershell
some code
```

Response: 

#### Cmdlet
Description: 

Parameters:
- **** [] [*Optional / Mandatory*] ()
- **** [] [*Optional / Mandatory*] ()
- **** [] [*Optional / Mandatory*] ()

Example 1: 
```powershell
some code
```

Example 2: 
```powershell
some code
```

Response: 

#### Cmdlet
Description: 

Parameters:
- **** [] [*Optional / Mandatory*] ()
- **** [] [*Optional / Mandatory*] ()
- **** [] [*Optional / Mandatory*] ()

Example 1: 
```powershell
some code
```

Example 2: 
```powershell
some code
```

Response: 

#### Cmdlet
Description: 

Parameters:
- **** [] [*Optional / Mandatory*] ()
- **** [] [*Optional / Mandatory*] ()
- **** [] [*Optional / Mandatory*] ()

Example 1: 
```powershell
some code
```

Example 2: 
```powershell
some code
```

Response: 

#### Cmdlet
Description: 

Parameters:
- **** [] [*Optional / Mandatory*] ()
- **** [] [*Optional / Mandatory*] ()
- **** [] [*Optional / Mandatory*] ()

Example 1: 
```powershell
some code
```

Example 2: 
```powershell
some code
```

Response: 

### Debugging
If any cmdlet fails, it terminates the script execution and provides an explanation of the failure, as well as the generic PowerShell exception message.

## References 

### Granular delegated admin privileges (GDAP) API overview
https://learn.microsoft.com/en-us/graph/api/resources/delegatedadminrelationships-api-overview?view=graph-rest-1.0

### Microsoft Entra built-in roles
https://learn.microsoft.com/en-us/entra/identity/role-based-access-control/permissions-reference

### Partner Center developer documentation
*Note that this module's latest version is from 2020, and it does therefore not provide admin relationship functionality because GDAP did not exist at that time.*
https://learn.microsoft.com/en-us/partner-center/developer/

### Partner Center PowerShell module (community)
*Note that this module's latest version is from 2020, and it does therefore not provide admin relationship functionality because GDAP did not exist at that time.*
https://learn.microsoft.com/en-us/powershell/partnercenter/overview?view=partnercenterps-3.0
https://www.powershellgallery.com/packages/PartnerCenter/3.0.10
https://github.com/microsoft/Partner-Center-PowerShell

## Patch notes

### version 2.0.0
Release date: 02.08.2024 (dd.mm.yyyy)
Release notes:
- The module was rewritten from scratch to remove the company's ownership of the product
- The module is now for both personal and corporative use, but all organizations require a formal consent from the module author to use the the module for any purposes
- The module now provides customization options using module variables
- Rework of the authentication process, which removed the dependency on the Microsoft Authentication Library (MSAL) module
- Added new cmdlets for GDAP removal, GDAP access assignment removal and to retrieve all customers in Microsoft Partner Center without the need of any additional PowerShell modules
- By reverse engineering, a new cmdlet to terminate accepted admin relationships was created (this capability is not yet provided by the Microsoft.Graph.Identity.Partner module)
- Added new cmdlets for management of admin customers (partner customers with at least one associated admin relationship that has the active status)
- A new documentation for the updated module was written

### version 1.0.0
Release date: 01.03.2024 (dd.mm.yyyy)
Release notes:
- The module was released for the first time and was designed specifically for an IT company for GDAP administration purposes, with strict naming policy control and strict quality checks.
