eval (/opt/homebrew/bin/brew shellenv)
starship init fish | source
zoxide init fish | source
alias cd="z"
alias vim="nvim"
alias tm="tmuxinator"
set -gx EDITOR nvim
set -gx WORKDIR /Users/pacheco/dev
set -gx PATH "$HOME/.local/bin" $PATH

# NGROK_TOKEN should be set as an environment variable or in a secrets file
if test -f ~/.config/secrets/ngrok
    source ~/.config/secrets/ngrok
end

set -gx PATH /opt/homebrew/opt/postgresql@16/bin $PATH
fish_add_path /opt/homebrew/opt/postgresql@16/bin

# Initialize nvm and use Node 20
if test -f ~/.config/fish/functions/nvm.fish
    # Set nvm data directory if not already set
    set -q nvm_data || set -gx nvm_data ~/.local/share/nvm
    # Use nvm silently to avoid output issues
    nvm use 20 --silent 2>/dev/null || nvm use 20
end
alias lg='lazygit'

# opencode
fish_add_path /Users/pacheco/.opencode/bin
rbenv init - fish | source

# bun
set --export BUN_INSTALL "$HOME/.bun"
set --export PATH $BUN_INSTALL/bin $PATH
fish_add_path $HOME/.local/bin

alias claude="/Users/pacheco/.claude/local/claude"