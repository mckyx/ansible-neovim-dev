# Ansible + Python Neovim Dev Environment

A clone-and-run **Neovim/LazyVim IDE** for Ansible playbooks, AWX/Ascender automation, Ansible collection/plugin development and Python. Designed for **Ubuntu 24.04 under WSL2**; also works on native Ubuntu 24.04.

**One install command**, no existing Ansible or Neovim required. A small Bash bootstrap is intentional: requiring Ansible to install Ansible makes onboarding harder.

## Quick start

Inside an **Ubuntu 24.04 WSL terminal**:

```bash
git clone https://github.com/mckyx/ansible-neovim-dev.git
cd ansible-neovim-dev
./install.sh
```

> Replace `mckyx` after publishing your repository. Alternatively, download the ZIP and run `./install.sh` from the extracted directory. Read a public shell script before running it.

Open a **new WSL terminal** and run:

```bash
nvim
```

On the first launch, let LazyVim and Mason finish installing plugins and language servers. Verify:

```vim
:LazyHealth
:Mason
:checkhealth
```

To test the included sample code:

```bash
./scripts/doctor.sh
./scripts/smoke-test.sh
```

## What is included?

| Area | Components |
|---|---|
| Editor | Current stable Neovim, LazyVim, TokyoNight |
| Autocomplete | Blink.cmp, snippets, LSP hover, definitions and references |
| Ansible | Ansible Language Server, ansible-lint, yamllint CLI, FQCN completion |
| YAML/JSON/Jinja2 | YAML Language Server, SchemaStore, Tree-sitter highlighting, dedicated `.j2` template support |
| Python | BasedPyright, Ruff LSP, Ruff formatter, mypy CLI, IPython |
| Testing | pytest, pytest-cov, pytest-mock, pytest-xdist, Neotest integration |
| Debugging | nvim-dap, nvim-dap-python, debugpy adapter |
| Virtual environments | `venv-selector.nvim`, Python provider `pynvim` |
| Other | Git integration, fuzzy file search, file explorer, diagnostics, trailing-whitespace visibility |

**Important:** This also installs `jmespath` and `netaddr`, which are useful for Ansible filters and network/IP-related automation. Completion for custom or private Ansible collections requires those collections to be present locally. A dev virtual environment is **not** the same as an AWX execution environment.

## Safe installation and reruns

- `install.sh` runs as the normal Linux user. Only system packages require `sudo`.
- System dependencies use Ubuntu's `apt`.
- Neovim, Tree-sitter CLI and Node.js 24 are installed **under your home directory**, not `/usr/local` or `/opt`.
- Official Node.js checksums are verified; published GitHub SHA-256 asset digests are verified when available.
- The Python packages live in `~/.venvs/ansible-dev` (no `--break-system-packages`).
- PATH is added to `~/.bashrc` in a clearly marked block.
- If another Neovim config exists, the installer **stops**, rather than silently overwriting it.
- Re-running the installer keeps edits in a previously managed `~/.config/nvim` configuration.
- When explicitly requested, old configurations are backed up with a timestamp before replacement.

```bash
./install.sh --dry-run           # show intended changes
./install.sh --force             # back up ANY existing Neovim config and install ours
./install.sh --update-config     # back up and refresh our previously managed config
./install.sh --skip-plugin-sync  # install config; fetch Neovim plugins on first launch
```

You can request a particular version of Ansible or of the downloaded tools:

```bash
ANSIBLE_CORE_SPEC='ansible-core==2.19.4' ./install.sh
NVIM_RELEASE='v0.12.4' TREE_SITTER_RELEASE='v0.27.2' ./install.sh
```

These are examples of pin syntax, not a promise that a version will remain available or compatible forever. Because `install.sh` skips already installed managed binaries, delete/rename their managed directories before changing their versions; never remove an unknown install blindly. For a truly reproducible team image, also commit a tested `lazy-lock.json` and pin Python dependencies and downloaded release versions.

## Environment layout

```text
~/.config/nvim/                     LazyVim configuration
~/.local/opt/ansible-nvim-neovim/   Neovim binary
~/.local/opt/ansible-nvim-node/     Node.js 24 for LSP
~/.local/opt/ansible-nvim-tree-sitter/ Tree-sitter CLI
~/.venvs/ansible-dev/              Ansible, pytest, ruff, debugpy, etc.
```

The source of the shared configuration is **`nvim/` in this repository**. To change the defaults for your team, edit those files, commit, then use `./install.sh --update-config` to apply a refreshed copy.

## Developing Ansible

```bash
source ~/.venvs/ansible-dev/bin/activate
cd ~/projects/my-ansible-repo
nvim .
```

For a conventional repository, place playbooks under `playbooks/` and role YAML under `roles/ROLE_NAME/tasks/`, `handlers/`, `defaults/`, etc. The editor detects those locations as `yaml.ansible`. Standalone root playbooks named `site.yml` or `playbook.yml` are also detected. For non-standard naming/layouts, open a file and use:

```vim
:set ft=yaml.ansible
:LspInfo
```

