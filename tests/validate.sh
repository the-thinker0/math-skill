#!/bin/bash
# Math Skill Validation Script (v3.3.2)
# Validates the three-layer architecture: lenses + knowledge-base + design-patterns

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

PASS=0
FAIL=0
WARN=0

check_file() {
    if [ -f "$1" ]; then
        echo -e "${GREEN}[PASS]${NC} $1"
        PASS=$((PASS + 1))
    else
        echo -e "${RED}[FAIL]${NC} $1"
        FAIL=$((FAIL + 1))
    fi
}

check_dir() {
    if [ -d "$1" ]; then
        echo -e "${GREEN}[PASS]${NC} $1/"
        PASS=$((PASS + 1))
    else
        echo -e "${RED}[FAIL]${NC} $1/"
        FAIL=$((FAIL + 1))
    fi
}

check_contains() {
    if grep -F -q -- "$2" "$1" 2>/dev/null; then
        echo -e "${GREEN}[PASS]${NC} $1 contains '$2'"
        PASS=$((PASS + 1))
    else
        echo -e "${RED}[FAIL]${NC} $1 does NOT contain '$2'"
        FAIL=$((FAIL + 1))
    fi
}

check_not_contains() {
    # Fixed-string matching (consistent with check_contains)
    if grep -Fq -- "$2" "$1" 2>/dev/null; then
        echo -e "${RED}[FAIL]${NC} $1 still contains '$2'"
        FAIL=$((FAIL + 1))
    else
        echo -e "${GREEN}[PASS]${NC} $1 does not contain '$2'"
        PASS=$((PASS + 1))
    fi
}

check_not_contains_regex() {
    # Regex matching (for patterns with ^, .*, etc.)
    if grep -q -- "$2" "$1" 2>/dev/null; then
        echo -e "${RED}[FAIL]${NC} $1 still contains '$2'"
        FAIL=$((FAIL + 1))
    else
        echo -e "${GREEN}[PASS]${NC} $1 does not contain '$2'"
        PASS=$((PASS + 1))
    fi
}

echo "========================================"
echo "  Math Skill Validation (v3.3.2)"
echo "========================================"

# --- Infrastructure ---
echo ""
echo "--- Infrastructure ---"
check_file "package.json"
check_contains "package.json" '"files"'
check_contains "package.json" '"lenses/"'
check_contains "package.json" '"design-patterns/"'
check_contains "package.json" '"knowledge-base/"'
check_contains "package.json" '"references/"'
check_file "SKILL.md"
check_file "SKILL.en.md"
if [ "$(head -n 1 SKILL.md)" = "---" ] && [ "$(head -n 1 SKILL.en.md)" = "---" ]; then
    echo -e "${GREEN}[PASS]${NC} canonical entries start with YAML frontmatter"
    PASS=$((PASS + 1))
else
    echo -e "${RED}[FAIL]${NC} canonical entry has bytes/text before YAML frontmatter"
    FAIL=$((FAIL + 1))
fi

# --- Activator ---
echo ""
echo "--- Activator ---"
check_contains "SKILL.md" 'Domain Router'
check_contains "SKILL.md" '渐进加载与 token 预算'
check_contains "SKILL.md" 'Knowledge Gap Protocol'
check_contains "SKILL.en.md" 'Progressive loading and token budget'
check_contains "SKILL.en.md" 'Domain Router'
check_contains "skills/math-research-activator/SKILL.md" '../../SKILL.md'
check_contains "skills/math-research-activator/SKILL.en.md" '../../SKILL.en.md'

# --- Commands ---
echo ""
echo "--- Commands ---"
check_file "commands/ask.md"
check_contains "commands/ask.md" '../SKILL.md'
check_file "commands/ask.en.md"
check_contains "commands/ask.en.md" '../SKILL.en.md'

# --- Lenses ---
echo ""
echo "--- Lenses ---"
check_dir "lenses"
EXPECTED_LENSES="axiomatization categorical variational duality symmetry perturbation topological probabilistic geometric local-to-global algorithmic spectral game causal projection"
for lens in $EXPECTED_LENSES; do
    check_file "lenses/${lens}.md"
    check_file "lenses/${lens}.en.md"
    if [ -f "lenses/${lens}.md" ]; then
        check_contains "lenses/${lens}.md" '它是什么视角'
        check_contains "lenses/${lens}.md" '推理协议'
    fi
done

