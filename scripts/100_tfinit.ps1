param (
    [string]$TfDir
)

$ErrorActionPreference = 'Stop'
$PSNativeCommandUseErrorActionPreference = $true
. (Join-Path $PSScriptRoot "/shared.ps1")

if ($isGithub -eq $false) {
    Test-Tenant
    Set-DefaultSub
}

try {
    $loc = Get-Location
    Set-Location (Join-Path $PSScriptRoot "../terraform/$TfDir")

    Write-InfoLog "Invoking terraform init..."
    terraform init `
        -backend-config="resource_group_name=$mgmtResourceGroupName" `
        -backend-config="storage_account_name=$storageAccountName" `
        -backend-config="container_name=$terraformContainerName" `
        -reconfigure
    Write-InfoLog "terraform init done."
}
finally {
    Set-Location $loc
}