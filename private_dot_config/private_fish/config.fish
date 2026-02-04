set -gx EDITOR nvim

# for headless gpg git credential manager
set -gx GPG_TTY (tty)

fish_add_path ~/.cargo/bin/
fish_add_path ~/.local/bin/

enable_transience
