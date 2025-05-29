# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Purpose

This is an Ansible-based development environment setup repository that automates the installation and configuration of a complete development workstation. It manages dotfiles, development tools, and application configurations across macOS and Linux systems.

## Architecture

The repository uses a **modular Ansible playbook structure** where `main.yaml` orchestrates individual component installations through tagged task files. Each YAML file in the root handles a specific aspect of the development environment:

- **Core utilities**: `utils.yaml` (jq, fish, starship, fzf, ripgrep, zoxide)
- **Terminal setup**: `terminal.yaml` (Ghostty terminal, Fish shell, Starship prompt)
- **Development languages**: `node.yaml`, `rust.yaml`, `python.yaml`
- **Editors/Tools**: `zed.yaml`, `git.yaml`, `karabiner.yaml`
- **Infrastructure**: `nix.yaml`, `ngrok.yaml`, `ssh.yaml`

Configuration files are managed through **GNU Stow** for symlink-based dotfile management, with source files in the `dotfiles/` directory.

## Common Commands

```bash
# Run complete environment setup
ansible-playbook -i localhost, main.yaml

# Install specific components using tags
ansible-playbook -i localhost, main.yaml --tags utils,terminal
ansible-playbook -i localhost, main.yaml --tags zed,git
ansible-playbook -i localhost, main.yaml --tags python,node,rust

# Apply dotfile changes (run from dotfiles directory)
cd dotfiles && stow fish ghostty zed karabiner starship
```

## Key Configurations

- **Zed Editor**: Configured with Claude Sonnet 4, vim mode, Python LSP (ruff + pyright), and MCP context servers for PostgreSQL and Linear
- **Terminal Stack**: Ghostty + Fish shell + Starship prompt with Catppuccin theme
- **Keyboard**: Karabiner home row mods for ergonomic key mappings
- **Cross-platform**: Supports macOS (Homebrew), Arch Linux (pacman), and Ubuntu (apt)

## Development Workflow

When modifying configurations:
1. Edit source files in `dotfiles/` directory
2. Test changes by re-running specific playbook tags
3. Commit both the YAML playbooks and dotfile changes together