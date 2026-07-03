# Math Skill Validation Script (PowerShell, v2)
# Checks that all required files exist, references are correct, the
# math-research-activator entry is wired up, the references/ layer is present,
# and that npm pack ships no PDFs / math_book/ content.

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

function Check-Absent {
    param([string]$haystack, [string]$pattern)
    if ($haystack -match $pattern) {
        Write-Host "[FAIL] forbidden pattern '$pattern' present" -ForegroundColor Red
        $script:fail++
    } else {
        Write-Host "[PASS] '$pattern' correctly absent" -ForegroundColor Green
        $script:pass++
    }
}

function Check-NoOutput {
    param([object[]]$hits, [string]$label)
    if ($hits -and $hits.Count -gt 0) {
        Write-Host "[FAIL] $label" -ForegroundColor Red
        $hits | ForEach-Object { Write-Host $_ }
        $script:fail++
    } else {
        Write-Host "[PASS] $label" -ForegroundColor Green
        $script:pass++
    }
}

Write-Host "========================================"
Write-Host "  Math Skill Validation (v2)"
Write-Host "========================================"
Write-Host ""

# Check infrastructure files
Write-Host "--- Infrastructure ---"
Check-File "package.json"

# Check skills directories and files
Write-Host ""
Write-Host "--- Skills ---"
$skills = @("axiomatization", "abstraction", "logic-deduction", "modeling", "optimization", "probability-statistics", "transformation", "symmetry-invariance", "induction-analogy", "algorithmic-thinking", "information-theory", "game-theory", "causal-inference", "topological-thinking", "discrete-combinatorial", "math-research-activator")

foreach ($skill in $skills) {
    Check-Dir "skills/$skill"
    Check-File "skills/$skill/SKILL.md"
    Check-File "skills/$skill/original-texts.md"
    Check-Content "skills/$skill/SKILL.md" "^---"
    Check-Content "skills/$skill/SKILL.md" "name:"
    Check-Content "skills/$skill/SKILL.md" "description:"
}

# v2: no skill should still carry life-mode body content
Write-Host ""
Write-Host "--- Life-Mode Removal Check ---"
$lifeLeak = 0
foreach ($skill in $skills) {
    $hits = (Select-String -Path "skills/$skill/SKILL.md" -Pattern '生活模式|生活触发|生活输出格式|Life Mode|Life trigger' -ErrorAction SilentlyContinue | Measure-Object).Count
    if ($hits -gt 0) {
        Write-Host "[FAIL] skills/$skill/SKILL.md still has $hits life-mode line(s)" -ForegroundColor Red
        $script:fail++
        $lifeLeak++
    }
}
if ($lifeLeak -eq 0) {
    Write-Host "[PASS] no skill retains life-mode body content" -ForegroundColor Green
    $script:pass++
}

# v2: command files must not carry life-mode residue either
Write-Host ""
Write-Host "--- Command Life-Mode Removal Check ---"
$cmdLifeLeak = 0
foreach ($f in (Get-ChildItem -Path "commands" -Filter "*.md" -File -ErrorAction SilentlyContinue)) {
    $hits = (Select-String -Path $f.FullName -Pattern '生活模式|生活触发|生活输出格式|Life Mode|Life trigger' -ErrorAction SilentlyContinue | Measure-Object).Count
    if ($hits -gt 0) {
        Write-Host "[FAIL] $($f.Name) still has $hits life-mode line(s)" -ForegroundColor Red
        $script:fail++
        $cmdLifeLeak++
    }
}
if ($cmdLifeLeak -eq 0) {
    Write-Host "[PASS] no command retains life-mode body content" -ForegroundColor Green
    $script:pass++
}

# v2: every weapon (not the activator router) must carry a modern-math activation hook
Write-Host ""
Write-Host "--- Modern-Math Activation Hook ---"
$weapons15 = @("axiomatization", "abstraction", "logic-deduction", "modeling", "optimization", "probability-statistics", "transformation", "symmetry-invariance", "induction-analogy", "algorithmic-thinking", "information-theory", "game-theory", "causal-inference", "topological-thinking", "discrete-combinatorial")
foreach ($w in $weapons15) {
    Check-Content "skills/$w/SKILL.md" "现代数学激活"
}

# v2: every skill must explicitly use the official GPU
# eight-dimension vocabulary from references/gpu-friendly-math.md.
Write-Host ""
Write-Host "--- GPU Eight-Dimension Coverage ---"
$gpuDims = @("张量化", "GEMM 可映射", "复杂度", "显存与 KV-Cache", "低精度稳定", "并行与通信", "稀疏结构", "算子融合")
foreach ($skill in $skills) {
    $content = Get-Content "skills/$skill/SKILL.md" -Raw
    $missing = @()
    foreach ($dim in $gpuDims) {
        if ($content -notmatch [regex]::Escape($dim)) {
            $missing += $dim
        }
    }
    if ($missing.Count -gt 0) {
        Write-Host "[FAIL] skills/$skill/SKILL.md missing GPU dimension(s): $($missing -join ', ')" -ForegroundColor Red
        $script:fail++
    } else {
        Write-Host "[PASS] skills/$skill/SKILL.md covers official GPU eight dimensions" -ForegroundColor Green
        $script:pass++
    }
}

