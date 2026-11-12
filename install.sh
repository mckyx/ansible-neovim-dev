#!/usr/bin/env bash
set -Eeuo pipefail

# Ansible + Python Neovim IDE bootstrap for Ubuntu 24.04 / WSL2
ROOT="$(cd "$(dirname "$0")" && pwd)"
OPT="$HOME/.local/opt"
BIN="$HOME/.local/bin"
VENV="$HOME/.venvs/ansible-dev"
CONFIG="$HOME/.config/nvim"
FORCE=0
UPDATE=0
SKIP=0

help() {
  echo "Usage: ./install.sh [--dry-run] [--force] [--update-config] [--skip-plugin-sync]"
}
for arg in "$@"; do
  case "$arg" in
    --dry-run) DRY=1 ;;
    --force) FORCE=1 ;;
    --update-config) UPDATE=1 ;;
    --skip-plugin-sync) SKIP=1 ;;
    --help|-h) help; exit 0 ;;
    *) help; echo "Unknown option: $arg" >&2; exit 1 ;;
  esac
done

(( EUID != 0 )) || { echo 'Run as normal user, not root.' >&2; exit 1; }
[[ -d "$ROOT/nvim" ]] || { echo 'Missing nvim source config.' >&2; exit 1; }
if [[ -e "$CONFIG" && ! -f "$CONFIG/.ansible-neovim-dev-managed" && "$FORCE" -ne 1 ]]; then
  echo "Unmanaged Neovim config found: $CONFIG. Use --force to back it up." >&2
  exit 1
fi
if [[ "$DRY" == 1 ]]; then
  printf 'Will install Ubuntu prerequisites, Neovim, Node, Tree-sitter, Python tooling and config into %s\n' "$HOME"
  exit 0
fi
source /etc/os-release
[[ "$ID" == ubuntu && "$VERSION_ID" == 24.04 ]] || { echo 'Ubuntu 24.04 required.' >&2; exit 1; }
case "$(uname -m)" in
  x86_64) ARCH=x86_64; SHORT_ARCH=x64 ;;
  aarch64) ARCH=arm64; SHORT_ARCH=arm64 ;;
  *) echo 'Unsupported CPU architecture' >&2; exit 1 ;;
esac

sudo apt-get update
sudo env DEBIAN_FRONTEND=noninteractive apt-get install -y \
  ca-certificates curl git unzip xz-utils jq python3 python3-venv python3-pip \
  python3-dev build-essential ripgrep fd-find fzf shellcheck xclip

mkdir -p "$OPT" "$BIN" "$HOME/.venvs" "$HOME/.config"
TMP="$(mktemp -d)"
trap 'rm -rf -- "$TMP"' EXIT

get() { curl -fL --retry 3 --silent --show-error "$1" -o "$2"; }
verify_github() {
  local repo="$1" release="$2" asset="$3" file="$4" endpoint digest
  if [[ "$release" == latest ]]; then
    endpoint="https://api.github.com/repos/$repo/releases/latest"
  else
    endpoint="https://api.github.com/repos/$repo/releases/tags/$release"
  fi
  digest="$(curl -fsSL --max-time 15 "$endpoint" 2>/dev/null | jq -r --arg asset "$asset" '.assets[]? | select(.name == $asset) | .digest // empty' 2>/dev/null | head -n1 || true)"
  if [[ "$digest" == sha256:* ]]; then
    echo "$digest" | cut -d: -f2 | xargs -I '{}' sh -c 'echo "$1  $2" | sha256sum -c --status' _ '{}' "$file" || return 1
  else
    echo "WARNING: SHA256 digest unavailable for $asset; using HTTPS download." >&2
  fi
}

NVIM_DIR="$OPT/ansible-nvim-neovim"
NVIM_RELEASE="$(printenv NVIM_RELEASE || echo latest)"
if [[ ! -x "$NVIM_DIR/bin/nvim" ]]; then
  asset="nvim-linux-$ARCH.tar.gz"
  if [[ "$NVIM_RELEASE" == latest ]]; then
    url="https://github.com/neovim/neovim/releases/latest/download/$asset"
  else
    url="https://github.com/neovim/neovim/releases/download/$NVIM_RELEASE/$asset"
  fi
  get "$url" "$TMP/$asset"
  verify_github neovim/neovim "$NVIM_RELEASE" "$asset" "$TMP/$asset"
  tar -xzf "$TMP/$asset" -C "$TMP"
  mv "$TMP/nvim-linux-$ARCH" "$NVIM_DIR"