# --- Knowledge Base ---
echo ""
echo "--- Knowledge Base ---"
check_dir "knowledge-base"
KB_DOMAINS="matrix-analysis optimization differential-geometry lie-theory topology probability information-geometry algebraic-geometry cryptography"
KB_TOTAL=0
for domain in $KB_DOMAINS; do
    check_dir "knowledge-base/${domain}"
    count=$(find "knowledge-base/${domain}" -name "*.md" ! -name "*.en.md" ! -name "index.md" 2>/dev/null | wc -l)
    en_count=$(find "knowledge-base/${domain}" -name "*.en.md" ! -name "index.en.md" 2>/dev/null | wc -l)
    KB_TOTAL=$((KB_TOTAL + count))
    echo -e "  ${GREEN}[INFO]${NC} ${domain}: ${count} CN + ${en_count} EN cards"
done
echo -e "  ${GREEN}[INFO]${NC} Total knowledge cards: ${KB_TOTAL} CN"

# --- Design Patterns ---
echo ""
echo "--- Design Patterns ---"
check_dir "design-patterns"
DP_TYPES="attention loss routing representation compression"
DP_TOTAL=0
for type in $DP_TYPES; do
    check_dir "design-patterns/${type}"
    count=$(find "design-patterns/${type}" -name "*.md" ! -name "*.en.md" 2>/dev/null | wc -l)
    en_count=$(find "design-patterns/${type}" -name "*.en.md" 2>/dev/null | wc -l)
    DP_TOTAL=$((DP_TOTAL + count))
    echo -e "  ${GREEN}[INFO]${NC} ${type}: ${count} CN + ${en_count} EN patterns"
done
echo -e "  ${GREEN}[INFO]${NC} Total design patterns: ${DP_TOTAL} CN"

# --- References ---
echo ""
echo "--- References ---"
check_file "references/gpu-friendly-math.md"
check_file "references/agentic-workflow.md"
check_file "references/inspiration.md"
check_dir "references/books"
for book in abstract-algebra algebraic-geometry-rising-sea differential-geometry matrix-analysis micro-lie-theory optimization-ml smooth-manifolds applied-cryptography foundations-of-cryptography introduction-to-modern-cryptography; do
    check_file "references/books/${book}.md"
    check_file "references/books/${book}.en.md"
done

# --- Agents ---
echo ""
echo "--- Agents ---"
check_file "agents/math-critic.md"
check_file "agents/math-critic.en.md"

# --- Old Architecture Removal ---
echo ""
echo "--- Old Architecture Removal ---"
# Verify no old weapon skill directories remain
OLD_SKILLS="axiomatization categorical logic-deduction modeling optimization probability-statistics transformation symmetry-invariance induction-analogy algorithmic-thinking information-theory game-theory causal-inference topological-thinking discrete-combinatorial"
for skill in $OLD_SKILLS; do
    if [ -d "skills/${skill}" ]; then
        echo -e "${RED}[FAIL]${NC} Old skill directory still exists: skills/${skill}/"
        FAIL=$((FAIL + 1))
    else
        echo -e "${GREEN}[PASS]${NC} Old skill removed: skills/${skill}/"
        PASS=$((PASS + 1))
    fi
done

# Verify no old command files remain (only ask.md should exist)
OLD_COMMANDS="axiomatization categorical logic-deduction modeling optimization probability-statistics transformation symmetry-invariance induction-analogy algorithmic-thinking information-theory game-theory causal-inference topological-thinking discrete-combinatorial"
for cmd in $OLD_COMMANDS; do
    if [ -f "commands/${cmd}.md" ]; then
        echo -e "${RED}[FAIL]${NC} Old command file still exists: commands/${cmd}.md"
        FAIL=$((FAIL + 1))
    else
        echo -e "${GREEN}[PASS]${NC} Old command removed: commands/${cmd}.md"
        PASS=$((PASS + 1))
    fi
done

# --- README Consistency ---
echo ""
echo "--- README Consistency ---"
check_not_contains "README.md" '/axiomatization '
check_not_contains "README.md" '/optimization <'
check_not_contains "README.md" '十六思想武器'
check_contains "README.md" 'lenses/'
check_contains "README.md" 'knowledge-base/'
check_contains "README.md" 'design-patterns/'
check_contains "README.en-US.md" 'lenses/'
check_contains "README.en-US.md" 'knowledge-base/'
check_contains "README.en-US.md" 'design-patterns/'

