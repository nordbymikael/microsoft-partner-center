Bli ferdig med cmdlets
Bli ferdig med skriptene og fiks import av variabler
Optimaliser skriptene med Powershell module best practices
Legg til help for Get-Help <cmdlet>, samt syntax
Eventuelt annet som kan forbedres
// Implementer $select i Graph API calls så du får bedre performance, eksempelvis https://graph.microsoft.com/v1.0/tenantRelationships/delegatedAdminRelationships/e96e248c-ca9c-4211-a7de-a1f7515b22de-72465188-6db8-4510-ba33-40392d5db724/accessAssignments?$select=accessContainer,accessDetails

Fiks problemet med autentisering og dokumenter i README.md
Test alt sammen og verifiser at modulen er ferdig

Bli kvitt Old og TempDev mappene
Skriv ferdig README.md
// I README.md, nevn at "Get-CMPCAdminRelationship" tar ikke hensyn til at det kan være mer enn 300 requests, operations eller accessassignments, på grunn av performance og at det er svært usannsynlig at det er så mange parametere
// I README.md, nevn at "New-CMPCAdminRelationshipAccessAssignment" tar ikke hensyn til at en access assignment kan allerede eksistere fra før. Om du forsøker å legge til en access assignment som finnes, vil du få en error.
// I README.md, nevn at "Remove-CMPCAdminRelationshipAccessAssignment" tar ikke hensyn til at en access assigment kan være slettet fra før. Om du forsøker å legge til en access assignment som finnes, vil du få en error.
// Kanskje lage en egne funksjoner i en egen mappe som tar hensyn til dette?
Rediger modulfilene PSD1 og PSM1
Fjern .gitignore fra repositoryen
Publiser modulen i Github
Publiser modulen i PS Gallery
Lage GDAP "good to know" dokumentasjon?
// Nevn i good to know GDAP dokumentasjonen at GDAP API ikke støtter $top, $select og $expand i sine requests, så paging med @odata.nextlink er obligatorisk om man må hente flere objekter
