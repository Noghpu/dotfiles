fish_add_path ~/.local/bin ~/.cargo/bin ~/Applications/depot_tools

# Defined by starship's init; guard it so shells without starship start cleanly.
type -q enable_transience; and enable_transience

umask 077

if test -r $XDG_CONFIG_HOME/fish/user_config.fish
    source $XDG_CONFIG_HOME/fish/user_config.fish
end

