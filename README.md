# Development Environment Setup

An Ansible-based development environment setup repository that automates the installation and configuration of a complete development workstation. This project manages dotfiles, development tools, and application configurations across macOS and Linux systems.

## 🚨 Important: Personal Files Warning

**Before using this repository, you MUST delete the `files/` directory!**

The `files/` folder contains encrypted personal files (SSH keys, etc.) that belong exclusively to the repository owner. These files will prevent the installation process from working for other users.

```bash
rm -rf files/**
```

## Architecture

This repository uses a **modular Ansible playbook structure** where `main.yaml` orchestrates individual component installations through tagged task files. Each YAML file handles a specific aspect of the development environment:

### Core Components

- **Core utilities** (`utils.yaml`): jq, fish, starship, fzf, ripgrep, zoxide
- **Terminal setup** (`terminal.yaml`): Ghostty terminal, Fish shell, Starship prompt
- **Development languages**: `node.yaml`, `rust.yaml`, `python.yaml`
- **Editors/Tools**: `zed.yaml`, `neovim.yaml`, `git.yaml`, `karabiner.yaml`
- **Infrastructure**: `nix.yaml`, `ngrok.yaml`, `ssh.yaml`, `tmux.yaml`

Configuration files are managed through **GNU Stow** for symlink-based dotfile management, with source files in the `dotfiles/` directory.

## Quick Start

### Prerequisites

- macOS, Arch Linux, or Ubuntu
- Ansible installed (`pip install ansible` or use system package manager)
- Git

### Full Installation

```bash
# Clone the repository
git clone <repository-url>
cd devenv

# IMPORTANT: Remove personal files
rm -rf files/

# Run complete environment setup
make install
```

### Selective Installation

You can pick and choose which components to install using tags:

```bash
# Install just terminal and shell setup
make install-terminal

# Install development languages
make install-languages

# Install editors
make install-editors

# Install specific components
make install-component TAGS=utils,git,zed
```

## Available Make Targets

| Target | Description |
|--------|-------------|
| `make install` | Complete environment setup |
| `make install-terminal` | Terminal, shell, and prompt setup |
| `make install-languages` | Node.js, Rust, and Python |
| `make install-editors` | Zed and Neovim |
| `make install-utils` | Core utilities (fzf, ripgrep, etc.) |
| `make install-component TAGS=...` | Install specific tagged components |
| `make stow` | Apply dotfile configurations |
| `make help` | Show all available targets |

## Manual Ansible Commands

If you prefer to run Ansible directly:

```bash
# Complete setup
ansible-playbook -i localhost, main.yaml

# Install specific components using tags
ansible-playbook -i localhost, main.yaml --tags utils,terminal
ansible-playbook -i localhost, main.yaml --tags zed,git
ansible-playbook -i localhost, main.yaml --tags python,node,rust

# Apply dotfile changes (run from dotfiles directory)
cd dotfiles && stow fish ghostty zed karabiner starship tmux
```

## Available Tags

| Tag | Component | Description |
|-----|-----------|-------------|
| `utils` | Core utilities | jq, fish, starship, fzf, ripgrep, zoxide |
| `ssh` | SSH setup | SSH key management and configuration |
| `terminal` | Terminal setup | Ghostty terminal with configurations |
| `git` | Git configuration | Git settings and aliases |
| `nix` | Nix package manager | Nix installation and setup |
| `zed` | Zed editor | Zed editor with Claude integration |
| `neovim` | Neovim editor | Neovim with configurations |
| `node` | Node.js | Node.js and npm setup |
| `rust` | Rust | Rust toolchain installation |
| `python` | Python | Python environment setup |
| `ngrok` | Ngrok | Tunnel service setup |
| `karabiner` | Karabiner Elements | Keyboard remapping (macOS) |
| `tmux` | Tmux | Terminal multiplexer setup |

## Key Configurations

- **Zed Editor**: Configured with Claude Sonnet 4, vim mode, Python LSP (ruff + pyright), and MCP context servers for PostgreSQL and Linear
- **Terminal Stack**: Ghostty + Fish shell + Starship prompt with Catppuccin theme
- **Keyboard**: Karabiner home row mods for ergonomic key mappings
- **Cross-platform**: Supports macOS (Homebrew), Arch Linux (pacman), and Ubuntu (apt)

## Development Workflow

When modifying configurations:

1. Edit source files in `dotfiles/` directory
2. Test changes by re-running specific playbook tags
3. Apply dotfile changes with `make stow`
4. Commit both the YAML playbooks and dotfile changes together

## Platform Support

- **macOS**: Full support with Homebrew
- **Arch Linux**: Full support with pacman
- **Ubuntu**: Full support with apt

## Troubleshooting

### Common Issues

1. **Permission errors**: Make sure you have sudo access for system-wide installations
2. **Stow conflicts**: Remove existing dotfiles that conflict with stow symlinks
3. **Missing dependencies**: Some tools require additional system dependencies

### Getting Help

- Check individual YAML files for component-specific requirements
- Review Ansible output for specific error messages
- Ensure all prerequisites are installed for your platform

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test on your platform
5. Submit a pull request

## License

This project is for personal use. Adapt as needed for your own development environment.
