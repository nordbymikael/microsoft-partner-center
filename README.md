# Documentation

## Good to know about granular delegated admin relationships (GDAP)

### General
- A "GDAP relationship" is also known as an "admin relationship".
- A partner customer is a customer with whom a reseller relationship has been established
- A delegated admin customer is a customer with whom an admin relationship has been established
- Therefore, a partner customer is not always a delegated admin customer, and a delegated admin customer is not always a partner customer

### About admin relationships
- For the creation of an admin relationship, only a displayname, duration and minimum one role is required
- Every admin relationship requires a unique name and it cannot exceed 50 characters and few special characters are supported
- The duration is in the ISO 8601 format and it must be a value between P1D and P2Y (or P720D) inclusive
- The auto extend duration is in the backend defined in the ISO 8601 format
- If the auto extend duration is specified, the admin relationship will be automatically renewed
- Supported valued for auto extend duration are P0D, PT0S and P180D
- The customer associated with an admin relationship can either be defined at the admin relationship creation, or automatically when the admin relationship is accepted by a customer

### About access assignments
- Usually, the user does not have any use for the access assignment ID because it is primarily used in the backend by Microsoft
- When an access assignment is created for a security group on an admin relationship, the access assignment ID will be generated with a random globally unique identifier (GUID)
- The historic entry of that specific access assignment will be uniquely identified by the access assignment ID

- The security group can only have one active access assignment at a time
- Therefore, the creation of a new access assignment on a security group will trigger a 409 error if an active access assignment on the same security group already exists
- To edit an active access assignment, use the Edit-CMPCAdminRelationshipAccessAssignment function in this module

### About requests
- A lockForApproval request is required for the relationship to be accepted
- Without a lockForApproval request, the relationship has the created status and can be modified, meanwhile only the auto extend duration and the presence of the Global Administrator role can be changed after the lockForApproval
- A request on an admin relationship is either related to a lockForApproval action or a termination action
- This module does automatically lock an admin relationship for approval when the admin relationship is created

### About operations
- An operation is often refered to as a long-running operation
- Operations include the removal of a Global Administrator role from an admin relationship

### About the API endpoints
- API requests for admin relationships and delegated admin customers are associated with the following Microsoft Graph API endpoint: https://graph.microsoft.com/v1.0/tenantRelationships
- The Graph API endpoint requires the "DelegatedAdminRelationship.ReadWrite.All" or "DelegatedAdminRelationship.Read.All" API permissions
- Microsoft uses a backend API endpoint associated with Azure Traffic Manager for GDAP: https://traf-pcsvcadmin-prod.trafficmanager.net/CustomerServiceAdminApi/Web/v1/granularAdminRelationships
- The Azure Traffic Manager endpoint requires the "PartnerCustomerDelegatedAdministration.ReadWrite.All" or "PartnerCustomerDelegatedAdministration.Read.All" API permissions
- The API requests for the Graph API endpoint has a limited response amount to 300 responses, and the @odata.nextLink can be used to get the next 300 responses
- $top og $expand are not supported on the https://graph.microsoft.com/v1.0/tenantRelationships endpoint, only $select is supported because it is default for the Graph API

## Preparation

### Dependencies on other modules
The module has no dependencies on other Powershell modules, and the functions' functionality is based on Graph API.

### Access token and API permissions
To use the module, you will use the Connect-CMPC function to obtain an access token which will be used by the other functions.
The authorization will be fully managed by the backend of the module.
The module requires the "DelegatedAdminRelationship.ReadWrite.All" API permission in the access token to function.

Follow the steps below to create an app registration with the correct API permissions and a client secret to authenticate:
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
In the module source files, navigate to the "...\CustomMicrosoftPartnerCenter\Configuration" folder.
Here you will find a configuration template Configuration.ps1 that is meant to be a template for a proper admin relationship infrastructire.
If you are planning on implementing admin relationships in an organization, use this template to standarize the admin relationships.