# --- npm Pack Check ---
echo ""
echo "--- npm Pack Check ---"
PACK_OUTPUT=$(npm pack --dry-run --cache "$PWD/.npm-cache" 2>&1)
if echo "$PACK_OUTPUT" | grep -q "total files"; then
    echo -e "${GREEN}[PASS]${NC} npm pack --dry-run succeeded"
    PASS=$((PASS + 1))
else
    echo -e "${RED}[FAIL]${NC} npm pack --dry-run failed"
    FAIL=$((FAIL + 1))
fi

if echo "$PACK_OUTPUT" | grep -q "lenses/"; then
    echo -e "${GREEN}[PASS]${NC} npm pack includes lenses/"
    PASS=$((PASS + 1))
else
    echo -e "${RED}[FAIL]${NC} npm pack MISSING lenses/"
    FAIL=$((FAIL + 1))
fi

if echo "$PACK_OUTPUT" | grep -q "design-patterns/"; then
    echo -e "${GREEN}[PASS]${NC} npm pack includes design-patterns/"
    PASS=$((PASS + 1))
else
    echo -e "${RED}[FAIL]${NC} npm pack MISSING design-patterns/"
    FAIL=$((FAIL + 1))
fi

if echo "$PACK_OUTPUT" | grep -q "knowledge-base/"; then
    echo -e "${GREEN}[PASS]${NC} npm pack includes knowledge-base/"
    PASS=$((PASS + 1))
else
    echo -e "${RED}[FAIL]${NC} npm pack MISSING knowledge-base/"
    FAIL=$((FAIL + 1))
fi

if echo "$PACK_OUTPUT" | grep -q "SKILL.md"; then
    echo -e "${GREEN}[PASS]${NC} npm pack includes canonical root SKILL.md"
    PASS=$((PASS + 1))
else
    echo -e "${RED}[FAIL]${NC} npm pack MISSING canonical root SKILL.md"
    FAIL=$((FAIL + 1))
fi

if echo "$PACK_OUTPUT" | grep -q "math_book/\|\.pdf"; then
    echo -e "${RED}[FAIL]${NC} npm pack includes PDFs or math_book/"
    FAIL=$((FAIL + 1))
else
    echo -e "${GREEN}[PASS]${NC} no PDFs or math_book/ in npm pack"
    PASS=$((PASS + 1))
fi

if echo "$PACK_OUTPUT" | grep -q "skills/math-research-activator"; then
    echo -e "${RED}[FAIL]${NC} npm pack includes repo-only skills/ (must be excluded: compat stub, never installed)"
    FAIL=$((FAIL + 1))
else
    echo -e "${GREEN}[PASS]${NC} npm pack excludes skills/ (repo-only compat entry)"
    PASS=$((PASS + 1))
fi

# --- CN/EN Pairing ---
echo ""
echo "--- CN/EN File Pairing ---"
for cn_file in $(find commands skills agents lenses knowledge-base design-patterns references -name '*.md' ! -name '*.en.md' 2>/dev/null | sort); do
    en_file="${cn_file%.md}.en.md"
    if [ -f "$en_file" ]; then
        echo -e "${GREEN}[PASS]${NC} $cn_file has EN pair"
        PASS=$((PASS + 1))
    else
        echo -e "${RED}[FAIL]${NC} $cn_file missing EN pair: $en_file"
        FAIL=$((FAIL + 1))
    fi
done

# --- Cross-Reference Integrity ---
echo ""
echo "--- Cross-Reference Integrity ---"
XREF_OUTPUT=$(node <<'NODE'
const fs = require('fs');
const path = require('path');

function walk(dir) {
  let out = [];
  if (!fs.existsSync(dir)) return out;
  for (const ent of fs.readdirSync(dir, { withFileTypes: true })) {
    if (ent.name === '.git' || ent.name === 'node_modules') continue;
    const p = path.join(dir, ent.name);
    if (ent.isDirectory()) out = out.concat(walk(p));
    else if (/\.md$/.test(ent.name)) out.push(p);
  }
  return out;
}

const roots = ['commands', 'skills', 'agents', 'lenses', 'knowledge-base', 'design-patterns', 'references', 'tests/eval'];
const bad = [];
const files = roots.flatMap(walk).concat(['SKILL.md', 'SKILL.en.md']);
for (const file of files) {
  const text = fs.readFileSync(file, 'utf8');
  for (const match of text.matchAll(/`([^`]+)`/g)) {
    const ref = match[1];
    if (
      /^https?:/.test(ref) ||
      ref.includes('*') ||
      ref.includes(' ') ||
      ref.includes('|') ||
      ref.includes('(') ||
      ref.includes('$') ||
      ref === 'math_book/' ||
      ref.endsWith('/math_book/') ||
      !(/\.md$|\/$/.test(ref))
    ) continue;
    const target = path.normalize(path.join(path.dirname(file), ref));
    if (!fs.existsSync(target)) {
      const line = text.slice(0, match.index).split('\n').length;
      bad.push(`${file}:${line} -> \`${ref}\` => ${target}`);
    }
  }
}

