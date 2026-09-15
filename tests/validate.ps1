# Use the same checks as Bash/npm and propagate startup errors and exit status.
$ErrorActionPreference = 'Stop'
try {
    & node (Join-Path $PSScriptRoot 'validate.mjs') @args
    if ($null -eq $LASTEXITCODE) { throw 'Node did not return an exit status' }
    exit $LASTEXITCODE
} catch {
    Write-Error $_ -ErrorAction Continue
    exit 1
}
