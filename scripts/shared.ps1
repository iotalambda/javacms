function Write-InfoLog {
    param (
        [string]$Message
    )
    Write-Output "$((Get-Date).ToString("HH:mm:ss")) [JCMS][INFO] $Message"
}

function Write-ErrorLog {
    param (
        [string]$Message
    )
    Write-Error "$((Get-Date).ToString("HH:mm:ss")) [JCMS][ERROR] $Message"
}

$isGithub = $null -ne $env:GITHUB_SHA

if ($env:JCMS_TENANTID) {
    $tenantId = $env:JCMS_TENANTID
}
else {
    Write-ErrorLog "JCMS_TENANTID not set."
    exit 1
}

if ($env:JCMS_SUBSCRIPTIONID) {
    $subscriptionId = $env:JCMS_SUBSCRIPTIONID
}
else {
    Write-ErrorLog "JCMS_SUBSCRIPTIONID not set."
    exit 1
}

if ($isGithub -eq $false) {
    if ($env:JCMS_DEVSOBJECTID) {
        $devsObjectId = $env:JCMS_DEVSOBJECTID
    }
    else {
        Write-ErrorLog "JCMS_DEVSOBJECTID not set."
        exit 1
    }
}

$location = "northeurope"
$mgmtResourceGroupName = "jcms-dev-mgmt"
$appResourceGroupName = "jcms-dev-app"
$storageAccountName = "jcmsdevmgmtsa"
$acrName = "jcmsdevappacr"
$terraformContainerName = "terraform"
$keyVaultName = "jcms-dev-mgmt-kv"
$githubSpName = "jcms-github"
$appRegName = "jcms-app"
$env:ARM_USE_AZUREAD = "true"

function Set-GithubVariable($key, $value, $output = $false) {
    if ($output -eq $true) {
        Add-Content -Path $env:GITHUB_OUTPUT -Value "$key=$value"   
    }
    Set-Item "env:$key" $value
    Add-Content -Path $env:GITHUB_ENV -Value "$key=$value"
}

if ($isGithub -eq $true) {
    Set-GithubVariable "ARM_CLIENT_ID" $env:JCMS_GITHUBSPCLIENTID
    Set-GithubVariable "ARM_CLIENT_SECRET" $env:JCMS_GITHUBSPCLIENTSECRET
    Set-GithubVariable "ARM_SUBSCRIPTION_ID" $subscriptionId
    Set-GithubVariable "ARM_TENANT_ID" $tenantId
    Set-GithubVariable "ARM_USE_AZUREAD" $env:ARM_USE_AZUREAD
    Set-GithubVariable "JCMS_ACR_NAME" $acrName
    Set-GithubVariable "JCMS_TAG" $env:GITHUB_SHA.Substring(0, 7) $true
    Set-GithubVariable "JCMS_CREDS" "{ ""clientSecret"": ""$env:ARM_CLIENT_SECRET"", ""subscriptionId"": ""$env:ARM_SUBSCRIPTION_ID"", ""tenantId"": ""$env:ARM_TENANT_ID"", ""clientId"": ""$env:ARM_CLIENT_ID"" }"
}

function Test-Tenant {
    Write-InfoLog "Checking tenantId..."
    if ($(az account show --query "homeTenantId" --output "tsv") -ne $tenantId) {
        Write-ErrorLog "Bad tenantId. Re-login."
        exit 1
    }
    Write-InfoLog "tenantId OK."
}

function Set-DefaultSub {
    Write-InfoLog "Setting default subscription..."
    az account set --subscription "$subscriptionId"
    Write-InfoLog "Default subscription set."
}