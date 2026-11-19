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
if [ ! -x "$BIN" ]; then
  BIN="$(ls -1 "$SELF_DIR"/Wormagent-v* 2>/dev/null | sort -V | tail -1 || true)"
fi

banner() {
  [ -n "${WORMAGENT_NO_BANNER:-}" ] && return 0
  [ -t 1 ] || return 0
  local l1='█   █ █▀▀█ █▀▀█ █▄ ▄█ █▀▀█ █▀▀█ █▀▀▀ █  █ ▀▀█▀▀'
  local l2='█ █ █ █  █ █▀▀▄ █ ▀ █ █▀▀█ █ ▀▀ █▀▀  █▄ █   █  '
  local l3=' ▀ ▀  ▀▀▀▀ ▀  ▀ ▀   ▀ ▀  ▀ ▀▀▀▀ ▀▀▀▀ ▀ ▀▀   ▀  '
  printf '[38;5;209m%s
%s
%s[0m
' "$l1" "$l2" "$l3"
  printf '  [2mterminal coding agent[0m

'
}

# Show the banner only when an interactive TUI is about to start:
# no arguments, or a directory argument. Never for subcommands or flags.
show_banner=false
if [ $# -eq 0 ]; then
  show_banner=true
else
  case "$1" in
    upgrade|update|uninstall|acp|api|debug|auth|mcp|plugin|models|stats|mini|run|session|service|reload|pair|serve) ;;
    -*) ;;
    *) [ -d "$1" ] && show_banner=true ;;
  esac
fi
[ "$show_banner" = true ] && banner

[ -n "$BIN" ] && [ -x "$BIN" ] || { echo "WormAgent binary not found next to this launcher" >&2; exit 127; }
exec "$BIN" "$@"
LAUNCHER
chmod 755 "$INSTALL_DIR/Wormagent"

CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/opencode"
CFG="$CONFIG_DIR/opencode.json"
if [ ! -f "$CFG" ]; then
  mkdir -p "$CONFIG_DIR/.secrets"
  cat > "$CFG" <<'CFGEOF'
{
  "$schema": "https://opencode.ai/config.json",
  "provider": {
    "wormgpt": {
      "npm": "@ai-sdk/WormGPT-compatible",
      "name": "WormGPT",
      "options": {
        "baseURL": "https://wormgpt.app/v1",
        "apiKey": "{file:.secrets/wormgpt.key}"
      },
      "models": {
        "wormgpt-line-v8": {
          "name": "WormGPT Line V8",
          "modelID": "wormgpt-line-v8",
          "limit": { "context": 1000000, "output": 131072 },
          "capabilities": {
            "tools": true,
            "input": ["text"],
            "output": ["text"],
            "reasoning": { "supported": true, "effort": ["low", "high", "max"] }
          },
          "compatibility": {
            "maxTokensField": "max_tokens",
            "streamUsage": true,
            "requireReasoning": false,
            "reasoningField": "reasoning_content"
          },
          "body": { "thinking": true, "reasoning_effort": "high" },
          "reasoning": true,
          "interleaved": { "field": "reasoning_content" }
        }
      }
    }
  },
  "enabled_providers": ["wormgpt"],
  "model": "wormgpt/wormgpt-line-v8"
}
CFGEOF
  echo "${DIM}Wrote${NC} $CFG ${DIM}(wormgpt.app only)${NC}"
else
  echo "${DIM}Keeping existing${NC} $CFG"
fi
if [ -n "${WORMAGENT_API_KEY:-}" ]; then
  printf '%s' "$WORMAGENT_API_KEY" > "$CONFIG_DIR/.secrets/wormgpt.key"
  chmod 600 "$CONFIG_DIR/.secrets/wormgpt.key"
  echo "${DIM}Saved${NC} API key ${DIM}→${NC} $CONFIG_DIR/.secrets/wormgpt.key"
fi

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
