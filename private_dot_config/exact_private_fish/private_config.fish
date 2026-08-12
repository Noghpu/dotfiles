fish_add_path ~/.local/bin ~/.cargo/bin ~/Applications/depot_tools

# Fish 4.4+ bundles the Catppuccin themes. Pin the dark variant instead of
# following terminal/system light-mode changes.
fish_config theme choose catppuccin-mocha --color-theme=dark

# Keep previous prompts compact using Fish's native transient-prompt support.
set -g fish_transient_prompt 1

umask 077

if test -r $XDG_CONFIG_HOME/fish/user_config.fish
    source $XDG_CONFIG_HOME/fish/user_config.fish
end
