# Math Skill Validation Script (PowerShell, v3.3.0)
# Validates the three-layer architecture: lenses + knowledge-base + design-patterns
#
# Usage (run from repo root):
#   powershell -ExecutionPolicy Bypass -File .\tests\validate.ps1
# Or, after `Set-ExecutionPolicy -Scope CurrentUser RemoteSigned`:
#   .\tests\validate.ps1
#
# NOTE: save this file as UTF-8 with BOM so that PowerShell 5.1 on
# Windows correctly reads the Chinese strings used in content checks.

# Force UTF-8 code page + default encoding so Get-Content reads the
# repo's UTF-8 markdown files correctly (avoids garbled Chinese -> false FAIL).
try { chcp 65001 > $null } catch {}
if ($PSVersionTable.PSVersion.Major -lt 7) {
    $PSDefaultParameterValues['Get-Content:Encoding'] = 'utf8'
} else {
    $PSDefaultParameterValues['Get-Content:Encoding'] = 'utf8NoBOM'
}

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
Write-Host "  Math Skill Validation (v3.3.0 PS)"
Write-Host "========================================"

# --- Infrastructure ---
Write-Host "`n--- Infrastructure ---"
Check-File "package.json"
Check-Contains "package.json" "lenses/"
Check-Contains "package.json" "design-patterns/"
Check-Contains "package.json" "knowledge-base/"
Check-Contains "package.json" '"version": "3.3.0"'
Check-File "SKILL.md"
Check-File "SKILL.en.md"
if ((Get-Content "SKILL.md" -TotalCount 1) -eq "---" -and (Get-Content "SKILL.en.md" -TotalCount 1) -eq "---") {
    Write-Host "[PASS] canonical entries start with YAML frontmatter" -ForegroundColor Green; $script:pass++
} else {
    Write-Host "[FAIL] canonical entry has text before YAML frontmatter" -ForegroundColor Red; $script:fail++
}

# --- Activator ---
Write-Host "`n--- Activator ---"
Check-File "skills\math-research-activator\SKILL.md"
Check-File "skills\math-research-activator\SKILL.en.md"
Check-Contains "SKILL.md" "渐进加载与 token 预算"
Check-Contains "SKILL.en.md" "Progressive loading and token budget"
Check-Contains "skills\math-research-activator\SKILL.md" "../../SKILL.md"
Check-Contains "skills\math-research-activator\SKILL.md" "也用于与 AI 研究有关的数学查询"
Check-Contains "skills\math-research-activator\SKILL.en.md" "Also use for mathematics questions tied to AI research"
Check-Contains "agents\math-critic.md" "knowledge-base/cryptography/"
Check-Contains "agents\math-critic.en.md" "knowledge-base/cryptography/"
Check-Contains "references\skill-index.md" "默认 ≤2"

# --- Commands ---
Write-Host "`n--- Commands ---"
Check-File "commands\ask.md"
Check-File "commands\ask.en.md"
Check-Contains "commands\ask.md" "../SKILL.md"
Check-Contains "commands\ask.en.md" "../SKILL.en.md"

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
$domains = @("matrix-analysis","optimization","differential-geometry","lie-theory","topology","probability","information-geometry","algebraic-geometry","cryptography")
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
$books = @("abstract-algebra","algebraic-geometry-rising-sea","differential-geometry","matrix-analysis","micro-lie-theory","optimization-ml","smooth-manifolds","applied-cryptography","foundations-of-cryptography","introduction-to-modern-cryptography")
foreach ($book in $books) {
    Check-File "references\books\$book.md"
    Check-File "references\books\$book.en.md"
}

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
Check-File "tests\eval\mixed-language-routing.md"

# --- v3.0.1 Additions ---
Write-Host "`n--- v3.0.1 Additions ---"
Check-Contains "SKILL.md" "主语言"
Check-Contains "SKILL.en.md" "primary language"

# --- v3.1.0 Additions ---
Write-Host "`n--- v3.1.0 Additions ---"
Check-Contains "SKILL.md" "Knowledge Gap Protocol"
Check-Contains "SKILL.en.md" "Knowledge Gap Protocol"
Check-File "references\skill-index.md"
Check-File "references\skill-index.en.md"
Check-Contains "knowledge-base\overview.md" "激活锚点"
Check-Contains "knowledge-base\overview.en.md" "Activation Anchor"
Check-File "design-patterns\overview.md"
Check-File "design-patterns\overview.en.md"
$kbDomains = @("matrix-analysis","optimization","differential-geometry","lie-theory","topology","probability","information-geometry")
foreach ($domain in $kbDomains) {
    Check-File "knowledge-base\$domain\index.md"
    Check-File "knowledge-base\$domain\index.en.md"
}
Check-Contains "README.md" "不存储数学"
Check-Contains "README.md" "激活锚点"
Check-Contains "README.en-US.md" "does not store mathematics"
Check-Contains "README.en-US.md" "Activation Anchor"

