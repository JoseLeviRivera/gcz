#!/usr/bin/env bash

# =========================================================
# GCZ SHELL INSTALLER
# =========================================================

set -e

GREEN="\033[1;32m"
YELLOW="\033[1;33m"
RED="\033[1;31m"
BLUE="\033[1;34m"
RESET="\033[0m"

echo -e "${BLUE}"
echo "======================================="
echo "         GCZ INSTALLER"
echo "======================================="
echo -e "${RESET}"

# =========================
# CHECK GCZ
# =========================

if ! command -v gcz &> /dev/null; then
  echo -e "${RED}gcz is not installed globally${RESET}"
  echo ""
  echo "Install first:"
  echo "sudo cp gcz.sh /usr/local/bin/gcz"
  echo "sudo chmod +x /usr/local/bin/gcz"
  exit 1
fi

echo -e "${GREEN}gcz detected:${RESET} $(which gcz)"

# =========================
# DETECT SHELL
# =========================

SHELL_NAME=$(basename "$SHELL")

case "$SHELL_NAME" in
  bash)
    SHELL_RC="$HOME/.bashrc"
    ;;
  zsh)
    SHELL_RC="$HOME/.zshrc"
    ;;
  *)
    echo -e "${RED}Unsupported shell:${RESET} $SHELL_NAME"
    exit 1
    ;;
esac

echo -e "${YELLOW}Shell detected:${RESET} $SHELL_NAME"

# =========================
# PREVENT DUPLICATES
# =========================

if grep -q "GCZ GIT OVERRIDE" "$SHELL_RC"; then
  echo -e "${YELLOW}GCZ already configured${RESET}"
  exit 0
fi

# =========================
# APPEND CONFIG
# =========================

cat << 'EOF' >> "$SHELL_RC"

# =========================================================
# GCZ GIT OVERRIDE
# =========================================================

git() {

  if [[ "$1" == "commit" ]]; then

    for arg in "$@"; do
      if [[ "$arg" == "-m" ]]; then
        command git "$@"
        return
      fi
    done

    shift

    gcz

    return
  fi

  command git "$@"
}

EOF

echo -e "${GREEN}GCZ added to:${RESET} $SHELL_RC"

# =========================
# RELOAD
# =========================

echo ""
echo -e "${YELLOW}Reload shell:${RESET}"

echo ""
echo "Run:"
echo ""

if [ "$SHELL_NAME" = "bash" ]; then
  echo "source ~/.bashrc"
else
  echo "source ~/.zshrc"
fi

echo ""
echo -e "${GREEN}Done.${RESET}"