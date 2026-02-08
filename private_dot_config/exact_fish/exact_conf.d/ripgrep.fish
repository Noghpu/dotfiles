if command -q rg
    set -gx RIPGREP_CONFIG_PATH $XDG_CONFIG_HOME/ripgrep/.ripgreprc
    if not test -r
        mkdir -p $XDG_CONFIG_HOME/ripgrep
        touch $XDG_CONFIG_HOME/ripgrep/.ripgreprc
    end
end