# --- Semantic Regression Checks ---
Write-Host "`n--- Semantic Regression Checks ---"
Check-Contains "design-patterns\compression\low-rank-kv-cache.md" "O(Lk + kd)"
Check-Contains "design-patterns\compression\low-rank-kv-cache.en.md" "O(Lk + kd)"
Check-Not-Contains "design-patterns\compression\low-rank-kv-cache.md" "压缩到 `$O(kd)"
Check-Not-Contains "design-patterns\compression\low-rank-kv-cache.en.md" "to `$O(kd)"
Check-Not-Contains "design-patterns\compression\low-rank-kv-cache.md" "softmax attention 需从因子重构完整"
Check-Not-Contains "design-patterns\compression\low-rank-kv-cache.en.md" "must be reconstructed from the factored form"
Check-Contains "design-patterns\compression\low-rank-kv-cache.md" "因子化 GEMM"
Check-Contains "design-patterns\compression\low-rank-kv-cache.en.md" "factorized GEMMs"
Check-Contains "design-patterns\compression\low-rank-kv-cache.md" "Eckart-Young 谱范数误差"
Check-Contains "design-patterns\compression\low-rank-kv-cache.en.md" "Eckart--Young spectral-norm error"
Check-Not-Contains "design-patterns\compression\low-rank-kv-cache.md" "Weyl 扰动界保证"
Check-Not-Contains "design-patterns\compression\low-rank-kv-cache.en.md" "Weyl perturbation bound guarantees"
Check-Not-Contains "knowledge-base\matrix-analysis\low-rank-approximation.md" "需先重构"
Check-Not-Contains "knowledge-base\matrix-analysis\low-rank-approximation.en.md" "must first reconstruct"
Check-Contains "knowledge-base\matrix-analysis\low-rank-approximation.md" "主子空间唯一"
Check-Contains "knowledge-base\matrix-analysis\low-rank-approximation.en.md" "principal subspace is unique"
Check-Not-Contains "knowledge-base\matrix-analysis\low-rank-approximation.md" "唯一最优解"
Check-Not-Contains "knowledge-base\matrix-analysis\low-rank-approximation.en.md" "unique optimal solution"
Check-Contains "knowledge-base\matrix-analysis\low-rank-approximation.md" "O(mn)"
Check-Contains "knowledge-base\matrix-analysis\low-rank-approximation.en.md" "O(mn)"
Check-Contains "knowledge-base\matrix-analysis\low-rank-approximation.en.md" "information-bottleneck.en.md"
Check-Contains "design-patterns\loss\constraint-penalty.md" "不等式乘子必须保持"
Check-Contains "design-patterns\loss\constraint-penalty.en.md" "inequality multipliers must satisfy"
Check-Contains "design-patterns\compression\low-rank-kv-cache.md" "Q_final"
Check-Contains "design-patterns\compression\low-rank-kv-cache.en.md" "Q_final"
Check-Contains "design-patterns\routing\spectral-clustering-routing.md" "cdist(X_sample, X_sample)**2"
Check-Contains "design-patterns\routing\spectral-clustering-routing.en.md" "cdist(X_sample, X_sample)**2"
Check-Contains "design-patterns\attention\information-bottleneck-attention.md" "logistic-normal"
Check-Contains "design-patterns\attention\information-bottleneck-attention.en.md" "logistic-normal"
Check-Contains "design-patterns\compression\spectral-token-pruning.md" "未 mask 且不可约"
Check-Contains "design-patterns\compression\spectral-token-pruning.en.md" "unmasked irreducible"
Check-Not-Contains "design-patterns\routing\moe-routing.md" "X%"
Check-Not-Contains "design-patterns\routing\moe-routing.en.md" "X%"
Check-Not-Contains "design-patterns\routing\moe-routing.md" ">95%"
Check-Not-Contains "design-patterns\routing\moe-routing.en.md" "exceeds 95%"
Check-Not-Contains "lenses\spectral.md" "必须使用 Jordan"
Check-Not-Contains "lenses\spectral.en.md" "Jordan form is required"
Check-Not-Contains "design-patterns\loss\contrastive-loss.md" "O(1/√N)"
Check-Not-Contains "design-patterns\loss\contrastive-loss.en.md" "O(1/√N)"
Check-Contains "design-patterns\overview.md" "严谨性约定"
Check-Contains "design-patterns\overview.en.md" "Rigor convention"
Check-Contains "knowledge-base\matrix-analysis\projection.md" "Moore--Penrose"
Check-Not-Contains "knowledge-base\matrix-analysis\projection.md" "ResNet 的正交残差"
Check-Contains "knowledge-base\cryptography\prf-prg-owf.md" "3 轮给出选择明文意义下的 PRP"
Check-Not-Contains "knowledge-base\cryptography\cca-cpa-ae-hierarchy.md" "训练数据量 ≥ 模型参数量"
Check-Not-Contains "knowledge-base\cryptography\reduction-proof-template.md" "差分隐私假设"