if (bad.length) {
  console.log(bad.join('\n'));
  process.exit(1);
}
NODE
)
if [ $? -eq 0 ]; then
    echo -e "${GREEN}[PASS]${NC} All backtick path references resolve"
    PASS=$((PASS + 1))
else
    echo "$XREF_OUTPUT"
    echo -e "${RED}[FAIL]${NC} Missing backtick path references"
    FAIL=$((FAIL + 1))
fi

# --- v3.0.1 Additions ---
echo ""
echo "--- v3.0.1 Additions ---"
check_contains "SKILL.md" '主语言'
check_contains "SKILL.en.md" 'primary language'
check_file "tests/eval/mixed-language-routing.md"

# --- v3.1.0 Additions ---
echo ""
echo "--- v3.1.0 Additions ---"
check_contains "SKILL.md" 'Knowledge Gap Protocol'
check_contains "SKILL.en.md" 'Knowledge Gap Protocol'
check_file "references/skill-index.md"
check_file "references/skill-index.en.md"
check_contains "knowledge-base/overview.md" '激活锚点'
check_contains "knowledge-base/overview.en.md" 'Activation Anchor'
check_file "design-patterns/overview.md"
check_file "design-patterns/overview.en.md"
for domain in matrix-analysis optimization differential-geometry lie-theory topology probability information-geometry; do
    check_file "knowledge-base/${domain}/index.md"
    check_file "knowledge-base/${domain}/index.en.md"
done
check_contains "README.md" '不存储数学'
check_contains "README.md" '激活锚点'
check_contains "README.en-US.md" 'does not store mathematics'
check_contains "README.en-US.md" 'Activation Anchor'

# --- Semantic Regression Checks ---
echo ""
echo "--- Semantic Regression Checks ---"
check_contains "design-patterns/compression/low-rank-kv-cache.md" 'O(Lk + kd)'
check_contains "design-patterns/compression/low-rank-kv-cache.en.md" 'O(Lk + kd)'
check_not_contains_regex "design-patterns/compression/low-rank-kv-cache.md" '压缩到.*O(kd)'
check_not_contains_regex "design-patterns/compression/low-rank-kv-cache.en.md" 'to .*O(kd)'
check_not_contains "design-patterns/compression/low-rank-kv-cache.md" 'softmax attention 需从因子重构完整'
check_not_contains "design-patterns/compression/low-rank-kv-cache.en.md" 'must be reconstructed from the factored form'
check_contains "design-patterns/compression/low-rank-kv-cache.md" '因子化 GEMM'
check_contains "design-patterns/compression/low-rank-kv-cache.en.md" 'factorized GEMMs'
check_contains "design-patterns/compression/low-rank-kv-cache.md" 'Eckart-Young 谱范数误差'
check_contains "design-patterns/compression/low-rank-kv-cache.en.md" 'Eckart--Young spectral-norm error'
check_not_contains "design-patterns/compression/low-rank-kv-cache.md" 'Weyl 扰动界保证'
check_not_contains "design-patterns/compression/low-rank-kv-cache.en.md" 'Weyl perturbation bound guarantees'
check_not_contains "knowledge-base/matrix-analysis/low-rank-approximation.md" '需先重构'
check_not_contains "knowledge-base/matrix-analysis/low-rank-approximation.en.md" 'must first reconstruct'
check_contains "knowledge-base/matrix-analysis/low-rank-approximation.md" '主子空间唯一'
check_contains "knowledge-base/matrix-analysis/low-rank-approximation.en.md" 'principal subspace is unique'
check_not_contains "knowledge-base/matrix-analysis/low-rank-approximation.md" '唯一最优解'
check_not_contains "knowledge-base/matrix-analysis/low-rank-approximation.en.md" 'unique optimal solution'
check_contains "knowledge-base/matrix-analysis/low-rank-approximation.md" 'O(mn)'
check_contains "knowledge-base/matrix-analysis/low-rank-approximation.en.md" 'O(mn)'
check_contains "knowledge-base/matrix-analysis/low-rank-approximation.en.md" 'information-bottleneck.en.md'
check_contains "design-patterns/loss/constraint-penalty.md" '不等式乘子必须保持'
check_contains "design-patterns/loss/constraint-penalty.en.md" 'inequality multipliers must satisfy'
check_contains "design-patterns/compression/low-rank-kv-cache.md" 'Q_final'
check_contains "design-patterns/compression/low-rank-kv-cache.en.md" 'Q_final'
check_contains "design-patterns/routing/spectral-clustering-routing.md" 'cdist(X_sample, X_sample)**2'
check_contains "design-patterns/routing/spectral-clustering-routing.en.md" 'cdist(X_sample, X_sample)**2'
check_contains "design-patterns/attention/information-bottleneck-attention.md" 'logistic-normal'
check_contains "design-patterns/attention/information-bottleneck-attention.en.md" 'logistic-normal'
check_contains "design-patterns/compression/spectral-token-pruning.md" '未 mask 且不可约'
check_contains "design-patterns/compression/spectral-token-pruning.en.md" 'unmasked irreducible'
check_not_contains "design-patterns/routing/moe-routing.md" 'X%'
check_not_contains "design-patterns/routing/moe-routing.en.md" 'X%'
check_not_contains "design-patterns/routing/moe-routing.md" '>95%'
check_not_contains "design-patterns/routing/moe-routing.en.md" 'exceeds 95%'
check_not_contains "lenses/spectral.md" '必须使用 Jordan'
check_not_contains "lenses/spectral.en.md" 'Jordan form is required'
check_not_contains "design-patterns/loss/contrastive-loss.md" 'O(1/√N)'
check_not_contains "design-patterns/loss/contrastive-loss.en.md" 'O(1/√N)'
check_contains "design-patterns/overview.md" '严谨性约定'
check_contains "design-patterns/overview.en.md" 'Rigor convention'