fi

TREE_DIR="$OPT/ansible-nvim-tree-sitter"
TREE_RELEASE="$(printenv TREE_SITTER_RELEASE || echo latest)"
if [[ ! -x "$TREE_DIR/bin/tree-sitter" ]]; then
  asset="tree-sitter-cli-linux-$SHORT_ARCH.zip"
  if [[ "$TREE_RELEASE" == latest ]]; then
    url="https://github.com/tree-sitter/tree-sitter/releases/latest/download/$asset"
  else
    url="https://github.com/tree-sitter/tree-sitter/releases/download/$TREE_RELEASE/$asset"
  fi
  get "$url" "$TMP/$asset"
  verify_github tree-sitter/tree-sitter "$TREE_RELEASE" "$asset" "$TMP/$asset"
  mkdir -p "$TREE_DIR/bin" "$TMP/unzip"
  unzip -q "$TMP/$asset" -d "$TMP/unzip"
  found="$(find "$TMP/unzip" -type f -name tree-sitter -print -quit)"
  [[ -n "$found" ]] || { echo 'Tree-sitter binary missing' >&2; exit 1; }
  install -m 755 "$found" "$TREE_DIR/bin/tree-sitter"
fi

NODE_DIR="$OPT/ansible-nvim-node"
if [[ ! -x "$NODE_DIR/bin/node" ]]; then
  base='https://nodejs.org/dist/latest-v24.x'
  sums="$(curl -fsSL "$base/SHASUMS256.txt")"
  filename="$(printf '%s\n' "$sums" | awk -v arch="$SHORT_ARCH" '$2 ~ ("-linux-" arch ".tar.xz$") {print $2; exit}')"
  [[ -n "$filename" ]] || { echo 'Node.js download unavailable' >&2; exit 1; }
  get "$base/$filename" "$TMP/$filename"
  (cd "$TMP"; printf '%s\n' "$sums" | grep -F "  $filename" | sha256sum -c --status)
  tar -xJf "$TMP/$filename" -C "$TMP"
  mv "$TMP/$(basename "$filename" .tar.xz)" "$NODE_DIR"
fi

[[ -e "$BIN/fd" ]] || ln -s "$(command -v fdfind)" "$BIN/fd"
if ! grep -Fq '# >>> ansible-neovim-dev PATH >>>' "$HOME/.bashrc" 2>/dev/null; then
  cat >> "$HOME/.bashrc" <<'RC'

# >>> ansible-neovim-dev PATH >>>
export PATH="$HOME/.local/opt/ansible-nvim-neovim/bin:$HOME/.local/opt/ansible-nvim-tree-sitter/bin:$HOME/.local/opt/ansible-nvim-node/bin:$HOME/.local/bin:$PATH"
# <<< ansible-neovim-dev PATH <<<
RC
fi
export PATH="$NVIM_DIR/bin:$TREE_DIR/bin:$NODE_DIR/bin:$BIN:$PATH"

[[ -x "$VENV/bin/python" ]] || python3 -m venv "$VENV"
"$VENV/bin/python" -m pip install --upgrade pip
ANSIBLE_CORE_SPEC="$(printenv ANSIBLE_CORE_SPEC || echo ansible-core)"
"$VENV/bin/python" -m pip install "$ANSIBLE_CORE_SPEC" ansible-lint yamllint \
  pytest pytest-cov pytest-mock pytest-xdist debugpy pynvim \
  ruff mypy jinja2 jmespath netaddr ipython

if [[ -e "$CONFIG" && ( "$FORCE" == 1 || "$UPDATE" == 1 ) ]]; then
  mv "$CONFIG" "$CONFIG.backup.$(date +%Y%m%d-%H%M%S).$$"
fi
if [[ ! -e "$CONFIG" ]]; then
  cp -a "$ROOT/nvim" "$CONFIG"
  echo 'managed by ansible-neovim-dev' > "$CONFIG/.ansible-neovim-dev-managed"
fi

"$NVIM_DIR/bin/nvim" --version | head -n1
"$VENV/bin/ansible" --version | head -n1
if [[ "$SKIP" -eq 0 ]]; then
  "$NVIM_DIR/bin/nvim" --headless '+Lazy! sync' '+qa' || echo 'Finish plugin installation from :Lazy and :Mason'
fi
echo 'Installed. Open a new WSL shell, run nvim, and check :LazyHealth and :Mason.'