# --- npm Pack ---
Write-Host "`n--- npm Pack Check ---"
$npmCmd = Get-Command npm -ErrorAction SilentlyContinue
if (-not $npmCmd) {
    Write-Host "[WARN] npm not found on PATH; skipping npm pack checks" -ForegroundColor Yellow
    $script:warn += 3
} else {
    $packOutput = npm pack --dry-run --cache .npm-cache 2>&1 | Out-String
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
    if ($packOutput -match "SKILL.md") {
        Write-Host "[PASS] npm pack includes canonical root SKILL.md" -ForegroundColor Green; $script:pass++
    } else {
        Write-Host "[FAIL] npm pack missing canonical root SKILL.md" -ForegroundColor Red; $script:fail++
    }
}

# --- CN/EN Pairing (synced with validate.sh) ---
Write-Host "`n--- CN/EN File Pairing ---"
$pairRoots = @("commands","skills","agents","lenses","knowledge-base","design-patterns","references")
$cnFiles = Get-ChildItem -Path $pairRoots -Recurse -Filter "*.md" | Where-Object { $_.Name -notlike "*.en.md" } | Sort-Object FullName
foreach ($cn in $cnFiles) {
    $enPath = Join-Path $cn.DirectoryName ($cn.BaseName + ".en.md")
    if (Test-Path $enPath) {
        Write-Host "[PASS] $($cn.FullName) has EN pair" -ForegroundColor Green
        $script:pass++
    } else {
        Write-Host "[FAIL] $($cn.FullName) missing EN pair: $enPath" -ForegroundColor Red
        $script:fail++
    }
}

# --- Cross-Reference Integrity (synced with validate.sh) ---
Write-Host "`n--- Cross-Reference Integrity ---"
$xrefFail = 0
$xrefRoots = @("commands","skills","agents","lenses","knowledge-base","design-patterns","references","tests\eval")
$mdFiles = @(Get-ChildItem -Path $xrefRoots -Recurse -Filter "*.md" -ErrorAction SilentlyContinue) + @(Get-Item "SKILL.md", "SKILL.en.md")
foreach ($file in $mdFiles) {
    $content = Get-Content $file.FullName -Raw
    # NOTE: $matches is a PowerShell automatic variable; rename to $refMatches
    # to avoid `Cannot overwrite variable matches` on PS 5.1.
    $refMatches = [regex]::Matches($content, '`([^`]+)`')
    foreach ($match in $refMatches) {
        $ref = $match.Groups[1].Value
        if (
            $ref -match '^https?:' -or
            $ref.Contains('*') -or
            $ref.Contains(' ') -or
            $ref.Contains('|') -or
            $ref.Contains('(') -or
            $ref.Contains('$') -or
            $ref -eq 'math_book/' -or
            $ref.EndsWith('/math_book/') -or
            -not ($ref.EndsWith('.md') -or $ref.EndsWith('/'))
        ) {
            continue
        }
        # GetFullPath throws ArgumentException on paths with invalid chars;
        # guard it so one bad ref doesn't abort the whole script.
        try {
            $target = [System.IO.Path]::GetFullPath((Join-Path $file.DirectoryName $ref))
        } catch {
            Write-Host "[WARN] $($file.FullName): skipped malformed ref $ref" -ForegroundColor Yellow
            $script:warn++
            continue
        }
        if (-not (Test-Path $target)) {
            $line = ($content.Substring(0, $match.Index) -split "`n").Count
            Write-Host "[FAIL] $($file.FullName):$line references missing $ref => $target" -ForegroundColor Red
            $script:fail++
            $xrefFail++
        }
    }
}
if ($xrefFail -eq 0) {
    Write-Host "[PASS] All backtick path references resolve" -ForegroundColor Green
    $script:pass++
}

# --- Count Verification (synced with validate.sh) ---
Write-Host "`n--- Count Verification ---"
$cnLenses = (Get-ChildItem -Path "lenses" -Filter "*.md" | Where-Object { $_.Name -notlike "*.en.md" }).Count
$enLenses = (Get-ChildItem -Path "lenses" -Filter "*.en.md").Count
$cnKB = (Get-ChildItem -Path "knowledge-base" -Recurse -Filter "*.md" | Where-Object { $_.Name -notlike "*.en.md" -and $_.Name -notlike "overview*" -and $_.Name -notlike "index*" }).Count
$enKB = (Get-ChildItem -Path "knowledge-base" -Recurse -Filter "*.en.md" | Where-Object { $_.Name -notlike "overview.en.md" -and $_.Name -notlike "index.en.md" }).Count
$cnDP = (Get-ChildItem -Path "design-patterns" -Recurse -Filter "*.md" | Where-Object { $_.Name -notlike "*.en.md" -and $_.Name -notlike "overview*" }).Count
$enDP = (Get-ChildItem -Path "design-patterns" -Recurse -Filter "*.en.md" | Where-Object { $_.Name -notlike "overview.en.md" }).Count

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
