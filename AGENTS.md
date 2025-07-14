# AGENTS.md

## Build/Test/Lint Commands
```bash
# Run complete environment setup
ansible-playbook -i localhost, main.yaml

# Install specific components using tags
ansible-playbook -i localhost, main.yaml --tags utils,terminal
ansible-playbook -i localhost, main.yaml --tags python,node,rust

# Apply dotfile changes (run from dotfiles directory)
cd dotfiles && stow fish ghostty zed karabiner starship

# Test single component (dry run)
ansible-playbook -i localhost, main.yaml --tags python --check
```

## Code Style Guidelines
- **Language**: YAML (Ansible playbooks), Fish shell scripts, JSON configs
- **Formatting**: Use 2-space indentation for YAML, format on save enabled
- **Structure**: Modular playbooks with tags, each YAML file handles one component
- **Naming**: Use descriptive task names, kebab-case for files, snake_case for variables
- **Error Handling**: Use `creates:` parameter to make tasks idempotent
- **Dependencies**: Check existing tools before adding new ones, support macOS/Linux
- **Python**: Use uv for package management, Python 3.11, ruff + pyright for linting/typing
- **Dotfiles**: Manage via GNU Stow, source files in `dotfiles/` directory
- **Testing**: Always use TDD approach, test with `--check` flag for dry runs