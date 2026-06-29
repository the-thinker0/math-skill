#!/bin/bash
# Math Skill Validation Script (v2)
# Checks that all required files exist, references are correct, the
# math-research-activator entry is wired up, the references/ layer is present,
# and that npm pack ships no PDFs / math_book/ content.

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

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

check_content() {
    if grep -q "$2" "$1" 2>/dev/null; then
        echo -e "${GREEN}[PASS]${NC} $1 contains '$2'"
        PASS=$((PASS + 1))
    else
        echo -e "${RED}[FAIL]${NC} $1 missing '$2'"
        FAIL=$((FAIL + 1))
    fi
}

check_absent() {
    # $1 = haystack text, $2 = pattern that must NOT appear
    if echo "$1" | grep -qE "$2"; then
        echo -e "${RED}[FAIL]${NC} forbidden pattern '$2' present"
        FAIL=$((FAIL + 1))
    else
        echo -e "${GREEN}[PASS]${NC} '$2' correctly absent"
        PASS=$((PASS + 1))
    fi
}

check_no_output() {
    # $1 = command output, $2 = human-readable check name
    if [ -n "$1" ]; then
        echo -e "${RED}[FAIL]${NC} $2"
        echo "$1"
        FAIL=$((FAIL + 1))
    else
        echo -e "${GREEN}[PASS]${NC} $2"
        PASS=$((PASS + 1))
    fi
}

echo "========================================"
echo "  Math Skill Validation (v2)"
echo "========================================"
echo ""

# Check infrastructure files
echo "--- Infrastructure ---"
check_file "package.json"

# Check skills directories and files
echo ""
echo "--- Skills ---"
SKILLS="axiomatization abstraction logic-deduction modeling optimization probability-statistics transformation symmetry-invariance induction-analogy algorithmic-thinking information-theory game-theory causal-inference topological-thinking discrete-combinatorial math-research-activator"

for skill in $SKILLS; do
    check_dir "skills/$skill"
    check_file "skills/$skill/SKILL.md"
    check_file "skills/$skill/original-texts.md"

    # Check that SKILL.md has proper frontmatter
    check_content "skills/$skill/SKILL.md" "^---"
    check_content "skills/$skill/SKILL.md" "name:"
    check_content "skills/$skill/SKILL.md" "description:"
done

# v2: no skill should still carry life-mode body content
echo ""
echo "--- Life-Mode Removal Check ---"
LIFE_LEAK=0
for skill in $SKILLS; do
    hits=$(grep -ciE '生活模式|生活触发|生活输出格式|Life Mode|Life trigger' "skills/$skill/SKILL.md" 2>/dev/null)
    if [ "$hits" -gt 0 ]; then
        echo -e "${RED}[FAIL]${NC} skills/$skill/SKILL.md still has $hits life-mode line(s)"
        FAIL=$((FAIL + 1))
        LIFE_LEAK=$((LIFE_LEAK + 1))
    fi
done
if [ "$LIFE_LEAK" -eq 0 ]; then
    echo -e "${GREEN}[PASS]${NC} no skill retains life-mode body content"
    PASS=$((PASS + 1))
fi

# v2: command files must not carry life-mode residue either
echo ""
echo "--- Command Life-Mode Removal Check ---"
CMD_LIFE_LEAK=0
for f in commands/*.md; do
    [ -f "$f" ] || continue
    hits=$(grep -ciE '生活模式|生活触发|生活输出格式|Life Mode|Life trigger' "$f" 2>/dev/null)
    if [ "$hits" -gt 0 ]; then
        echo -e "${RED}[FAIL]${NC} $f still has $hits life-mode line(s)"
        FAIL=$((FAIL + 1))
        CMD_LIFE_LEAK=$((CMD_LIFE_LEAK + 1))
    fi
done
if [ "$CMD_LIFE_LEAK" -eq 0 ]; then
    echo -e "${GREEN}[PASS]${NC} no command retains life-mode body content"
    PASS=$((PASS + 1))
fi

# v2: every weapon (not the activator router) must carry a modern-math activation hook
echo ""
echo "--- Modern-Math Activation Hook ---"
WEAPONS15="axiomatization abstraction logic-deduction modeling optimization probability-statistics transformation symmetry-invariance induction-analogy algorithmic-thinking information-theory game-theory causal-inference topological-thinking discrete-combinatorial"
for w in $WEAPONS15; do
    check_content "skills/$w/SKILL.md" "现代数学激活"
done

# v2: every skill must explicitly use the official GPU
# eight-dimension vocabulary from references/gpu-friendly-math.md.
echo ""
echo "--- GPU Eight-Dimension Coverage ---"
GPU_DIMS="张量化|GEMM 可映射|复杂度|显存与 KV-Cache|低精度稳定|并行与通信|稀疏结构|算子融合"
for skill in $SKILLS; do
    missing=""
    OLD_IFS="$IFS"
    IFS='|'
    for dim in $GPU_DIMS; do
        if ! grep -q "$dim" "skills/$skill/SKILL.md"; then
            missing="$missing $dim"
        fi
    done
    IFS="$OLD_IFS"
    if [ -n "$missing" ]; then
        echo -e "${RED}[FAIL]${NC} skills/$skill/SKILL.md missing GPU dimension(s):$missing"
        FAIL=$((FAIL + 1))
    else
        echo -e "${GREEN}[PASS]${NC} skills/$skill/SKILL.md covers official GPU eight dimensions"
        PASS=$((PASS + 1))
    fi
done

# Check command files
echo ""
echo "--- Commands ---"
COMMANDS="axiomatization abstraction logic-deduction modeling optimization probability-statistics transformation symmetry-invariance induction-analogy algorithmic-thinking information-theory game-theory causal-inference topological-thinking discrete-combinatorial ask"

for cmd in $COMMANDS; do
    check_file "commands/$cmd.md"

    # 'ask' command routes to the math-research-activator skill
    if [ "$cmd" = "ask" ]; then
        check_content "commands/$cmd.md" "../skills/math-research-activator/SKILL.md"
    else
        check_content "commands/$cmd.md" "../skills/$cmd/SKILL.md"
    fi
done

# Check references layer (methodology + book activation)
echo ""
echo "--- References Layer ---"
check_dir "references"
check_file "references/agentic-workflow.md"
check_file "references/gpu-friendly-math.md"
# v2: the activator must wire to the GPU eight-dimension gate (source of truth)
check_content "skills/math-research-activator/SKILL.md" "gpu-friendly-math.md"
check_dir "references/books"
BOOKS="abstract-algebra algebraic-geometry-rising-sea differential-geometry matrix-analysis micro-lie-theory optimization-ml smooth-manifolds"
for book in $BOOKS; do
    check_file "references/books/$book.md"
done

# Check knowledge base
echo ""
echo "--- Knowledge Base ---"
check_dir "knowledge-base"
check_file "knowledge-base/overview.md"

# Check agents
echo ""
echo "--- Agents ---"
check_dir "agents"
check_file "agents/math-critic.md"
# v2: math-critic must carry the GPU-feasibility + modern-math dimensions
check_content "agents/math-critic.md" "GPU 可行性审视"
check_content "agents/math-critic.md" "现代数学激活审视"

# Check tests
echo ""
echo "--- Tests ---"
check_dir "tests"
check_file "tests/validate.sh"
check_file "tests/validate.ps1"

echo ""
echo "--- Path Hygiene ---"
ABS_PATH_PATTERN='/home/[[:alnum:]_.-]+'
ABS_PATH_HITS=$(grep -RInE --exclude-dir=.git --exclude-dir=.deepseek --exclude-dir=math_book --exclude-dir=node_modules "$ABS_PATH_PATTERN" . 2>/dev/null || true)
check_no_output "$ABS_PATH_HITS" "no absolute local paths are present"

BROKEN_SKILL_REFS=$(grep -RIn 'references/' skills/*/SKILL.md 2>/dev/null | grep -v '../../references/' || true)
check_no_output "$BROKEN_SKILL_REFS" "skill reference paths are relative to each SKILL.md"

