#!/bin/bash
# Math Skill Validation Script
# Checks that all required files exist and references are correct

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

echo "========================================"
echo "  Math Skill Validation"
echo "========================================"
echo ""

# Check infrastructure files
echo "--- Infrastructure ---"
check_file "package.json"

# Check skills directories and files
echo ""
echo "--- Skills ---"
SKILLS="axiomatization abstraction logic-deduction modeling optimization probability-statistics transformation symmetry-invariance induction-analogy algorithmic-thinking information-theory game-theory causal-inference topological-thinking discrete-combinatorial meta-selector"

for skill in $SKILLS; do
    check_dir "skills/$skill"
    check_file "skills/$skill/SKILL.md"
    check_file "skills/$skill/original-texts.md"

    # Check that SKILL.md has proper frontmatter
    check_content "skills/$skill/SKILL.md" "^---"
    check_content "skills/$skill/SKILL.md" "name:"
    check_content "skills/$skill/SKILL.md" "description:"
done

# Check command files
echo ""
echo "--- Commands ---"
COMMANDS="axiomatization abstraction logic-deduction modeling optimization probability-statistics transformation symmetry-invariance induction-analogy algorithmic-thinking information-theory game-theory causal-inference topological-thinking discrete-combinatorial ask"

for cmd in $COMMANDS; do
    check_file "commands/$cmd.md"

    # Check that command references the correct skill
    # 'ask' command references 'meta-selector' skill, not 'ask' skill
    if [ "$cmd" = "ask" ]; then
        check_content "commands/$cmd.md" "skills/meta-selector/SKILL.md"
    else
        check_content "commands/$cmd.md" "skills/$cmd/SKILL.md"
    fi
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

# Check tests
echo ""
echo "--- Tests ---"
check_dir "tests"
check_file "tests/validate.sh"
check_file "tests/validate.ps1"

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
check_content "package.json" '"keywords"'
check_content "package.json" '"repository"'
check_content "package.json" '"author"'
check_content "package.json" '"scripts"'

# Check npm pack output
echo ""
echo "--- npm Pack Check ---"
if command -v npm &>/dev/null; then
    PACK_OUTPUT=$(npm pack --dry-run 2>/dev/null) || true
    PACK_EXIT=$?
    if [ $PACK_EXIT -eq 0 ]; then
        echo -e "${GREEN}[PASS]${NC} npm pack --dry-run succeeded"
        PASS=$((PASS + 1))

        # Check that essential files are included in the pack
        for item in "README.md" "LICENSE" "commands/" "skills/" "agents/" "knowledge-base/" "docs/"; do
            if echo "$PACK_OUTPUT" | grep -q "$item"; then
                echo -e "${GREEN}[PASS]${NC} npm pack includes $item"
                PASS=$((PASS + 1))
            else
                echo -e "${RED}[FAIL]${NC} npm pack missing $item"
                FAIL=$((FAIL + 1))
            fi
        done
    else
        echo -e "${YELLOW}[WARN]${NC} npm pack --dry-run failed"
        WARN=$((WARN + 1))
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
