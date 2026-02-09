fish_add_path ~/.local/bin ~/.cargo/bin ~/Applications/depot_tools

enable_transience

umask 077

if test -r $XDG_CONFIG_HOME/fish/user_config.fish
    source $XDG_CONFIG_HOME/fish/user_config.fish
end
