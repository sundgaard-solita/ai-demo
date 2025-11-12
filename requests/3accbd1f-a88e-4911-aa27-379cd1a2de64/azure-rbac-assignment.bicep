// Azure RBAC Role Assignment for RIT5 Resource Group
// Request ID: 3accbd1f-a88e-4911-aa27-379cd1a2de64
// Requested by: Michael Ringholm Sundgaard
// Date: 2025-11-04

@description('The principal ID (Object ID) of the user MRS')
param principalId string

@description('The name of the resource group')
param resourceGroupName string = 'RIT5'

@description('Role definition - Contributor provides read/write access')
@allowed([
  'Reader'
  'Contributor'
  'Owner'
])
param roleName string = 'Contributor'

// Built-in Azure role definitions
var roleDefinitionIds = {
  Reader: 'acdd72a7-3385-48ef-bd42-f606fba81ae7'
  Contributor: 'b24988ac-6180-42a0-ab88-20f7382dd24c'
  Owner: '8e3af657-a8ff-443c-a75c-2fe8c4bcb635'
}

resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(resourceGroupName, principalId, roleDefinitionIds[roleName])
  scope: resourceGroup(resourceGroupName)
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', roleDefinitionIds[roleName])
    principalId: principalId
    principalType: 'User'
    description: 'Access granted via request 3accbd1f-a88e-4911-aa27-379cd1a2de64 on 2025-11-04'
  }
}

output roleAssignmentId string = roleAssignment.id
output assignedRole string = roleName
output resourceGroup string = resourceGroupName
