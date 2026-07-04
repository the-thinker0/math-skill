# Math Skill Validation Script (PowerShell, v3.0.0)
# Validates the three-layer architecture: lenses + knowledge-base + design-patterns

$script:pass = 0
$script:fail = 0
$script:warn = 0

function Check-File {
    param([string]$path)
    if (Test-Path $path) {
        Write-Host "[PASS] $path" -ForegroundColor Green
        $script:pass++
    } else {
        Write-Host "[FAIL] $path" -ForegroundColor Red
        $script:fail++
    }
}

function Check-Dir {
    param([string]$path)
    if (Test-Path $path) {
        Write-Host "[PASS] $path/" -ForegroundColor Green
        $script:pass++
    } else {
        Write-Host "[FAIL] $path/" -ForegroundColor Red
        $script:fail++
    }
}

function Check-Contains {
    param([string]$file, [string]$pattern)
    if (Test-Path $file) {
        $content = Get-Content $file -Raw
        if ($content -match [regex]::Escape($pattern)) {
            Write-Host "[PASS] $file contains '$pattern'" -ForegroundColor Green
            $script:pass++
        } else {
            Write-Host "[FAIL] $file does NOT contain '$pattern'" -ForegroundColor Red
            $script:fail++
        }
    } else {
        Write-Host "[FAIL] $file not found" -ForegroundColor Red
        $script:fail++
    }
}

function Check-Not-Contains {
    param([string]$file, [string]$pattern)
    if (Test-Path $file) {
        $content = Get-Content $file -Raw
        if ($content -notmatch [regex]::Escape($pattern)) {
            Write-Host "[PASS] $file does not contain '$pattern'" -ForegroundColor Green
            $script:pass++
        } else {
            Write-Host "[FAIL] $file still contains '$pattern'" -ForegroundColor Red
            $script:fail++
        }
    }
}

Write-Host "========================================"
Write-Host "  Math Skill Validation (v3.0.0 PS)"
Write-Host "========================================"

# --- Infrastructure ---
Write-Host "`n--- Infrastructure ---"
Check-File "package.json"
Check-Contains "package.json" "lenses/"
Check-Contains "package.json" "design-patterns/"
Check-Contains "package.json" "knowledge-base/"

# --- Activator ---
Write-Host "`n--- Activator ---"
Check-File "skills\math-research-activator\SKILL.md"
Check-File "skills\math-research-activator\SKILL.en.md"

# --- Commands ---
Write-Host "`n--- Commands ---"
Check-File "commands\ask.md"

# --- Lenses ---
Write-Host "`n--- Lenses ---"
Check-Dir "lenses"
$lenses = @("axiomatization","categorical","variational","duality","symmetry","perturbation","topological","probabilistic","geometric","local-to-global","algorithmic","spectral","game","causal","projection")
foreach ($lens in $lenses) {
    Check-File "lenses\$lens.md"
    Check-File "lenses\$lens.en.md"
}

# --- Knowledge Base ---
Write-Host "`n--- Knowledge Base ---"
Check-Dir "knowledge-base"
$domains = @("matrix-analysis","optimization","differential-geometry","lie-theory","topology","probability","information-geometry")
foreach ($domain in $domains) {
    Check-Dir "knowledge-base\$domain"
}

# --- Design Patterns ---
Write-Host "`n--- Design Patterns ---"
Check-Dir "design-patterns"
$types = @("attention","loss","routing","representation","compression")
foreach ($type in $types) {
    Check-Dir "design-patterns\$type"
}

# --- References ---
Write-Host "`n--- References ---"
Check-File "references\gpu-friendly-math.md"
Check-Dir "references\books"

# --- Agents ---
Write-Host "`n--- Agents ---"
Check-File "agents\math-critic.md"
Check-File "agents\math-critic.en.md"

# --- Old Architecture Removal ---
Write-Host "`n--- Old Architecture Removal ---"
$oldSkills = @("axiomatization","abstraction","logic-deduction","modeling","optimization","probability-statistics","transformation","symmetry-invariance","induction-analogy","algorithmic-thinking","information-theory","game-theory","causal-inference","topological-thinking","discrete-combinatorial")
foreach ($skill in $oldSkills) {
    if (Test-Path "skills\$skill") {
        Write-Host "[FAIL] Old skill directory still exists: skills\$skill" -ForegroundColor Red
        $script:fail++
    } else {
        Write-Host "[PASS] Old skill removed: skills\$skill" -ForegroundColor Green
        $script:pass++
    }
}

$oldCommands = @("axiomatization","abstraction","logic-deduction","modeling","optimization","probability-statistics","transformation","symmetry-invariance","induction-analogy","algorithmic-thinking","information-theory","game-theory","causal-inference","topological-thinking","discrete-combinatorial")
foreach ($cmd in $oldCommands) {
    if (Test-Path "commands\$cmd.md") {
        Write-Host "[FAIL] Old command still exists: commands\$cmd.md" -ForegroundColor Red
        $script:fail++
    } else {
        Write-Host "[PASS] Old command removed: commands\$cmd.md" -ForegroundColor Green
        $script:pass++
    }
}

# --- README Consistency ---
Write-Host "`n--- README Consistency ---"
Check-Not-Contains "README.md" "十六思想武器"
Check-Contains "README.md" "lenses/"
Check-Contains "README.md" "knowledge-base/"
Check-Contains "README.md" "design-patterns/"

# --- Eval Tests ---
Write-Host "`n--- Eval Tests ---"
Check-File "tests\eval\should-trigger-design.md"
Check-File "tests\eval\should-trigger-knowledge.md"
Check-File "tests\eval\should-not-trigger.md"

