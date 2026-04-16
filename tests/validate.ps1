# Math Skill Validation Script (PowerShell)
# Checks that all required files exist and references are correct

$script:pass = 0
$script:fail = 0
$script:warn = 0

function Check-File {
    param([string]$path)
    if (Test-Path $path -PathType Leaf) {
        Write-Host "[PASS] $path" -ForegroundColor Green
        $script:pass++
    } else {
        Write-Host "[FAIL] $path" -ForegroundColor Red
        $script:fail++
    }
}

function Check-Dir {
    param([string]$path)
    if (Test-Path $path -PathType Container) {
        Write-Host "[PASS] $path/" -ForegroundColor Green
        $script:pass++
    } else {
        Write-Host "[FAIL] $path/" -ForegroundColor Red
        $script:fail++
    }
}

function Check-Content {
    param([string]$file, [string]$pattern)
    if (Select-String -Path $file -Pattern $pattern -Quiet -ErrorAction SilentlyContinue) {
        Write-Host "[PASS] $file contains '$pattern'" -ForegroundColor Green
        $script:pass++
    } else {
        Write-Host "[FAIL] $file missing '$pattern'" -ForegroundColor Red
        $script:fail++
    }
}

Write-Host "========================================"
Write-Host "  Math Skill Validation"
Write-Host "========================================"
Write-Host ""

# Check infrastructure files
Write-Host "--- Infrastructure ---"
Check-File "package.json"

# Check skills directories and files
Write-Host ""
Write-Host "--- Skills ---"
$skills = @("axiomatization", "abstraction", "logic-deduction", "modeling", "optimization", "probability-statistics", "transformation", "symmetry-invariance", "induction-analogy", "algorithmic-thinking", "information-theory", "game-theory", "causal-inference", "topological-thinking", "discrete-combinatorial")

foreach ($skill in $skills) {
    Check-Dir "skills/$skill"
    Check-File "skills/$skill/SKILL.md"
    Check-File "skills/$skill/original-texts.md"
    Check-Content "skills/$skill/SKILL.md" "^---"
    Check-Content "skills/$skill/SKILL.md" "name:"
    Check-Content "skills/$skill/SKILL.md" "description:"
}

# Check command files
Write-Host ""
Write-Host "--- Commands ---"
foreach ($cmd in $skills) {
    Check-File "commands/$cmd.md"
    Check-Content "commands/$cmd.md" "skills/$cmd/SKILL.md"
}

# Check knowledge base
Write-Host ""
Write-Host "--- Knowledge Base ---"
Check-Dir "knowledge-base"
Check-File "knowledge-base/overview.md"

# Check agents
Write-Host ""
Write-Host "--- Agents ---"
Check-Dir "agents"
Check-File "agents/math-critic.md"

# Check tests
Write-Host ""
Write-Host "--- Tests ---"
Check-Dir "tests"
Check-File "tests/validate.sh"
Check-File "tests/validate.ps1"

# Check docs
Write-Host ""
Write-Host "--- Documentation ---"
Check-Dir "docs"
Check-File "docs/CLAUDE.md"
Check-File "README.md"
Check-File "LICENSE"

# Check npm package files
Write-Host ""
Write-Host "--- npm Package ---"
Check-File ".npmignore"
Check-Content "package.json" '"files"'
Check-Content "package.json" '"keywords"'
Check-Content "package.json" '"repository"'
Check-Content "package.json" '"author"'
Check-Content "package.json" '"scripts"'

# Check npm pack output
Write-Host ""
Write-Host "--- npm Pack Check ---"
$npmCmd = Get-Command npm -ErrorAction SilentlyContinue
if ($npmCmd) {
    $packOutput = npm pack --dry-run 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "[PASS] npm pack --dry-run succeeded" -ForegroundColor Green
        $script:pass++

        $packItems = @("README.md", "LICENSE", "commands/", "skills/", "agents/", "knowledge-base/", "docs/")
        foreach ($item in $packItems) {
            if ($packOutput -match $item) {
                Write-Host "[PASS] npm pack includes $item" -ForegroundColor Green
                $script:pass++
            } else {
                Write-Host "[FAIL] npm pack missing $item" -ForegroundColor Red
                $script:fail++
            }
        }
    } else {
        Write-Host "[WARN] npm pack --dry-run failed" -ForegroundColor Yellow
        $script:warn++
    }
} else {
    Write-Host "[WARN] npm not found, skipping pack check" -ForegroundColor Yellow
    $script:warn++
}

# Summary
Write-Host ""
Write-Host "========================================"
Write-Host "  Results: $($script:pass) passed, $($script:fail) failed, $($script:warn) warnings"
Write-Host "========================================"

if ($script:fail -gt 0) {
    exit 1
}

Write-Host "All checks passed!" -ForegroundColor Green
exit 0