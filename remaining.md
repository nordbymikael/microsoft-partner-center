Bli ferdig med funksjonene
Bli ferdig med skriptene
Optimaliser skriptene med Powershell module best practices
Legg til help for Get-Help <function>, samt syntax
Eventuelt annet som kan forbedres
// Implementer $select i Graph API calls så du får bedre performance, eksempelvis https://graph.microsoft.com/v1.0/tenantRelationships/delegatedAdminRelationships/e96e248c-ca9c-4211-a7de-a1f7515b22de-72465188-6db8-4510-ba33-40392d5db724/accessAssignments?$select=accessContainer,accessDetails

Test alt sammen og verifiser at modulen er ferdig
Bli kvitt Old og TempDev mappene

Skriv ferdig README.md
// I README.md, nevn at "New-CMPCAdminRelationshipAccessAssignment" tar ikke hensyn til at en access assignment kan allerede eksistere fra før. Om du forsøker å legge til en access assignment som finnes, vil du få en error.
// I README.md, nevn at "Remove-CMPCAdminRelationshipAccessAssignment" tar ikke hensyn til at en access assigment kan være slettet fra før. Om du forsøker å legge til en access assignment som finnes, vil du få en error.
Rediger modulfilene PSD1 og PSM1
Fjern .gitignore fra repositoryen
Publiser modulen i Github
Publiser modulen i PS Gallery
Lage GDAP "good to know" dokumentasjon?
// Nevn i good to know GDAP dokumentasjonen at GDAP API ikke støtter $top og $expand i sine requests, så å få respons fra @odata.nextlink er obligatorisk om man må hente flere objekter
// Nevn om fakka endpoint https://traf-pcsvcadmin-prod.trafficmanager.net/CustomerServiceAdminApi/Web/v1/granularAdminRelationships/ som krever delegated PartnerCustomerDelegatedAdministration.ReadWrite.All permissions

