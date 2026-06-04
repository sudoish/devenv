eval (/opt/homebrew/bin/brew shellenv)
starship init fish | source
zoxide init fish | source
alias cd="z"
alias vim="nvim"
alias tm="tmuxinator"
set -gx EDITOR nvim
set -gx WORKDIR $HOME/dev
set -gx DYLD_FALLBACK_LIBRARY_PATH /opt/homebrew/opt/libmagic/lib $DYLD_FALLBACK_LIBRARY_PATH
set -gx PATH "$HOME/.local/bin" $PATH

# NGROK_TOKEN should be set as an environment variable or in a secrets file
if test -f ~/.config/secrets/ngrok
    source ~/.config/secrets/ngrok
end

# Initialize nvm and use Node 20
if test -f ~/.config/fish/functions/nvm.fish
    # Set nvm data directory if not already set
    set -q nvm_data || set -gx nvm_data ~/.local/share/nvm
    # Use nvm silently to avoid output issues
    # nvm use 20 --silent 2>/dev/null || nvm use 20
end
alias lg='lazygit'

# opencode
fish_add_path $HOME/.opencode/bin
# rbenv init - fish | source

# bun
set --export BUN_INSTALL "$HOME/.bun"
set --export PATH $BUN_INSTALL/bin $PATH
fish_add_path $HOME/.local/bin

fish_add_path $HOME/.emacs.d/bin

# npm global packages
fish_add_path $HOME/.npm-global/bin

fish_add_path $HOME/develop/flutter/bin

# Android SDK
set -gx ANDROID_HOME /opt/homebrew/share/android-commandlinetools
fish_add_path $ANDROID_HOME/platform-tools

eval "$(/opt/homebrew/bin/brew shellenv fish)"
