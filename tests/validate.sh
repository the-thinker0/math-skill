#!/bin/bash
# Math Skill Validation Script (v3.0.0)
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
    if grep -q "$2" "$1" 2>/dev/null; then
        echo -e "${GREEN}[PASS]${NC} $1 contains '$2'"
        PASS=$((PASS + 1))
    else
        echo -e "${RED}[FAIL]${NC} $1 does NOT contain '$2'"
        FAIL=$((FAIL + 1))
    fi
}

check_not_contains() {
    if grep -q "$2" "$1" 2>/dev/null; then
        echo -e "${RED}[FAIL]${NC} $1 still contains '$2'"
        FAIL=$((FAIL + 1))
    else
        echo -e "${GREEN}[PASS]${NC} $1 does not contain '$2'"
        PASS=$((PASS + 1))
    fi
}

echo "========================================"
echo "  Math Skill Validation (v3.0.0)"
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

# --- Activator ---
echo ""
echo "--- Activator ---"
check_file "skills/math-research-activator/SKILL.md"
check_file "skills/math-research-activator/SKILL.en.md"
check_contains "skills/math-research-activator/SKILL.md" '三层正交架构'
check_contains "skills/math-research-activator/SKILL.md" '思想透镜'
check_contains "skills/math-research-activator/SKILL.md" '数学知识'
check_contains "skills/math-research-activator/SKILL.md" '设计翻译'
check_contains "skills/math-research-activator/SKILL.en.md" 'Thinking Lenses'
check_contains "skills/math-research-activator/SKILL.en.md" 'Math Knowledge'
check_contains "skills/math-research-activator/SKILL.en.md" 'Design Translation'

# --- Commands ---
echo ""
echo "--- Commands ---"
check_file "commands/ask.md"
check_contains "commands/ask.md" 'math-research-activator'
check_file "commands/ask.en.md"
check_contains "commands/ask.en.md" 'SKILL.en.md'

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
KB_DOMAINS="matrix-analysis optimization differential-geometry lie-theory topology probability information-geometry"
KB_TOTAL=0
for domain in $KB_DOMAINS; do
    check_dir "knowledge-base/${domain}"
    count=$(find "knowledge-base/${domain}" -name "*.md" ! -name "*.en.md" 2>/dev/null | wc -l)
    en_count=$(find "knowledge-base/${domain}" -name "*.en.md" 2>/dev/null | wc -l)
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
for book in abstract-algebra algebraic-geometry-rising-sea differential-geometry matrix-analysis micro-lie-theory optimization-ml smooth-manifolds; do
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
PACK_OUTPUT=$(npm pack --dry-run 2>&1)
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

if echo "$PACK_OUTPUT" | grep -q "math_book/\|\.pdf"; then
    echo -e "${RED}[FAIL]${NC} npm pack includes PDFs or math_book/"
    FAIL=$((FAIL + 1))
else
    echo -e "${GREEN}[PASS]${NC} no PDFs or math_book/ in npm pack"
    PASS=$((PASS + 1))
fi

# --- CN/EN Pairing ---
echo ""
echo "--- CN/EN File Pairing ---"
for cn_file in lenses/*.md; do
    [ "${cn_file%.en.md}" != "$cn_file" ] && continue
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
XREF_FAIL=0
# Check that lens references in design patterns point to existing files
for dp_file in design-patterns/*/*.md; do
    [ "${dp_file%.en.md}" != "$dp_file" ] && continue
    refs=$(grep -oE 'lenses/[a-z-]+\.md' "$dp_file" 2>/dev/null)
    for ref in $refs; do
        if [ ! -f "$ref" ]; then
            echo -e "${RED}[FAIL]${NC} $dp_file references missing $ref"
            FAIL=$((FAIL + 1))
            XREF_FAIL=$((XREF_FAIL + 1))
        fi
    done
    kb_refs=$(grep -oE 'knowledge-base/[a-z-]+/[a-z-]+\.md' "$dp_file" 2>/dev/null)
    for ref in $kb_refs; do
        if [ ! -f "$ref" ]; then
            echo -e "${RED}[FAIL]${NC} $dp_file references missing $ref"
            FAIL=$((FAIL + 1))
            XREF_FAIL=$((XREF_FAIL + 1))
        fi
    done
done
if [ $XREF_FAIL -eq 0 ]; then
    echo -e "${GREEN}[PASS]${NC} All cross-references resolve"
    PASS=$((PASS + 1))
fi

# --- v3.0.1 Additions ---
echo ""
echo "--- v3.0.1 Additions ---"
check_contains "skills/math-research-activator/SKILL.md" '混合输入'
check_contains "skills/math-research-activator/SKILL.en.md" 'Mixed-Input'
check_file "tests/eval/mixed-language-routing.md"

# --- v3.1.0 Additions ---
echo ""
echo "--- v3.1.0 Additions ---"
check_contains "skills/math-research-activator/SKILL.md" '知识缺口协议'
check_contains "skills/math-research-activator/SKILL.en.md" 'Knowledge Gap Protocol'
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
