# Provide your Microsoft Tenant ID
$CMPC_TenantId = ""

# Provide your Application ID (Client ID)
$CMPC_ClientId = ""

# Provide your Client secret
$CMPC_ClientSecret = ""

# Define your admin relationship name (all admin relationships must have unique names and cannot exceed 50 characters, for example: "ShortenedCompanyName_$(New-Guid)")
$CMPC_AdminRelationshipDisplayName = ""

# Define your admin relationship duration (maximum number is 730 days: "P730D")
$CMPC_AdminRelationshipDuration = ""

# Define your admin relationship auto extend duration (maximum number is 180 days: "P180D")
$CMPC_AdminRelationshipAutoExtendDuration = ""

$CMPC_AdminRelationshipUnifiedRoles = @"
[
{"roleDefinitionId": "62e90394-69f5-4237-9190-012177145e10", "roleDefinitionName": "Global Administrator", "securityGroupId": ""},
{"roleDefinitionId": "44367163-eba1-44c3-98af-f5787879f96a", "roleDefinitionName": "Dynamics 365 Administrator", "securityGroupId": ""},
{"roleDefinitionId": "29232cdf-9323-42fd-ade2-1d097af3e4de", "roleDefinitionName": "Exchange Administrator", "securityGroupId": ""},
{"roleDefinitionId": "31392ffb-586c-42d1-9346-e59415a2cc4e", "roleDefinitionName": "Exchange Recipient Administrator", "securityGroupId": ""},
{"roleDefinitionId": "45d8d3c5-c802-45c6-b32a-1d70b5e1e86e", "roleDefinitionName": "Identity Governance Administrator", "securityGroupId": ""},
{"roleDefinitionId": "b5a8dcf3-09d5-43a9-a639-8e29ef291470", "roleDefinitionName": "Knowledge Administrator", "securityGroupId": ""},
{"roleDefinitionId": "744ec460-397e-42ad-a462-8b3f9747a02c", "roleDefinitionName": "Knowledge Manager", "securityGroupId": ""},
{"roleDefinitionId": "32696413-001a-46ae-978c-ce0f6b3620d2", "roleDefinitionName": "Windows Update Deployment Administrator", "securityGroupId": ""},
{"roleDefinitionId": "892c5842-a9a6-463a-8041-72aa08ca3cf6", "roleDefinitionName": "Cloud App Security Administrator", "securityGroupId": ""},
{"roleDefinitionId": "fdd7a751-b60b-444a-984c-02652fe8fa1c", "roleDefinitionName": "Groups Administrator", "securityGroupId": ""},
{"roleDefinitionId": "a9ea8996-122f-4c74-9520-8edcd192826c", "roleDefinitionName": "Fabric Administrator", "securityGroupId": ""},
{"roleDefinitionId": "69091246-20e8-4a56-aa4d-066075b2a7a8", "roleDefinitionName": "Teams Administrator", "securityGroupId": ""},
{"roleDefinitionId": "3d762c5a-1b6c-493f-843e-55a3b42923d4", "roleDefinitionName": "Teams Devices Administrator", "securityGroupId": ""},
{"roleDefinitionId": "baf37b3a-610e-45da-9e62-d9d1e5e8914b", "roleDefinitionName": "Teams Communications Administrator", "securityGroupId": ""},
{"roleDefinitionId": "f70938a0-fc10-4177-9e90-2178f8765737", "roleDefinitionName": "Teams Communications Support Engineer", "securityGroupId": ""},
{"roleDefinitionId": "fcf91098-03e3-41a9-b5ba-6f0ec8188a12", "roleDefinitionName": "Teams Communications Support Specialist", "securityGroupId": ""},
{"roleDefinitionId": "75941009-915a-4869-abe7-691bff18279e", "roleDefinitionName": "Skype for Business Administrator", "securityGroupId": ""},
{"roleDefinitionId": "74ef975b-6605-40af-a5d2-b9539d836353", "roleDefinitionName": "Kaizala Administrator", "securityGroupId": ""},
{"roleDefinitionId": "eb1f4a8d-243a-41f0-9fbd-c7cdf6c5ef7c", "roleDefinitionName": "Insights Administrator", "securityGroupId": ""},
{"roleDefinitionId": "31e939ad-9672-4796-9c2e-873181342d2d", "roleDefinitionName": "Insights Business Leader", "securityGroupId": ""},
{"roleDefinitionId": "d37c8bed-0711-4417-ba38-b4abe66ce4c2", "roleDefinitionName": "Network Administrator", "securityGroupId": ""},
{"roleDefinitionId": "2b745bdf-0803-4d80-aa65-822c4493daac", "roleDefinitionName": "Office Apps Administrator", "securityGroupId": ""},
{"roleDefinitionId": "11648597-926c-4cf3-9c36-bcebb0ba8dcc", "roleDefinitionName": "Power Platform Administrator", "securityGroupId": ""},
{"roleDefinitionId": "0964bb5e-9bdb-4d7b-ac29-58e794862a40", "roleDefinitionName": "Search Administrator", "securityGroupId": ""},
{"roleDefinitionId": "8835291a-918c-4fd7-a9ce-faa49f0cf7d9", "roleDefinitionName": "Search Editor", "securityGroupId": ""},
{"roleDefinitionId": "f28a1f50-f6e7-4571-818b-6a12f2af6b6c", "roleDefinitionName": "SharePoint Administrator", "securityGroupId": ""},
{"roleDefinitionId": "e3973bdf-4987-49ae-837a-ba8e231c7286", "roleDefinitionName": "Azure DevOps Administrator", "securityGroupId": ""},
{"roleDefinitionId": "6e591065-9bad-43ed-90f3-e9424366d2f0", "roleDefinitionName": "External ID User Flow Administrator", "securityGroupId": ""},
{"roleDefinitionId": "0f971eea-41eb-4569-a71e-57bb8a3eff1e", "roleDefinitionName": "External ID User Flow Attribute Administrator", "securityGroupId": ""},
{"roleDefinitionId": "3a2c62db-5318-420d-8d74-23affee5d9d5", "roleDefinitionName": "Intune Administrator", "securityGroupId": ""},
{"roleDefinitionId": "7698a772-787b-4ac8-901f-60d6b08affd2", "roleDefinitionName": "Cloud Device Administrator", "securityGroupId": ""},
{"roleDefinitionId": "38a96431-2bdf-4b4c-8b6e-5d3d8abac1a4", "roleDefinitionName": "Desktop Analytics Administrator", "securityGroupId": ""},
{"roleDefinitionId": "644ef478-e28f-4e28-b9dc-3fdde9aa0b1f", "roleDefinitionName": "Printer Administrator", "securityGroupId": ""},
{"roleDefinitionId": "e8cef6f1-e4bd-4ea8-bc07-4b8d950f4477", "roleDefinitionName": "Printer Technician", "securityGroupId": ""},
{"roleDefinitionId": "9f06204d-73c1-4d4c-880a-6edb90606fd8", "roleDefinitionName": "Microsoft Entra Joined Device Local Administrator", "securityGroupId": ""},
{"roleDefinitionId": "11451d60-acb2-45eb-a7d6-43d0f0125c13", "roleDefinitionName": "Windows 365 Administrator", "securityGroupId": ""},
{"roleDefinitionId": "c4e39bd9-1100-46d3-8c65-fb160da0071f", "roleDefinitionName": "Authentication Administrator", "securityGroupId": ""},
{"roleDefinitionId": "b1be1c3e-b65d-4f19-8427-f6fa0d97feb9", "roleDefinitionName": "Conditional Access Administrator", "securityGroupId": ""},
{"roleDefinitionId": "729827e3-9c14-49f7-bb1b-9608f156bbb8", "roleDefinitionName": "Helpdesk Administrator", "securityGroupId": ""},
{"roleDefinitionId": "4d6ac14f-3453-41d0-bef9-a3e0c569773a", "roleDefinitionName": "License Administrator", "securityGroupId": ""},
{"roleDefinitionId": "966707d0-3269-4727-9be2-8c3a10f19b9d", "roleDefinitionName": "Password Administrator", "securityGroupId": ""},
{"roleDefinitionId": "7be44c8a-adaf-4e2a-84d6-ab2649e08a13", "roleDefinitionName": "Privileged Authentication Administrator", "securityGroupId": ""},
{"roleDefinitionId": "e8611ab8-c189-46e8-94e1-60213ab1f814", "roleDefinitionName": "Privileged Role Administrator", "securityGroupId": ""},
{"roleDefinitionId": "fe930be7-5e62-47db-91af-98c3a49a38b1", "roleDefinitionName": "User Administrator", "securityGroupId": ""},
{"roleDefinitionId": "9b895d92-2cd3-44c7-9d02-a6ac2d5ea5c3", "roleDefinitionName": "Application Administrator", "securityGroupId": ""},
{"roleDefinitionId": "cf1c38e5-3621-4004-a7cb-879624dced7c", "roleDefinitionName": "Application Developer", "securityGroupId": ""},
{"roleDefinitionId": "158c047a-c907-4556-b7ef-446551a6b5f7", "roleDefinitionName": "Cloud Application Administrator", "securityGroupId": ""},
{"roleDefinitionId": "be2f45a1-457d-42af-a067-6ec1fa63bc45", "roleDefinitionName": "External Identity Provider Administrator", "securityGroupId": ""},
{"roleDefinitionId": "95e79109-95c0-4d8e-aee3-d01accf2d47b", "roleDefinitionName": "Guest Inviter", "securityGroupId": ""},
{"roleDefinitionId": "8ac3fc64-6eca-42ea-9e69-59f4c7b60eb2", "roleDefinitionName": "Hybrid Identity Administrator", "securityGroupId": ""},
{"roleDefinitionId": "aaf43236-0c0d-4d5f-883a-6955382ac081", "roleDefinitionName": "B2C IEF Keyset Administrator", "securityGroupId": ""},
{"roleDefinitionId": "3edaf663-341e-4475-9f94-5c398ef6c070", "roleDefinitionName": "B2C IEF Policy Administrator", "securityGroupId": ""},
{"roleDefinitionId": "b0f54661-2d74-4c50-afa3-1ec803f12efe", "roleDefinitionName": "Billing Administrator", "securityGroupId": ""},
{"roleDefinitionId": "f023fd81-a637-4b56-95fd-791ac0226033", "roleDefinitionName": "Service Support Administrator", "securityGroupId": ""},
{"roleDefinitionId": "d29b2b05-8046-44ba-8758-1e26182fcf32", "roleDefinitionName": "Directory Synchronization Accounts", "securityGroupId": ""},
{"roleDefinitionId": "9360feb5-f418-4baa-8175-e2a00bac4301", "roleDefinitionName": "Directory Writers", "securityGroupId": ""},
{"roleDefinitionId": "8329153b-31d0-4727-b945-745eb3bc5f31", "roleDefinitionName": "Domain Name Administrator", "securityGroupId": ""},
{"roleDefinitionId": "88d8e3e3-8f55-4a1e-953a-9b9898b8876b", "roleDefinitionName": "Directory Readers", "securityGroupId": ""},
{"roleDefinitionId": "5d6b6bb7-de71-4623-b4af-96380a352509", "roleDefinitionName": "Security Reader", "securityGroupId": ""},
{"roleDefinitionId": "f2ef992c-3afb-46b9-b7cf-a126ee74c451", "roleDefinitionName": "Global Reader", "securityGroupId": ""},
{"roleDefinitionId": "ac16e43d-7b2d-40e0-ac05-243ff356ab5b", "roleDefinitionName": "Message Center Privacy Reader", "securityGroupId": ""},
{"roleDefinitionId": "790c1fb9-7f7d-4f88-86a1-ef1f95c05c1b", "roleDefinitionName": "Message Center Reader", "securityGroupId": ""},
{"roleDefinitionId": "4a5d8f65-41da-4de4-8968-e035b65339cf", "roleDefinitionName": "Reports Reader", "securityGroupId": ""},
{"roleDefinitionId": "75934031-6c7e-415a-99d7-48dbd49e875e", "roleDefinitionName": "Usage Summary Reports Reader", "securityGroupId": ""},
{"roleDefinitionId": "17315797-102d-40b4-93e0-432062caca18", "roleDefinitionName": "Compliance Administrator", "securityGroupId": ""},
{"roleDefinitionId": "e6d1a23a-da11-4be4-9570-befc86d067a7", "roleDefinitionName": "Compliance Data Administrator", "securityGroupId": ""},
{"roleDefinitionId": "194ae4cb-b126-40b2-bd5b-6091b380977d", "roleDefinitionName": "Security Administrator", "securityGroupId": ""},
{"roleDefinitionId": "5f2222b1-57c3-48ba-8ad5-d4759f1fde6f", "roleDefinitionName": "Security Operator", "securityGroupId": ""},
{"roleDefinitionId": "7495fdc4-34c4-4d15-a289-98788ce399fd", "roleDefinitionName": "Azure Information Protection Administrator", "securityGroupId": ""},
{"roleDefinitionId": "5c4f9dcd-47dc-4cf7-8c9a-9e4207cbfc91", "roleDefinitionName": "Customer LockBox Access Approver", "securityGroupId": ""},
{"roleDefinitionId": "0526716b-113d-4c15-b2c8-68e3c22b9f80", "roleDefinitionName": "Authentication Policy Administrator", "securityGroupId": ""},
{"roleDefinitionId": "9c6df0f2-1e7c-4dc3-b195-66dfbd24aa8f", "roleDefinitionName": "Attack Payload Author", "securityGroupId": ""},
{"roleDefinitionId": "c430b396-e693-46cc-96f3-db01bf8bb62a", "roleDefinitionName": "Attack Simulation Administrator", "securityGroupId": ""}
]
"@

