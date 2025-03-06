$ErrorActionPreference = 'Stop'
$PSNativeCommandUseErrorActionPreference = $true
. (Join-Path $PSScriptRoot "/shared.ps1")
Test-Tenant
Set-DefaultSub

Write-InfoLog "Ensuring mgmt resource group..."
az group create `
    --name "$mgmtResourceGroupName" `
    --location "$location" `
    --output "none"
Write-InfoLog "Mgmt resource group ensured."

Write-InfoLog "Ensuring mgmt storage account..."
$storageAccountId = az storage account create `
    --name "$storageAccountName" `
    --resource-group "$mgmtResourceGroupName" `
    --location "$location" `
    --access-tier "Hot" `
    --allow-blob-public-access "true" `
    --allow-shared-key-access "false" `
    --sku "Standard_LRS" `
    --kind "BlobStorage" `
    --min-tls-version "TLS1_2" `
    --public-network-access "Enabled" `
    --query "id" `
    --output "tsv"
Write-InfoLog "Mgmt storage account ensured."

Write-InfoLog "Ensuring tf backend container..."
az storage container create `
    --name "$terraformContainerName" `
    --resource-group "$mgmtResourceGroupName" `
    --account-name "$storageAccountName" `
    --auth-mode "login" `
    --public-access "blob" `
    --output "none"
Write-InfoLog "Tf backend container ensured."

Write-InfoLog "Ensuring mgmt storage account roles for devs group..."
az role assignment create `
    --assignee-object-id "$devsObjectId" `
    --assignee-principal-type "Group" `
    --role "Storage Blob Data Contributor" `
    --scope "$storageAccountId" `
    --output "none"
Write-InfoLog "Mgmt storage account roles for devs group ensured."

Write-InfoLog "Checking if mgmt key vault exists..."
$existingKeyVaultDetails = (az keyvault list --resource-group "$mgmtResourceGroupName" | ConvertFrom-Json) | Where-Object { $_.name -eq "$keyVaultName" }[0]
if ($existingKeyVaultDetails) {
    Write-InfoLog "Mgmt key vault already exists."
    $keyVaultId = $existingKeyVaultDetails.id
}
else {
    Write-InfoLog "Mgmt key vault does not exist. Creating mgmt key vault..."
    $keyVaultId = az keyvault create `
        --name "$keyVaultName" `
        --resource-group "$mgmtResourceGroupName" `
        --location "$location" `
        --enable-rbac-authorization `
        --query "id" `
        --output "tsv"
    Write-InfoLog "Mgmt key vault created."
}

Write-InfoLog "Ensuring mgmt key vault roles for devs group..."
az role assignment create `
    --assignee-object-id "$devsObjectId" `
    --assignee-principal-type "Group" `
    --role "Key Vault Administrator" `
    --scope "$keyVaultId" `
    --output "none"
Write-InfoLog "Mgmt key vault roles for devs group ensured."

Write-InfoLog "Adding devs object id to key vault..."
az keyvault secret set `
    --vault-name "$keyVaultName" `
    --name "jcms-devsobjectid" `
    --value "$devsObjectId" `
    --output "none"
Write-InfoLog "Devs object id added to key vault."

Write-InfoLog "Ensuring app resource group..."
az group create `
    --name "jcms-dev-app" `
    --location "$location" `
    --output "none"
Write-InfoLog "App resource group ensured."

