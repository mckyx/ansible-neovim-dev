#!/usr/bin/env bash
set -uo pipefail

ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
VENV="$HOME/.venvs/ansible-dev/bin"
CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}/nvim"
MASON="${XDG_DATA_HOME:-$HOME/.local/share}/nvim/mason/bin"
FAIL=0

ok() { printf '  \033[1;32mOK\033[0m   %-23s %s\n' "$1" "$2"; }
no() { printf '  \033[1;31mFAIL\033[0m %-23s %s\n' "$1" "$2"; FAIL=1; }
info() { printf '  \033[1;33mINFO\033[0m %-23s %s\n' "$1" "$2"; }
check_command() {
  local label="$1" command_path="$2"
  if command -v "$command_path" >/dev/null 2>&1; then
    ok "$label" "$(command -v "$command_path")"
  else
    no "$label" "Missing: $command_path"
  fi
}
check_file() {
  local label="$1" filename="$2"
  if [[ -e "$filename" ]]; then ok "$label" "$filename"; else no "$label" "Missing: $filename"; fi
}

printf '\nAnsible Neovim Dev | Doctor\n\n'
check_command 'Neovim' nvim
check_command 'Node.js' node
check_command 'Tree-sitter CLI' tree-sitter
check_command 'ripgrep' rg
check_command 'fd' fd
check_command 'Git' git
check_file 'Managed config' "$CONFIG/.ansible-neovim-dev-managed"
check_file 'Ansible virtualenv' "$VENV/python"
check_file 'ansible executable' "$VENV/ansible"
check_file 'ansible-lint' "$VENV/ansible-lint"
check_file 'yamllint' "$VENV/yamllint"
check_file 'pytest' "$VENV/pytest"
check_file 'ruff' "$VENV/ruff"
if [[ -x "$VENV/python" ]] && "$VENV/python" -c 'import debugpy' >/dev/null 2>&1; then
  ok 'debugpy Python module' "$VENV/python -m debugpy"
else
  no 'debugpy Python module' 'Not importable from Ansible virtualenv'
fi

printf '\nMason language server checks (may install during first Neovim launch):\n'
for name in ansible-language-server basedpyright-langserver ruff yaml-language-server debugpy-adapter; do
  if [[ -e "$MASON/$name" ]]; then
    ok "$name" "$MASON/$name"
  else
    info "$name" "Not visible yet; check :Mason after launching nvim"
  fi
done

printf '\nTry: cd %s/examples && ../scripts/smoke-test.sh\n' "$ROOT"
if (( FAIL )); then
  printf '\nOne or more prerequisites are missing; rerun ./install.sh.\n' >&2
  exit 1
fi
printf '\nBasic prerequisites are in place. In Neovim also check :LazyHealth and :checkhealth.\n'
