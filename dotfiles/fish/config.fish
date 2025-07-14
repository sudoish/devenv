eval (/opt/homebrew/bin/brew shellenv)
starship init fish | source
zoxide init fish | source
alias cd="z"
alias vim="nvim"
alias tm="tmuxinator"
set -gx EDITOR nvim
set -gx WORKDIR /Users/pacheco/dev
set -gx PATH "$HOME/.local/bin" $PATH
set -gx NGROK_TOKEN 2q1nV9EJe7jiPZRvoGgUSJnAZJy_7AdTfUxBywqv9uX9wHtvU
set -gx PATH /opt/homebrew/opt/postgresql@16/bin $PATH
fish_add_path /opt/homebrew/opt/postgresql@16/bin

# make node available by default with nvm use 18
nvm use 20
alias lg='lazygit'

# opencode
fish_add_path /Users/pacheco/.opencode/bin
