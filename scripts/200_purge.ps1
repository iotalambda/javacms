$ErrorActionPreference = 'Stop'
$PSNativeCommandUseErrorActionPreference = $true
. (Join-Path $PSScriptRoot "/shared.ps1")

if ($isGithub -eq $false) {
    Test-Tenant
    Set-DefaultSub
}

Write-InfoLog "Deleting Terraform state files..."
az storage blob delete-batch `
    --account-name "$storageAccountName" `
    --auth-mode "login" `
    --source "$terraformContainerName" `
    --pattern "*.tfstate"
Write-InfoLog "Terraform state files deleted."

Write-InfoLog "Getting app rg resource ids..."
$resourceIds = az resource list `
    --resource-group "$appResourceGroupName" `
    --query "[].id" `
    --output "tsv"
Write-InfoLog "app rg resource ids gotten."

if ($resourceIds) {
    Write-InfoLog "Deleting resources..."
    az resource delete `
        --ids $resourceIds
    Write-InfoLog "Resources deleted."
}
else {
    Write-InfoLog "No resources."
}

Write-InfoLog "Getting app rg deleted key vault details..."
$deletedKeyVaultDetails = az keyvault list-deleted
Write-InfoLog "app rg deleted key vault details gotten."

Write-InfoLog "Filtering purgeable key vault details..."
$purgeableKeyVaultDetails = ($deletedKeyVaultDetails | ConvertFrom-Json) `
| Where-Object { $_.properties.vaultId.Contains("resourceGroups/$appResourceGroupName") -and $_.properties.purgeProtectionEnabled -ne $true }
Write-InfoLog "Purgeable key vaults filtered."

if ($purgeableKeyVaultDetails) {
    Write-InfoLog "Purging key vaults..."
    foreach ($purgeableKeyVaultDetail in $purgeableKeyVaultDetails) {
        az keyvault purge `
            --name $purgeableKeyVaultDetail.name
    }
    Write-InfoLog "Key vaults purged."
}
else {
    Write-InfoLog "No key vaults."
}