# --- Knowledge Card Structure Check (v3.3.2) ---
echo ""
echo "--- Knowledge Card Structure Check ---"
# Each knowledge card (excluding index/overview) must have 6 required sections.
# Chinese cards check Chinese headers; English cards check English headers.
KB_DOMAINS_STRUCT="matrix-analysis optimization differential-geometry lie-theory topology probability information-geometry cryptography algebraic-geometry"
for domain in $KB_DOMAINS_STRUCT; do
    for cn_file in $(find "knowledge-base/${domain}" -name '*.md' ! -name '*.en.md' ! -name 'index.md' 2>/dev/null | sort); do
        missing=""
        grep -q '## 最小定义' "$cn_file" 2>/dev/null || missing="${missing}最小定义 "
        grep -q '## 核心公式' "$cn_file" 2>/dev/null || missing="${missing}核心公式 "
        grep -q '## 适用问题' "$cn_file" 2>/dev/null || missing="${missing}适用问题 "
        if [ "$domain" = "cryptography" ]; then
            grep -q '## 密码学构造与跨域边界' "$cn_file" 2>/dev/null || missing="${missing}密码学构造与跨域边界 "
            grep -q '## 实现注意事项' "$cn_file" 2>/dev/null || missing="${missing}实现注意事项 "
        else
            grep -q '## AI 设计翻译' "$cn_file" 2>/dev/null || missing="${missing}AI设计翻译 "
            grep -q '## 工程可行性' "$cn_file" 2>/dev/null || missing="${missing}工程可行性 "
        fi
        grep -q '## 风险与失效条件' "$cn_file" 2>/dev/null || missing="${missing}风险与失效条件 "
        if [ -z "$missing" ]; then
            echo -e "${GREEN}[PASS]${NC} $cn_file has all 6 required sections"
            PASS=$((PASS + 1))
        else
            echo -e "${RED}[FAIL]${NC} $cn_file missing:$missing"
            FAIL=$((FAIL + 1))
        fi
    done
    for en_file in $(find "knowledge-base/${domain}" -name '*.en.md' ! -name 'index.en.md' 2>/dev/null | sort); do
        missing=""
        grep -q '## Minimal Definition' "$en_file" 2>/dev/null || missing="${missing}Minimal Definition "
        grep -q '## Core Formulas' "$en_file" 2>/dev/null || missing="${missing}Core Formulas "
        grep -q '## Applicable Problems' "$en_file" 2>/dev/null || missing="${missing}Applicable Problems "
        if [ "$domain" = "cryptography" ]; then
            grep -q '## Cryptographic Construction and Cross-Domain Boundary' "$en_file" 2>/dev/null || missing="${missing}Cryptographic Boundary "
            grep -q '## Implementation Considerations' "$en_file" 2>/dev/null || missing="${missing}Implementation Considerations "
        else
            grep -q '## AI Design Translation' "$en_file" 2>/dev/null || missing="${missing}AI Design Translation "
            grep -q '## Engineering Feasibility' "$en_file" 2>/dev/null || missing="${missing}Engineering Feasibility "
        fi
        grep -q '## Risks and Failure Conditions' "$en_file" 2>/dev/null || missing="${missing}Risks and Failure Conditions "
        if [ -z "$missing" ]; then
            echo -e "${GREEN}[PASS]${NC} $en_file has all 6 required sections"
            PASS=$((PASS + 1))
        else
            echo -e "${RED}[FAIL]${NC} $en_file missing:$missing"
            FAIL=$((FAIL + 1))
        fi
    done