When `ansiblels` is running, test module completion by typing `ansible.builtin.` in a task. Use `K` on a module for hover documentation.

A **project-local** `ansible.cfg`, `.ansible-lint`, `requirements.yml` and/or virtual environment may be necessary to match your team's execution environment. For example:

```bash
source ~/.venvs/ansible-dev/bin/activate
ansible-galaxy collection install -r requirements.yml
ansible-lint playbooks/
ansible-playbook --syntax-check -i inventory.ini playbooks/site.yml
```

Do not run an unreviewed production playbook locally. Syntax checks can require credentials, variables or collections specific to Ascender, and may fail without them.

### Python for Ansible plugins and modules

`examples/filter_plugins/custom_filters.py` and `examples/tests/test_custom_filters.py` demonstrate writing and testing a custom Ansible filter using ordinary Python tests.

```bash
source ~/.venvs/ansible-dev/bin/activate
cd examples
ruff check .
ruff format --check .
pytest -q
python -m mypy filter_plugins  # optional static typing pass
```

For each real project, create a **project-specific `.venv`**, install its dependencies and select it with `Space c v` (`:VenvSelect`). BasedPyright and test tooling should analyze code against that interpreter rather than the bootstrap environment. The global `~/.venvs/ansible-dev` environment supplies Ansible development tools and Neovim's Python provider.

## Useful shortcuts

`Space` is the LazyVim leader key.

| Shortcut | Action |
|---|---|
| `Space e` | Toggle file explorer |
| `Space f f` | Find files |
| `Space s g` | Search repository text |
| `Space s d` | List diagnostics |
| `K` | Hover documentation |
| `g d` | Go to definition |
| `Space c a` | Code actions |
| `Space c f` | Format buffer (Python: Ruff) |
| `Space c v` | Choose Python virtual environment |
| `Space t r` | Neotest: run nearest test |
| `Space t t` | Neotest: test file |
| `Space d b` | Toggle debugger breakpoint |
| `Space d c` | Start/continue debugger |
| `Space d P t` | Debug Python test method |
| `Space a r` | Run Ansible playbook/role (only in Ansible files) |
| `Space c w` | Remove trailing whitespace (edits buffer) |

The Ansible `Space a r` shortcut is deliberately different from Neotest's `Space t a` to prevent a key collision.

## WSL recommendations

- Keep repositories in `~/projects/...` on the Linux filesystem instead of `/mnt/c/...` for faster Git, file search and Python tooling.
- Install **JetBrainsMono Nerd Font** (or another Nerd Font) in Windows, then select it in your Windows Terminal/WezTerm profile. The Linux bootstrap **does not** modify your Windows terminal configuration.
- A terminal emulator with true color and undercurl gives the best appearance.
- Clipboard integration with Windows depends on your WSL terminal, and may need extra local configuration; this installer does not override your clipboard.
- Do not run `nvim` as root: the configuration and Mason tools are user-scoped.

## Troubleshooting

| Symptom | Check |
|---|---|
| YAML color, but no Ansible completion | `:set ft?` must show `yaml.ansible`; then `:LspInfo` |
| Python has no completion | `:Mason`, `:LspInfo`, and `:VenvSelect` |
| `ansiblels` cannot find modules | Install the collection into the local environment; check `ansible.cfg` |
| Missing Tree-sitter highlights | `tree-sitter --version`, then `:checkhealth nvim-treesitter` |
| Debugger doesn't start | `:Mason` and check for `debugpy` adapter |
| Bad font/icons | Select a Nerd Font in Windows Terminal (not only WSL) |
| Packages still downloading | Open `:Lazy` and `:Mason`; run `:Lazy sync` if needed |
| Files are slow under WSL | Work inside `~/projects`, not `/mnt/c` |

## GitHub publishing and CI

The included `.github/workflows/ci.yml` automatically checks shell and Lua syntax, Ruff lint/format, and the Python unit tests on pushes and pull requests. This is a **static test pipeline**, not a substitute for a full WSL installation test.

If you fork or maintain a copy of this repository, you can commit changes using Git:

```bash
git init
git add .
git commit -m "Initial Ansible and Python Neovim dev environment"
gh auth login
gh repo create ansible-neovim-dev --public --source=. --remote=origin --push
```

`gh` is the GitHub CLI; install it separately on the machine where you publish. Do not run `gh repo create` if the repo already exists.

## Scope, updates and security

This installer downloads third-party programs and Neovim plugins from their upstream sources, and uses `sudo apt-get`. Review both `install.sh` and plugin sources before deploying on an enterprise machine. For company use, consider an internal Git mirror, approved packages, pinned versions, and a test pipeline before distributing it broadly.

LazyVim and Mason install some tooling on first launch. If a network proxy, corporate firewall or GitHub rate limit blocks downloads, run `:LazyHealth`, inspect `:Mason` and retry on an approved network.

No private playbooks, Ascender tokens, controller URLs, secrets, inventory or organization information are included in this repository.

## License

MIT. See `LICENSE`.