# Check command files
Write-Host ""
Write-Host "--- Commands ---"
$commands = @("axiomatization", "abstraction", "logic-deduction", "modeling", "optimization", "probability-statistics", "transformation", "symmetry-invariance", "induction-analogy", "algorithmic-thinking", "information-theory", "game-theory", "causal-inference", "topological-thinking", "discrete-combinatorial", "ask")

foreach ($cmd in $commands) {
    Check-File "commands/$cmd.md"

    # 'ask' command routes to the math-research-activator skill
    if ($cmd -eq "ask") {
        Check-Content "commands/$cmd.md" "../skills/math-research-activator/SKILL.md"
    } else {
        Check-Content "commands/$cmd.md" "../skills/$cmd/SKILL.md"
    }
}

# Check references layer (methodology + book activation)
Write-Host ""
Write-Host "--- References Layer ---"
Check-Dir "references"
Check-File "references/agentic-workflow.md"
Check-File "references/gpu-friendly-math.md"
# v2: the activator must wire to the GPU eight-dimension gate (source of truth)
Check-Content "skills/math-research-activator/SKILL.md" "gpu-friendly-math.md"
Check-Dir "references/books"
$books = @("abstract-algebra", "algebraic-geometry-rising-sea", "differential-geometry", "matrix-analysis", "micro-lie-theory", "optimization-ml", "smooth-manifolds")
foreach ($book in $books) {
    Check-File "references/books/$book.md"
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
Check-Content "agents/math-critic.md" "GPU 可行性审视"
Check-Content "agents/math-critic.md" "现代数学激活审视"

# Check tests
Write-Host ""
Write-Host "--- Tests ---"
Check-Dir "tests"
Check-File "tests/validate.sh"
Check-File "tests/validate.ps1"

Write-Host ""
Write-Host "--- Path Hygiene ---"
$repoFiles = Get-ChildItem -Recurse -File -Force | Where-Object {
    $_.FullName -notmatch '([\\/])\.git([\\/])' -and
    $_.FullName -notmatch '([\\/])\.deepseek([\\/])' -and
    $_.FullName -notmatch '([\\/])math_book([\\/])' -and
    $_.FullName -notmatch '([\\/])node_modules([\\/])'
}
$absPathHits = $repoFiles | Select-String -Pattern "/home/[A-Za-z0-9_.-]+"
Check-NoOutput $absPathHits "no absolute local paths are present"

$brokenSkillRefs = Select-String -Path "skills/*/SKILL.md" -Pattern "references/" | Where-Object {
    $_.Line -notmatch "\.\./\.\./references/"
}
Check-NoOutput $brokenSkillRefs "skill reference paths are relative to each SKILL.md"

# v2: every ../../references/*.md link from a SKILL.md must resolve to a real file
$brokenRefLinks = @()
$refMatches = Select-String -Path "skills/*/SKILL.md" -Pattern '\.\./\.\./references/[A-Za-z0-9/_.-]+\.md' -AllMatches -ErrorAction SilentlyContinue
foreach ($m in $refMatches) {
    foreach ($match in $m.Matches) {
        $ref = $match.Value
        $target = $ref -replace '^\.\./\.\./', ''
        if (-not (Test-Path $target -PathType Leaf)) {
            $brokenRefLinks += $ref
        }
    }
}
Check-NoOutput $brokenRefLinks "all skills -> references links resolve to existing files"

# Check top-level files
Write-Host ""
Write-Host "--- Documentation ---"
Check-File "README.md"
Check-File "LICENSE"

# Check npm package files
Write-Host ""
Write-Host "--- npm Package ---"
Check-File ".npmignore"
Check-Content "package.json" '"files"'
Check-Content "package.json" '"references/"'
Check-Content "package.json" '"keywords"'
Check-Content "package.json" '"repository"'
Check-Content "package.json" '"author"'
Check-Content "package.json" '"scripts"'

# Check npm pack output
Write-Host ""
Write-Host "--- npm Pack Check ---"
$npmCmd = Get-Command npm -ErrorAction SilentlyContinue
if ($npmCmd) {
    $packCache = Join-Path ([System.IO.Path]::GetTempPath()) "math-skill-npm-cache"
    New-Item -ItemType Directory -Force -Path $packCache | Out-Null
    $oldNpmCache = $env:npm_config_cache
    $env:npm_config_cache = $packCache
    $packOutput = npm pack --dry-run 2>&1
    $env:npm_config_cache = $oldNpmCache
    if ($LASTEXITCODE -eq 0) {
        Write-Host "[PASS] npm pack --dry-run succeeded" -ForegroundColor Green
        $script:pass++

        $packItems = @("README.md", "LICENSE", "commands/", "skills/", "agents/", "knowledge-base/", "references/")
        foreach ($item in $packItems) {
            if ($packOutput -match $item) {
                Write-Host "[PASS] npm pack includes $item" -ForegroundColor Green
                $script:pass++
            } else {
                Write-Host "[FAIL] npm pack missing $item" -ForegroundColor Red
                $script:fail++
            }
        }

        # v2: PDFs / math_book/ must NEVER ship (copyright + 110MB)
        Check-Absent ($packOutput -join "`n") "math_book/|\.pdf"
    } else {
        Write-Host "[FAIL] npm pack --dry-run failed" -ForegroundColor Red
        $packOutput | ForEach-Object { Write-Host $_ }
        $script:fail++
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