#### Authentication
In the Configuration.ps1 file, you can save the values for your Tenant ID, Client ID and the Client secret in the variables.
You should know what values to put in the variables if you have followed the whole preparation process.
It is strongly recommended to use Azure Key Vault and return the values into the variables from Key Vault, rather than paste the values as plain text directly into the variables.
If you specify the variables in the Configuration.ps1 file, you won't need to specify the Tenant ID, Client ID and the Client secret every time you use Connect-CMPC.
Alternatively, you can leave the variables in "Configuration.ps1" empty and provide all the associated parameters manually when you call the Connect-CMPC function.

#### Admin relationship configuration
In the Configuration.ps1, you can save values for your admin relationship configuration.
Some examples are the standard name of the admin relationship, the standard duration or lifetime of the admin relationship, as well as the auto extend duration.
If you specify the values for the variables, you won't need to specify the parameters each time you create a new admin relationship using the New-CMPCAdminRelationship function.
If you leave these variables empty, you have to specify them each time using the associated function parameters when you call the New-CMPCAdminRelationship.ps1 function.

#### Standarization of the admin relationship structure
The $CMPC_GDAPAccess variable in the Configuration.ps1 file is a JSON object which contains all the built-in Entra roles that can be associated with admin relationships.
If you specify any security groups 
Note that not all Entra built-in roles in the Microsoft's list of RBAC roles can be associated with admin relationships, and some roles may have limitations.
Some important limitations to consider are that roles granting access to Business Applications (Power BI, Power Platform and Dynamics 365) and SharePoint, might not work properly because these capabilities are still experimental in Microsoft Partner Center.
In addition, if you choose to include the Global Administrator role in the admin relationship, you will not be able to enable auto extention for the relationship.

## How to use the module

### Import the module
Specify the full file path to the CustomMicrosoftPartnerCenter.psm1 file when importing the module, as shown in the command below.
Import-Module -FullyQualifiedName "...\CustomMicrosoftPartnerCenter.psm1"

### function documentation

Not yet created online version

#### function
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

#### function
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

#### function
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

#### function
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

#### function
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

#### function
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

#### function
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

#### function
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

#### function
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
If any function fails, it terminates the script execution and provides an explanation of the failure, as well as the generic Powershell exception message.

## References 

### Granular delegated admin privileges (GDAP) API overview
https://learn.microsoft.com/en-us/graph/api/resources/delegatedadminrelationships-api-overview?view=graph-rest-1.0

### Microsoft Entra built-in roles
https://learn.microsoft.com/en-us/entra/identity/role-based-access-control/permissions-reference

### Partner Center developer documentation
*Note that this module's latest version is from 2020, and it does therefore not provide admin relationship functionality because GDAP did not exist at that time.*
https://learn.microsoft.com/en-us/partner-center/developer/

### Partner Center Powershell module (community)
*Note that this module's latest version is from 2020, and it does therefore not provide admin relationship functionality because GDAP did not exist at that time.*
https://learn.microsoft.com/en-us/powershell/partnercenter/overview?view=partnercenterps-3.0
https://www.powershellgallery.com/packages/PartnerCenter/3.0.10
https://github.com/microsoft/Partner-Center-PowerShell

## Patch notes

### version 0.8.0
Release date: 01.09.2024 (dd.mm.yyyy)
Release name: Early beta test
Release notes:
- The module was rewritten from scratch to remove the company's ownership of the SDK product
- The module is now for both personal and corporative use, but all organizations are allowed to use this module
- Note that the module is still copyright
- The module now provides customization options using module variables
- Rework of the authentication process, which removed the dependency on the Microsoft Authentication Library (MSAL.PS) module
- Added new functions for GDAP removal, GDAP access assignment removal and to retrieve all customers in Microsoft Partner Center without the need of any additional Powershell modules and backend API endpoints
- Added new functions for management of admin customers (partner customers with at least one associated admin relationship that has the active status)
- A new documentation for the updated module was written
- Powershell best practises were applied to generate the m

### version 0.7.0
Release date: 01.03.2024 (dd.mm.yyyy)
Release name: First prerelease
Release notes:
- The module was released for the first time and was designed specifically for an IT company for GDAP administration purposes, with a standarized naming policy control and strict quality checks.