done

# --- Design Pattern GPU Relevance Check (v3.3.2) ---
echo ""
echo "--- Design Pattern GPU Relevance Check ---"
# Require an explicit GPU section and at least one quantitative complexity/memory signal.
# Do not require all eight dimensions: irrelevant dimensions must be N/A rather than boilerplate.
for dp_file in $(find design-patterns -name '*.md' ! -name 'overview.md' ! -name 'overview.en.md' 2>/dev/null | sort); do
    missing=""
    grep -qE '^## (GPU 可行性|GPU Feasibility)' "$dp_file" 2>/dev/null || missing="${missing}GPU-section "
    grep -qE 'O\(|FLOPs|[Bb]ytes|显存|[Mm]emory|复杂度|[Cc]omplexity' "$dp_file" 2>/dev/null || missing="${missing}quantitative-signal "
    if [ -z "$missing" ]; then
        echo -e "${GREEN}[PASS]${NC} $dp_file has relevant GPU analysis"
        PASS=$((PASS + 1))
    else
        echo -e "${RED}[FAIL]${NC} $dp_file missing: $missing"
        FAIL=$((FAIL + 1))
    fi
done

# --- Domain Router Isolation Check (v3.3.2) ---
echo ""
echo "--- Domain Router Isolation Check ---"
check_contains "SKILL.md" '不加载密码学锚点/书稿'
check_contains "SKILL.md" '不加载 AI 设计模式'
check_contains "SKILL.en.md" 'Do not load crypto anchors/books'
check_contains "SKILL.en.md" 'Do not load AI design patterns'
check_not_contains_regex "knowledge-base/cryptography/attack-game-framework.md" '^## AI 设计翻译'
check_not_contains_regex "knowledge-base/cryptography/cca-cpa-ae-hierarchy.md" '^## AI 设计翻译'
check_not_contains_regex "knowledge-base/cryptography/reduction-proof-template.md" '^## AI 设计翻译'
check_not_contains_regex "knowledge-base/cryptography/prf-prg-owf.md" '^## AI 设计翻译'
# Verify cryptography layer has structured anchors (not just books)
CRYPTO_ANCHOR_COUNT=$(find "knowledge-base/cryptography" -name '*.md' ! -name '*.en.md' ! -name 'index.md' 2>/dev/null | wc -l)
if [ "$CRYPTO_ANCHOR_COUNT" -ge 4 ]; then
    echo -e "${GREEN}[PASS]${NC} knowledge-base/cryptography/ has $CRYPTO_ANCHOR_COUNT anchor cards (>=4)"
    PASS=$((PASS + 1))
else
    echo -e "${RED}[FAIL]${NC} knowledge-base/cryptography/ has only $CRYPTO_ANCHOR_COUNT anchor cards (need >=4)"
    FAIL=$((FAIL + 1))
fi
# Verify algebraic-geometry layer has anchors
ALGEO_ANCHOR_COUNT=$(find "knowledge-base/algebraic-geometry" -name '*.md' ! -name '*.en.md' ! -name 'index.md' 2>/dev/null | wc -l)
if [ "$ALGEO_ANCHOR_COUNT" -ge 2 ]; then
    echo -e "${GREEN}[PASS]${NC} knowledge-base/algebraic-geometry/ has $ALGEO_ANCHOR_COUNT anchor cards (>=2)"
    PASS=$((PASS + 1))
