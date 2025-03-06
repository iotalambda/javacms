$ErrorActionPreference = 'Stop'
$PSNativeCommandUseErrorActionPreference = $true
. (Join-Path $PSScriptRoot "/shared.ps1")
Test-Tenant
Set-DefaultSub

Write-InfoLog "Creating app registration for github..."
az ad sp create-for-rbac `
    --name "$githubSpName" `
    --role "Owner" `
    --scopes "/subscriptions/$subscriptionId" `
    --json-auth
Write-InfoLog "App registration for github created."

Write-InfoLog "Getting github service principal object id..."
$githubSpObjectId = ((az ad sp list | ConvertFrom-Json) | Where-Object { $_.displayName -eq "$githubSpName" })[0].id
Write-InfoLog "Github service principal object id gotten."

Write-InfoLog "Adding github service principal to devs group..."
az ad group member add `
    --group "$devsObjectId" `
    --member-id "$githubSpObjectId"
Write-InfoLog "Github service principal added to devs group."