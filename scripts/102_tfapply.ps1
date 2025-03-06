param (
    [string]$TfDir,
    [string]$TfApplyArgs
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

    Write-InfoLog "Generating terraform apply command..."
    $cmd = @("terraform apply")
    $cmd += "-auto-approve"
    if ($null -ne $TfApplyArgs) {
        $cmd += $TfApplyArgs
    }
    $cmd = $cmd -join " "
    Write-InfoLog "terraform apply command generated."

    Write-InfoLog "Invoking terraform apply..."
    Invoke-Expression $cmd
    Write-InfoLog "terraform apply done."
}
finally {
    Set-Location $loc
}