else
    echo -e "${RED}[FAIL]${NC} knowledge-base/algebraic-geometry/ has only $ALGEO_ANCHOR_COUNT anchor cards (need >=2)"
    FAIL=$((FAIL + 1))
fi

# --- Knowledge Gap Protocol Check (v3.3.2) ---
echo ""
echo "--- Knowledge Gap Protocol Check ---"
check_contains "SKILL.md" 'Knowledge Gap Protocol'
check_contains "SKILL.md" '缺口类型'
check_contains "SKILL.md" '临时卡必须标注 domain'
check_contains "SKILL.en.md" 'Knowledge Gap Protocol'
check_contains "SKILL.en.md" 'temporary card must state its domain'

# --- Progressive Loading Check (v3.3.2) ---
echo ""
echo "--- Progressive Loading Check ---"
check_contains "SKILL.md" '最少但足够'
check_contains "SKILL.md" '不展示内部加载路径'
check_contains "SKILL.md" '普通 A/B/D 场景使用上述检查即可'
check_contains "SKILL.en.md" 'smallest sufficient'
check_contains "SKILL.en.md" 'Do not repeat cards or expose internal load paths'
check_contains "SKILL.en.md" 'ordinary A/B/D tasks'
check_contains "README.md" 'v3.3.2 — 产品化与 npx 安装器'
check_contains "README.en-US.md" 'v3.3.2 — Productization & npx Installer'

# --- Lean Loading Check (v3.3.3) ---
echo ""
echo "--- Lean Loading Check ---"
check_contains "SKILL.md" '精益加载'
check_contains "SKILL.md" '按节读取'
check_contains "SKILL.md" '不设固定输出格式'
check_contains "SKILL.en.md" 'Lean loading'
check_contains "SKILL.en.md" 'Read by section'
check_contains "SKILL.en.md" 'no fixed output format'
check_contains "references/skill-index.md" '精益加载与尺寸提示'
check_contains "references/skill-index.en.md" 'Lean loading and size tiers'

# --- Pre-release Consistency Check (v3.3.2) ---
echo ""
echo "--- Pre-release Consistency Check ---"
check_contains "skills/math-research-activator/SKILL.md" '也用于与 AI 研究有关的数学查询'
check_contains "skills/math-research-activator/SKILL.en.md" 'Also use for mathematics questions tied to AI research'
check_contains "agents/math-critic.md" 'knowledge-base/cryptography/'
check_contains "agents/math-critic.en.md" 'knowledge-base/cryptography/'
check_contains "agents/math-critic.md" '不以 GPU 清单作安全门'
check_contains "agents/math-critic.en.md" 'Never use the GPU checklist as a security gate'
check_contains "references/skill-index.md" '默认 ≤2'
check_contains "references/skill-index.en.md" 'default ≤2'
check_not_contains "tests/eval/should-not-trigger.md" 'Gate 0'
check_contains "knowledge-base/algebraic-geometry/sheaf-cohomology.md" '不能把 $H^1=0$ 笼统写成'
check_contains "knowledge-base/algebraic-geometry/sheaf-cohomology.en.md" 'must not be stated as a blanket'

# --- High-Risk Semantic Regression Checks ---
echo ""
echo "--- High-Risk Semantic Regression Checks ---"
check_contains "knowledge-base/matrix-analysis/projection.md" '一般情形用 Moore--Penrose 伪逆'
check_contains "knowledge-base/matrix-analysis/projection.md" '不是线性投影'
check_not_contains "knowledge-base/matrix-analysis/projection.md" 'ResNet 的正交残差'
check_contains "knowledge-base/cryptography/prf-prg-owf.md" '3 轮给出选择明文意义下的 PRP，4 轮给出'
check_not_contains "knowledge-base/cryptography/prf-prg-owf.md" '通常是 small GEMM'
check_contains "knowledge-base/cryptography/cca-cpa-ae-hierarchy.md" '不能映射成“训练数据量 ≥ 模型参数量”'
check_not_contains "knowledge-base/cryptography/reduction-proof-template.md" '差分隐私假设'
check_contains "references/gpu-friendly-math.md" '`N/A` 不计分'
check_contains "package.json" '"version": "3.3.5"'

