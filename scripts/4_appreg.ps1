$ErrorActionPreference = 'Stop'
$PSNativeCommandUseErrorActionPreference = $true
. (Join-Path $PSScriptRoot "/shared.ps1")
Test-Tenant
Set-DefaultSub

$redirectUris = @{ "http://localhost:3000/api/auth/callback/microsoft-entra-id" = $true }

Write-InfoLog "Checking if app registration exists..."
$existingAppRegDetails = (az ad app list | ConvertFrom-Json) | Where-Object { $_.displayName -eq "$appRegName" }[0]
if ($existingAppRegDetails) {
    $appRegId = $existingAppRegDetails.appId
    Write-InfoLog "App registration exists. Extracting redirect uris..."
    if ($existingAppRegDetails.web.redirectUris) {
        foreach ($uri in $existingAppRegDetails.web.redirectUris) {
            $redirectUris[$uri] = $true
        }
        Write-InfoLog "Redirect uris extracted."
    }
    else {
        Write-InfoLog "No redirect uris."
    }
}
else {
    Write-InfoLog "App registration doesn't exist. Creating app registration..."
    $appRegId = az ad app create `
        --display-name "$appRegName" `
        --query "appId" `
        --output "tsv"
    Write-InfoLog "App registration created."
}

Write-InfoLog "Updating redirect uris..."
az ad app update `
    --id "$appRegId" `
    --web-redirect-uris $redirectUris.Keys `
    --output "none"
Write-InfoLog "Redirect uris updated."

Write-InfoLog "Adding identifier URI..."
az ad app update `
    --id "$appRegId" `
    --identifier-uris "api://$appRegId" `
    --output "none"
Write-InfoLog "Identifier URI added."

Write-InfoLog "Enabling ID tokens..."
az ad app update `
    --id "$appRegId" `
    --enable-id-token-issuance "true" `
    --output "none"
Write-InfoLog "ID tokens enabled."

Write-InfoLog "Adding OAuth2 scope..."
$oauth2ScopeId = "3c8d0da4-8000-49ab-b406-e2d601a12900"
$scopeJson = @{"oauth2PermissionScopes" = @(@{"id" = $oauth2ScopeId; "adminConsentDescription" = "Authenticate"; "adminConsentDisplayName" = "Authenticate"; "isEnabled" = $true; "type" = "User"; "value" = "auth" }) } | ConvertTo-Json -d 4 -Compress | ConvertTo-Json
az ad app update `
    --id "$appRegId" `
    --set api=$scopeJson `
    --output "none"
Write-InfoLog "OAuth2 scope added."

Write-InfoLog "Getting existing permissions..."
$existingPermissions = az ad app permission list --id "$appRegId" | ConvertFrom-Json
Write-InfoLog "Existing permissions gotten."

$graphApiAppId = "00000003-0000-0000-c000-000000000000"
$userReadResourceAccessId = "e1fe6dd8-ba31-4d61-89e7-88639da4683d"
$existingUserReadPermission = $existingPermissions | Where-Object { $_.resourceAppId -eq $graphApiAppId -and ($_.resourceAccess | Where-Object { $_.id -eq $userReadResourceAccessId }) }
if ($existingUserReadPermission) {
    Write-InfoLog "User.Read permission exists."
}
else {
    Write-InfoLog "Adding User.Read permission..."
    az ad app permission add `
        --id "$appRegId" `
        --api $graphApiAppId `
        --api-permissions "$userReadResourceAccessId=Scope" `
        --output "none"
    Write-InfoLog "User.Read permission added."
}

Write-InfoLog "Granting admin consent..."
az ad app permission admin-consent `
    --id "$appRegId" `
    --output "none"
Write-InfoLog "Admin consent granted."

Write-InfoLog "Creating enterprise app..."
az ad sp create `
    --id "$appRegId" `
    --output "none"
Write-InfoLog "Enterprise app created."

Write-InfoLog "Setting assignment required..."
az ad sp update `
    --id "$appRegId" `
    --set appRoleAssignmentRequired=true `
    --output "none"
Write-InfoLog "Assignment set required."

Write-InfoLog "Getting github service principal object id..."
$githubSpObjectId = ((az ad sp list | ConvertFrom-Json) | Where-Object { $_.displayName -eq "$githubSpName" })[0].id
Write-InfoLog "Github service principal object id gotten."

Write-InfoLog "Adding github service principal as the owner of the app..."
az ad app owner add `
    --id "$appRegId" `
    --owner-object-id "$githubSpObjectId" `
    --output "none"
Write-InfoLog "Github SP added as the owner of the app."

Write-InfoLog "Creating client secret..."
$clientSecret = az ad app credential reset `
    --id "$appRegId" `
    --display-name "client-secret" `
    --years 2 `
    --query "password" `
    --output "tsv"
Write-InfoLog "Client secret created."

Write-InfoLog "Adding client id to key vault..."
az keyvault secret set `
    --vault-name "$keyVaultName" `
    --name "jcms-entra-clientid" `
    --value "$appRegId" `
    --output "none"
Write-InfoLog "Client id added to key vault."

Write-InfoLog "Adding client secret to key vault..."
az keyvault secret set `
    --vault-name "$keyVaultName" `
    --name "jcms-entra-clientsecret" `
    --value "$clientSecret" `
    --output "none"
Write-InfoLog "Client secret added to key vault."