# --- npm Pack ---
Write-Host "`n--- npm Pack Check ---"
$packOutput = npm pack --dry-run 2>&1 | Out-String
if ($packOutput -match "total files") {
    Write-Host "[PASS] npm pack succeeded" -ForegroundColor Green; $script:pass++
} else {
    Write-Host "[FAIL] npm pack failed" -ForegroundColor Red; $script:fail++
}
if ($packOutput -match "lenses/") {
    Write-Host "[PASS] npm pack includes lenses/" -ForegroundColor Green; $script:pass++
} else {
    Write-Host "[FAIL] npm pack missing lenses/" -ForegroundColor Red; $script:fail++
}
if ($packOutput -match "design-patterns/") {
    Write-Host "[PASS] npm pack includes design-patterns/" -ForegroundColor Green; $script:pass++
} else {
    Write-Host "[FAIL] npm pack missing design-patterns/" -ForegroundColor Red; $script:fail++
}

# --- CN/EN Pairing (synced with validate.sh) ---
Write-Host "`n--- CN/EN File Pairing ---"
$cnLenses = Get-ChildItem -Path "lenses" -Filter "*.md" | Where-Object { $_.Name -notlike "*.en.md" }
foreach ($cn in $cnLenses) {
    $enName = $cn.BaseName + ".en.md"
    if (Test-Path "lenses\$enName") {
        Write-Host "[PASS] $($cn.Name) has EN pair" -ForegroundColor Green
        $script:pass++
    } else {
        Write-Host "[FAIL] $($cn.Name) missing EN pair" -ForegroundColor Red
        $script:fail++
    }
}

# --- Cross-Reference Integrity (synced with validate.sh) ---
Write-Host "`n--- Cross-Reference Integrity ---"
$xrefFail = 0
$dpFiles = Get-ChildItem -Path "design-patterns" -Recurse -Filter "*.md" | Where-Object { $_.Name -notlike "*.en.md" }
foreach ($dp in $dpFiles) {
    $content = Get-Content $dp.FullName -Raw

    $lensRefs = [regex]::Matches($content, 'lenses/([a-z-]+)\.md')
    foreach ($ref in $lensRefs) {
        $target = "lenses\" + $ref.Groups[1].Value + ".md"
        if (-not (Test-Path $target)) {
            Write-Host "[FAIL] $($dp.Name) references missing $($ref.Value)" -ForegroundColor Red
            $script:fail++
            $xrefFail++
        }
    }

    $kbRefs = [regex]::Matches($content, 'knowledge-base/([a-z-]+)/([a-z-]+)\.md')
    foreach ($ref in $kbRefs) {
        $target = "knowledge-base\" + $ref.Groups[1].Value + "\" + $ref.Groups[2].Value + ".md"
        if (-not (Test-Path $target)) {
            Write-Host "[FAIL] $($dp.Name) references missing $($ref.Value)" -ForegroundColor Red
            $script:fail++
            $xrefFail++
        }
    }
}
if ($xrefFail -eq 0) {
    Write-Host "[PASS] All cross-references resolved" -ForegroundColor Green
    $script:pass++
}

# --- Count Verification (synced with validate.sh) ---
Write-Host "`n--- Count Verification ---"
$cnLenses = (Get-ChildItem -Path "lenses" -Filter "*.md" | Where-Object { $_.Name -notlike "*.en.md" }).Count
$enLenses = (Get-ChildItem -Path "lenses" -Filter "*.en.md").Count
$cnKB = (Get-ChildItem -Path "knowledge-base" -Recurse -Filter "*.md" | Where-Object { $_.Name -notlike "*.en.md" -and $_.Name -notlike "overview*" }).Count
$enKB = (Get-ChildItem -Path "knowledge-base" -Recurse -Filter "*.en.md" | Where-Object { $_.Name -notlike "overview.en.md" }).Count
$cnDP = (Get-ChildItem -Path "design-patterns" -Recurse -Filter "*.md" | Where-Object { $_.Name -notlike "*.en.md" }).Count
$enDP = (Get-ChildItem -Path "design-patterns" -Recurse -Filter "*.en.md").Count

if ($cnLenses -eq $enLenses) {
    Write-Host "[PASS] Lenses: $cnLenses CN = $enLenses EN" -ForegroundColor Green; $script:pass++
} else {
    Write-Host "[FAIL] Lenses: $cnLenses CN != $enLenses EN" -ForegroundColor Red; $script:fail++
}
if ($cnKB -eq $enKB) {
    Write-Host "[PASS] Knowledge cards: $cnKB CN = $enKB EN" -ForegroundColor Green; $script:pass++
} else {
    Write-Host "[FAIL] Knowledge cards: $cnKB CN != $enKB EN" -ForegroundColor Red; $script:fail++
}
if ($cnDP -eq $enDP) {
    Write-Host "[PASS] Design patterns: $cnDP CN = $enDP EN" -ForegroundColor Green; $script:pass++
} else {
    Write-Host "[FAIL] Design patterns: $cnDP CN != $enDP EN" -ForegroundColor Red; $script:fail++
}
Write-Host "  Totals: $cnLenses lenses, $cnKB knowledge cards, $cnDP design patterns" -ForegroundColor Cyan

# --- Results ---
Write-Host "`n========================================"
Write-Host "  Results: $($script:pass) passed, $($script:fail) failed, $($script:warn) warnings"
Write-Host "========================================"

if ($script:fail -eq 0) {
    Write-Host "All checks passed!" -ForegroundColor Green
    exit 0
} else {
    Write-Host "Some checks failed!" -ForegroundColor Red
    exit 1
}

