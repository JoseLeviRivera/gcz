#!/usr/bin/env bash

# =========================================================
# GCZ - Git Conventional Commit CLI
# =========================================================
# Features:
# - Conventional Commits
# - Interactive menu with fzf
# - ANSI colors
# - Branch auto-detection
# - Commit validation
# - Optional scope/body/footer
# - Staged files preview
# - Lightweight Commitizen alternative
# =========================================================

set -e

# =========================
# COLORS
# =========================

RED="\033[1;31m"
GREEN="\033[1;32m"
YELLOW="\033[1;33m"
BLUE="\033[1;34m"
CYAN="\033[1;36m"
WHITE="\033[1;37m"
RESET="\033[0m"

# =========================
# BANNER
# =========================

banner() {
cat << "EOF"

   ______  ______ _____
  / ____/ / ____//__  /
 / / __  / /      / / 
/ /_/ / / /___   / /__
\____/  \____/  /____/

 Git Conventional Commit CLI

EOF
}

# =========================
# CHECK DEPENDENCIES
# =========================

check_dependencies() {

  if ! command -v git &> /dev/null; then
    echo -e "${RED}git is not installed${RESET}"
    exit 1
  fi

  if ! command -v fzf &> /dev/null; then
    echo -e "${RED}fzf is not installed${RESET}"
    echo -e "${YELLOW}Install:${RESET}"
    echo "sudo apt install fzf"
    exit 1
  fi
}

# =========================
# CHECK GIT REPOSITORY
# =========================

check_git_repo() {
  if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo -e "${RED}This is not a git repository${RESET}"
    exit 1
  fi
}

# =========================
# SHOW STAGED FILES
# =========================

show_changed_files() {

  echo -e "\n${CYAN}Changed files:${RESET}"

  FILES=$(git status --short)

  if [ -z "$FILES" ]; then
    echo -e "${YELLOW}No changes detected${RESET}"
  else
    echo "$FILES"
  fi
}

# =========================
# DETECT BRANCH TYPE
# =========================

detect_branch_type() {

  BRANCH=$(git branch --show-current)

  case "$BRANCH" in
    feature/*)
      DEFAULT_TYPE="feat"
      ;;
    fix/*|bugfix/*)
      DEFAULT_TYPE="fix"
      ;;
    hotfix/*)
      DEFAULT_TYPE="fix"
      ;;
    refactor/*)
      DEFAULT_TYPE="refactor"
      ;;
    docs/*)
      DEFAULT_TYPE="docs"
      ;;
    test/*)
      DEFAULT_TYPE="test"
      ;;
    chore/*)
      DEFAULT_TYPE="chore"
      ;;
    *)
      DEFAULT_TYPE=""
      ;;
  esac
}

# =========================
# SELECT TYPE
# =========================

select_commit_type() {

  TYPES=$(cat << EOF
feat       New feature
fix        Bug fix
docs       Documentation changes
style      Formatting changes
refactor   Code refactoring
perf       Performance improvements
test       Add/update tests
build      Build system changes
ci         CI/CD changes
chore      Maintenance tasks
revert     Revert commit
EOF
)

  SELECTED=$(echo "$TYPES" | fzf \
    --height=40% \
    --border \
    --prompt="Commit Type > " \
    --header="Select Conventional Commit Type")

  COMMIT_TYPE=$(echo "$SELECTED" | awk '{print $1}')

  if [ -z "$COMMIT_TYPE" ]; then
    echo -e "${RED}Commit type required${RESET}"
    exit 1
  fi
}

# =========================
# AUTO SCOPE
# =========================

suggest_scope() {

  SCOPE=$(git diff --cached --name-only \
    | head -n 1 \
    | cut -d '/' -f1)

}

# =========================
# INPUTS
# =========================

read_inputs() {

  echo ""

  if [ -n "$DEFAULT_TYPE" ]; then
    echo -e "${BLUE}Detected branch type:${RESET} $DEFAULT_TYPE"
  fi

  echo -e "${CYAN}Type:${RESET} $COMMIT_TYPE"

  read -rp "Scope [$SCOPE]: " USER_SCOPE

  if [ -n "$USER_SCOPE" ]; then
    SCOPE="$USER_SCOPE"
  fi

  while true; do

    read -rp "Description: " DESCRIPTION

    if [ -n "$DESCRIPTION" ]; then
      break
    fi

    echo -e "${RED}Description cannot be empty${RESET}"
  done

  echo ""
  read -rp "Body (optional): " BODY

  echo ""
  read -rp "Footer (optional): " FOOTER
}

# =========================
# VALIDATE MESSAGE
# =========================

validate_commit() {

  if [[ ! "$DESCRIPTION" =~ ^[a-zA-Z0-9] ]]; then
    echo -e "${RED}Invalid description${RESET}"
    exit 1
  fi
}

# =========================
# BUILD COMMIT
# =========================

build_commit_message() {

  if [ -n "$SCOPE" ]; then
    COMMIT_MESSAGE="${COMMIT_TYPE}(${SCOPE}): ${DESCRIPTION}"
  else
    COMMIT_MESSAGE="${COMMIT_TYPE}: ${DESCRIPTION}"
  fi

  if [ -n "$BODY" ]; then
    COMMIT_MESSAGE="${COMMIT_MESSAGE}

${BODY}"
  fi

  if [ -n "$FOOTER" ]; then
    COMMIT_MESSAGE="${COMMIT_MESSAGE}

${FOOTER}"
  fi
}

# =========================
# PREVIEW
# =========================

preview_commit() {

  echo ""
  echo -e "${GREEN}========================================${RESET}"
  echo -e "${GREEN}Generated Commit${RESET}"
  echo -e "${GREEN}========================================${RESET}"
  echo ""

  echo "$COMMIT_MESSAGE"

  echo ""
}

# =========================
# EXECUTE COMMIT
# =========================

execute_commit() {

  git add -A
  git commit -m "$COMMIT_MESSAGE"

  echo ""
  echo -e "${GREEN}Commit created successfully${RESET}"
}

# =========================
# MAIN
# =========================

main() {

  TARGET_DIR="${1:-.}"

  cd "$TARGET_DIR"

  banner

  check_dependencies
  check_git_repo

  show_changed_files

  detect_branch_type

  select_commit_type

  if [ -n "$DEFAULT_TYPE" ] && [ "$DEFAULT_TYPE" != "$COMMIT_TYPE" ]; then
    echo -e "${YELLOW}Warning:${RESET} branch suggests '$DEFAULT_TYPE'"
  fi

  suggest_scope

  read_inputs

  validate_commit

  build_commit_message

  preview_commit

  read -rp "Proceed with commit? (y/n): " CONFIRM

  if [[ "$CONFIRM" =~ ^[Yy]$ ]]; then
    execute_commit
  else
    echo -e "${RED}Commit canceled${RESET}"
  fi
}

main "$@"