#!/usr/bin/env bash
# Wormagent installer — Linux x86_64
# Usage: curl -fsSL https://wormagent.net/install | bash
set -euo pipefail

REPO="BlackXV2vip/wormagent-site"
BIN_URL="https://github.com/${REPO}/releases/latest/download/Wormagent-linux-x64"
INSTALL_DIR="${WORMAGENT_INSTALL_DIR:-$HOME/.Wormagent/bin}"
NO_PATH=false
[[ "${1:-}" == "--no-modify-path" ]] && NO_PATH=true

BOLD=$'\033[1m'; DIM=$'\033[2m'; RED=$'\033[31m'; GRN=$'\033[32m'; NC=$'\033[0m'

case "$(uname -s)" in
  Linux)  OS=linux ;;
  Darwin) OS=darwin ;;
  *) echo "${RED}Unsupported OS: $(uname -s)${NC}" >&2; exit 1 ;;
esac
case "$(uname -m)" in
  x86_64|amd64) ARCH=x64 ;;
  arm64|aarch64) ARCH=arm64 ;;
  *) echo "${RED}Unsupported CPU: $(uname -m)${NC}" >&2; exit 1 ;;
esac
if [ "$OS" != "linux" ] || [ "$ARCH" != "x64" ]; then
  echo "${RED}Current bundle supports Linux x86_64 only (detected: ${OS}/${ARCH}).${NC}" >&2
  exit 1
fi

echo "${DIM}Installing${NC} Wormagent ${DIM}→${NC} ${INSTALL_DIR}/Wormagent"
mkdir -p "$INSTALL_DIR"

TMP="$(mktemp -d)"; trap 'rm -rf "$TMP"' EXIT
if command -v curl >/dev/null 2>&1; then
  curl -fL --progress-bar "$BIN_URL" -o "$TMP/wormagent-bin"
else
  wget -q --show-progress "$BIN_URL" -O "$TMP/wormagent-bin"
fi
chmod 755 "$TMP/wormagent-bin"
mv "$TMP/wormagent-bin" "$INSTALL_DIR/wormagent-bin"

# Launcher: shows the WormAgent banner on interactive start, then runs the binary.
cat > "$INSTALL_DIR/Wormagent" <<'LAUNCHER'
#!/usr/bin/env bash
# WormAgent launcher — prints the WormAgent banner on interactive start, then runs the real binary.
set -euo pipefail
SELF_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BIN="$SELF_DIR/wormagent-bin"
[ -x "$BIN" ] || BIN="$SELF_DIR/opencode"

banner() {
  [ -n "${WORMAGENT_NO_BANNER:-}" ] && return 0
  [ -t 1 ] || return 0
  local l1='█   █ █▀▀█ █▀▀█ █▄ ▄█ █▀▀█ █▀▀█ █▀▀▀ █  █ ▀▀█▀▀'
  local l2='█ █ █ █  █ █▀▀▄ █ ▀ █ █▀▀█ █ ▀▀ █▀▀  █▄ █   █  '
  local l3=' ▀ ▀  ▀▀▀▀ ▀  ▀ ▀   ▀ ▀  ▀ ▀▀▀▀ ▀▀▀▀ ▀ ▀▀   ▀  '
  printf '\033[38;5;209m%s\n%s\n%s\033[0m\n' "$l1" "$l2" "$l3"
  printf '  \033[2mterminal coding agent\033[0m\n\n'
}

[ $# -eq 0 ] && banner
exec "$BIN" "$@"
LAUNCHER
chmod 755 "$INSTALL_DIR/Wormagent"

if [ "$NO_PATH" = false ]; then
  for rc in "$HOME/.bashrc" "$HOME/.zshrc"; do
    [ -f "$rc" ] || continue
    grep -q "$INSTALL_DIR" "$rc" || echo "export PATH=\"$INSTALL_DIR:\$PATH\"" >> "$rc"
  done
fi

echo
echo "${GRN}${BOLD}✔ Installed${NC} Wormagent to ${INSTALL_DIR}/Wormagent"
echo
echo "  export PATH=\"$INSTALL_DIR:\$PATH\""
echo "  cd <project> && Wormagent"
echo
echo "${DIM}Docs: https://wormagent.net${NC}"
