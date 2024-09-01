<#

Hi, this module is yet in early beta test and I would appreciate if you notified me about bugs on email: nordby.mikael@gmail.com

#>

<#

Known bugs and improvements to make:

Related to: Implementation of support for both admin relationship ID and admin relationship display name
Problem: In some functions, the validation scripts are incompatible with the admin relationship display name option, and are hard coded to depend on admin relationship ID.
Fix: Implement support for admin relationship display name in addition to the already existing admin relationship ID
Known functions where the problem exists: Edit-CMPCAdminRelationship, Edit-CMPCAdminRelationshipAccessAssignment, Remove-CMPCAdminRelationshipAccessAssignment

Related to: Implementation of pipeline input
Problem: All the function do not yet support pipeline input for the admin relationship ID and admin relationship display name
Fix: Implement pipeline input
Known functions where the problem exists: All

Related to: Parameter name and vaiable name standarization
Problem: The module has nonstandarized variable and parameter names (different capital letter on variable names), as well as some parameters have different names but indicate the same thing
Fix: Start all variables and parameters with capital letters
Known functions where the problem exists: Most functions

Related to: 
Problem: 
Fix: 
Known functions where the problem exists: 

Related to: 
Problem: 
Fix: 
Known functions where the problem exists: 

Related to: 
Problem: 
Fix: 
Known functions where the problem exists: 

#>

<#

Notes:

Bli ferdig med funksjonene
Bli ferdig med skriptene
Optimaliser skriptene med Powershell module best practices
Legg til comment-basert help
Implementer pipeline input
Eventuelt annet som kan forbedres
// Implementer $select i Graph API calls så du får bedre performance

Test alt sammen og verifiser at modulen er ferdig

Skriv ferdig README.md
// I README.md, nevn at "New-CMPCAdminRelationshipAccessAssignment" tar ikke hensyn til at en access assignment kan allerede eksistere fra før. Om du forsøker å legge til en access assignment som finnes, vil du få en error.
// I README.md, nevn at "Remove-CMPCAdminRelationshipAccessAssignment" tar ikke hensyn til at en access assigment kan være slettet fra før. Om du forsøker å legge til en access assignment som finnes, vil du få en error.

#>