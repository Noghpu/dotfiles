set -gx EDITOR nvim

# for headless gpg git credential manager
set -gx GPG_TTY (tty)

# Append common directories for executable files to $PATH
fish_add_path ~/.local/bin ~/.cargo/bin ~/Applications/depot_tools

enable_transience
