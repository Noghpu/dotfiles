if command -q rg
    set -gx RIPGREP_CONFIG_PATH $XDG_CONFIG_HOME/ripgrep/.ripgreprc
    if not test -r $RIPGREP_CONFIG_PATH
        mkdir -p (path dirname $RIPGREP_CONFIG_PATH)
        touch $RIPGREP_CONFIG_PATH
    end
end
