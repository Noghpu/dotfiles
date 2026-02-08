if command -q lazygit
    set -gx CONFIG_DIR $XDG_CONFIG_HOME/lazygit
    abbr lg lazygit
end
