#!/usr/bin/env bash
set -Eeuo pipefail

ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
EXAMPLES="$ROOT/examples"
BIN="$HOME/.venvs/ansible-dev/bin"

for tool in python ruff pytest ansible-playbook ansible-lint; do
  [[ -x "$BIN/$tool" ]] || { echo "Missing $BIN/$tool - please run ./install.sh" >&2; exit 1; }
done

cd "$EXAMPLES"
printf '\n==> Python lint\n'
"$BIN/ruff" check .
printf '\n==> Python formatting check\n'
"$BIN/ruff" format --check .
printf '\n==> Python unit tests\n'
"$BIN/pytest" -q
printf '\n==> Ansible syntax check\n'
"$BIN/ansible-playbook" --syntax-check playbooks/smoke.yml
printf '\n==> Ansible lint\n'
"$BIN/ansible-lint" playbooks/smoke.yml
printf '\nAll smoke tests passed.\n'
