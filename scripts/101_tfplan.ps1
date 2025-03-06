param (
    [string]$TfDir,
    [string]$TfPlanArgs
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

    Write-InfoLog "Generating terraform plan command..."
    $cmd = @("terraform plan")
    if ($isGithub -eq $true) {
        $cmd += '-out="tfplan"'
    }
    if ($null -ne $TfPlanArgs) {
        $cmd += $TfPlanArgs
    }
    $cmd = $cmd -join " "
    Write-InfoLog "terraform plan command generated."

    Write-InfoLog "Invoking terraform plan..."
    Invoke-Expression $cmd
    Write-InfoLog "terraform plan done."
}
finally {
    Set-Location $loc
}