# --- v3.3.2 Documentation Discipline Checks ---
echo ""
echo "--- v3.3.2 Documentation Discipline Checks ---"
check_contains "README.md" 'algebraic-geometry/'
check_contains "README.md" 'cryptography/'
check_contains "README.md" 'musings.md'
check_contains "README.md" 'skill-index.md'
check_contains "README.en-US.md" 'algebraic-geometry/'
check_contains "README.en-US.md" 'cryptography/'
check_contains "README.en-US.md" 'musings.en.md'
check_contains "README.en-US.md" 'skill-index.en.md'
check_contains "README.md" '默认 ≤2'
check_contains "README.md" '紧凑审查'
check_contains "README.en-US.md" 'default ≤2'
check_contains "README.en-US.md" 'Compact Review'
check_contains "README.md" 'v3 起改为 15 透镜'
check_contains "README.en-US.md" 'replaced by 15 lenses in v3'
check_contains "README.md" '扩展至 37'
check_contains "README.en-US.md" 'expanded to 37 in v3.2'
check_contains "README.md" 'v3.3.2'
check_contains "README.en-US.md" 'v3.3.2'
# CLAUDE.md is gitignored (machine-local); only check when present
if [ -f "CLAUDE.md" ]; then
    check_contains "CLAUDE.md" 'musings'
    check_contains "CLAUDE.md" 'skill-index'
fi

# --- Count Verification ---
echo ""
echo "--- Count Verification ---"
LENS_CN=$(ls lenses/*.md 2>/dev/null | grep -v '.en.md' | wc -l)
LENS_EN=$(ls lenses/*.en.md 2>/dev/null | wc -l)
KB_CN=$(find knowledge-base -name '*.md' ! -name '*.en.md' ! -name 'overview*' ! -name 'index*' 2>/dev/null | wc -l)
KB_EN=$(find knowledge-base -name '*.en.md' ! -name 'overview.en.md' ! -name 'index.en.md' 2>/dev/null | wc -l)
DP_CN=$(find design-patterns -name '*.md' ! -name '*.en.md' ! -name 'overview*' 2>/dev/null | wc -l)
DP_EN=$(find design-patterns -name '*.en.md' ! -name 'overview.en.md' 2>/dev/null | wc -l)

if [ "$LENS_CN" -eq "$LENS_EN" ]; then
    echo -e "${GREEN}[PASS]${NC} Lenses: $LENS_CN CN = $LENS_EN EN"
    PASS=$((PASS + 1))
else
    echo -e "${RED}[FAIL]${NC} Lenses: $LENS_CN CN ≠ $LENS_EN EN"
    FAIL=$((FAIL + 1))
fi

if [ "$KB_CN" -eq "$KB_EN" ]; then
    echo -e "${GREEN}[PASS]${NC} Knowledge cards: $KB_CN CN = $KB_EN EN"
    PASS=$((PASS + 1))
else
    echo -e "${RED}[FAIL]${NC} Knowledge cards: $KB_CN CN ≠ $KB_EN EN"
    FAIL=$((FAIL + 1))
fi

# v3.3.5 expected count: 37 shared (8 domains) + 4 crypto = 41
EXPECTED_KB=41
if [ "$KB_CN" -eq "$EXPECTED_KB" ]; then
    echo -e "${GREEN}[PASS]${NC} Knowledge cards count = $EXPECTED_KB (expected for v3.3.5)"
    PASS=$((PASS + 1))
else
    echo -e "${YELLOW}[WARN]${NC} Knowledge cards count = $KB_CN (expected $EXPECTED_KB for v3.3.5)"
    WARN=$((WARN + 1))
fi

if [ "$DP_CN" -eq "$DP_EN" ]; then
    echo -e "${GREEN}[PASS]${NC} Design patterns: $DP_CN CN = $DP_EN EN"
    PASS=$((PASS + 1))
else
    echo -e "${RED}[FAIL]${NC} Design patterns: $DP_CN CN ≠ $DP_EN EN"
    FAIL=$((FAIL + 1))
fi

echo -e "  ${GREEN}[INFO]${NC} Totals: $LENS_CN lenses, $KB_CN knowledge cards, $DP_CN design patterns"

# --- Results ---
echo ""
echo "========================================"
echo "  Results: $PASS passed, $FAIL failed, $WARN warnings"
echo "========================================"

if [ $FAIL -eq 0 ]; then
    echo "All checks passed!"
    exit 0
else
    echo "Some checks failed!"
    exit 1
fi
