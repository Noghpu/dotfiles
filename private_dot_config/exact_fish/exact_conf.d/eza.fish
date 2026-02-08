if command -q eza
    set -gx EZA_CONFIG_DIR $XDG_CONFIG_HOME/eza
    if not test -r
        mkdir -p $XDG_CONFIG_HOME/eza
        touch $XDG_CONFIG_HOME/eza/theme.yml
    end

    alias la='eza -la --color=always --group-directories-first --icons=always' # all files and dirs`
    alias ll='eza -l --color=always --group-directories-first --icons=always' # long format
    alias lt='eza -aT --color=always --group-directories-first --icons=always' # tree listing
    alias l.="eza -a | grep -e '^\.'" # show only dotfiles

end