# v2: every ../../references/*.md link from a SKILL.md must resolve to a real file
BROKEN_REFS=""
for ref in $(grep -rhoE '\.\./\.\./references/[A-Za-z0-9/_.-]+\.md' skills/*/SKILL.md 2>/dev/null | sort -u); do
    target="${ref#\.\./\.\./}"
    [ -f "$target" ] || BROKEN_REFS="$BROKEN_REFS $ref"
done
check_no_output "$BROKEN_REFS" "all skills -> references links resolve to existing files"

# Check docs
echo ""
echo "--- Documentation ---"
check_dir "docs"
check_file "docs/CLAUDE.md"
check_file "README.md"
check_file "LICENSE"

# Check npm package files
echo ""
echo "--- npm Package ---"
check_file ".npmignore"
check_content "package.json" '"files"'
check_content "package.json" '"references/"'
check_content "package.json" '"keywords"'
check_content "package.json" '"repository"'
check_content "package.json" '"author"'
check_content "package.json" '"scripts"'

# Check npm pack output
echo ""
echo "--- npm Pack Check ---"
if command -v npm &>/dev/null; then
    # npm prints the tarball contents to stderr ("npm notice ..."), so we must
    # capture 2>&1 — otherwise the file list is discarded and every item check
    # false-fails even though the pack succeeds.
    PACK_CACHE="${TMPDIR:-/tmp}/math-skill-npm-cache"
    mkdir -p "$PACK_CACHE"
    PACK_OUTPUT=$(npm_config_cache="$PACK_CACHE" npm pack --dry-run 2>&1)
    PACK_EXIT=$?
    if [ $PACK_EXIT -eq 0 ]; then
        echo -e "${GREEN}[PASS]${NC} npm pack --dry-run succeeded"
        PASS=$((PASS + 1))

        # Check that essential files are included in the pack
        for item in "README.md" "LICENSE" "commands/" "skills/" "agents/" "knowledge-base/" "references/" "docs/"; do
            if echo "$PACK_OUTPUT" | grep -q "$item"; then
                echo -e "${GREEN}[PASS]${NC} npm pack includes $item"
                PASS=$((PASS + 1))
            else
                echo -e "${RED}[FAIL]${NC} npm pack missing $item"
                FAIL=$((FAIL + 1))
            fi
        done

        # v2: PDFs / math_book/ must NEVER ship (copyright + 110MB)
        check_absent "$PACK_OUTPUT" "math_book/|\\.pdf"
    else
        echo -e "${RED}[FAIL]${NC} npm pack --dry-run failed"
        echo "$PACK_OUTPUT"
        FAIL=$((FAIL + 1))
    fi
else
    echo -e "${YELLOW}[WARN]${NC} npm not found, skipping pack check"
    WARN=$((WARN + 1))
fi

# Summary
echo ""
echo "========================================"
echo -e "  Results: ${GREEN}$PASS passed${NC}, ${RED}$FAIL failed${NC}, ${YELLOW}$WARN warnings${NC}"
echo "========================================"

if [ $FAIL -gt 0 ]; then
    exit 1
fi

echo -e "${GREEN}All checks passed!${NC}"
exit 0
