.PHONY: help install install-terminal install-languages install-editors install-utils install-component stow clean

# Default target
help: ## Show this help message
	@echo "Development Environment Setup - Available targets:"
	@echo ""
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)
	@echo ""
	@echo "Examples:"
	@echo "  make install                    # Full installation"
	@echo "  make install-terminal           # Just terminal setup"
	@echo "  make install-component TAGS=git,zed  # Specific components"

install: ## Install complete development environment
	@echo "🚀 Installing complete development environment..."
	ansible-playbook -i localhost, main.yaml

install-terminal: ## Install terminal setup (terminal, shell, prompt)
	@echo "🖥️  Installing terminal setup..."
	ansible-playbook -i localhost, main.yaml --tags terminal

install-languages: ## Install development languages (Node.js, Rust, Python)
	@echo "⚙️  Installing development languages..."
	ansible-playbook -i localhost, main.yaml --tags node,rust,python

install-editors: ## Install editors (Zed, Neovim)
	@echo "📝 Installing editors..."
	ansible-playbook -i localhost, main.yaml --tags zed,neovim

install-utils: ## Install core utilities (fzf, ripgrep, etc.)
	@echo "🔧 Installing core utilities..."
	ansible-playbook -i localhost, main.yaml --tags utils

install-component: ## Install specific components (use TAGS=tag1,tag2)
	@if [ -z "$(TAGS)" ]; then \
		echo "❌ Error: TAGS variable is required"; \
		echo "Usage: make install-component TAGS=utils,git,zed"; \
		exit 1; \
	fi
	@echo "🎯 Installing components: $(TAGS)..."
	ansible-playbook -i localhost, main.yaml --tags $(TAGS)

stow: ## Apply dotfile configurations using GNU Stow
	@echo "🔗 Applying dotfile configurations..."
	cd dotfiles && stow fish ghostty zed karabiner starship tmux neovim

clean: ## Clean up temporary files and reset
	@echo "🧹 Cleaning up..."
	@echo "This will remove any temporary Ansible files..."
	find . -name "*.retry" -delete
	@echo "Done!"

# Individual component targets for convenience
install-ssh: ## Install SSH configuration
	ansible-playbook -i localhost, main.yaml --tags ssh

install-git: ## Install Git configuration
	ansible-playbook -i localhost, main.yaml --tags git

install-nix: ## Install Nix package manager
	ansible-playbook -i localhost, main.yaml --tags nix

install-zed: ## Install Zed editor
	ansible-playbook -i localhost, main.yaml --tags zed

install-neovim: ## Install Neovim
	ansible-playbook -i localhost, main.yaml --tags neovim

install-node: ## Install Node.js
	ansible-playbook -i localhost, main.yaml --tags node

install-rust: ## Install Rust
	ansible-playbook -i localhost, main.yaml --tags rust

install-python: ## Install Python
	ansible-playbook -i localhost, main.yaml --tags python

install-ngrok: ## Install Ngrok
	ansible-playbook -i localhost, main.yaml --tags ngrok

install-karabiner: ## Install Karabiner Elements (macOS)
	ansible-playbook -i localhost, main.yaml --tags karabiner

install-tmux: ## Install Tmux
	ansible-playbook -i localhost, main.yaml --tags tmux

# Validation targets
check: ## Check Ansible syntax
	@echo "🔍 Checking Ansible syntax..."
	ansible-playbook --syntax-check -i localhost, main.yaml

validate: ## Validate all YAML files
	@echo "✅ Validating YAML files..."
	@for file in *.yaml; do \
		echo "Checking $$file..."; \
		ansible-playbook --syntax-check -i localhost, $$file; \
	done

# Development targets
dry-run: ## Show what would be installed without making changes
	@echo "🔍 Dry run - showing what would be installed..."
	ansible-playbook -i localhost, main.yaml --check --diff

list-tags: ## List all available tags
	@echo "📋 Available tags:"
	@grep -h "tags:" *.yaml | grep -o "\- [a-zA-Z_-]*" | sort -u | sed 's/- /  /'