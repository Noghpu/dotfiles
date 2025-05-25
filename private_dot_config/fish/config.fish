# For starship prompt
set -gx WSL_SESSION = 1

set -gx XDG_CACHE_HOME "$HOME/.cache"
set -gx XDG_CONFIG_HOME "$HOME/.config"
set -gx XDG_DATA_HOME "$HOME/.local/share"
set -gx XDG_STATE_HOME "$HOME/.local/state"

set -gx EDITOR /usr/bin/nvim

if status is-interactive
    # Commands to run in interactive sessions can go here
end

source $XDG_CONFIG_HOME/fish/functions/uutils_aliases.fish

if type -q starship
    set -gx STARSHIP_CONFIG $XDG_CONFIG_HOME/starship/starship.toml
    if not test -r $__fish_cache_dir/starship_init.fish
        starship init fish --print-full-init >$__fish_cache_dir/starship_init.fish
    end
    source $__fish_cache_dir/starship_init.fish
    enable_transience
end

if type -q rg
    set -gx RIPGREP_CONFIG_PATH $XDG_CONFIG_HOME/ripgrep
end

if type -q bat
    set -gx BAT_CONFIG_DIR $XDG_CONFIG_HOME/bat
    set -gx BAT_CONFIG_PATH $XDG_CONFIG_HOME/bat/config
    if not test -r $__fish_cache_dir/bat.fish
        bat --completion fish >$__fish_cache_dir/bat.fish

        if test -d $BAT_CONFIG_DIR/themes/
            set current_themes (bat --list-themes)
            for file in $BAT_CONFIG_DIR/themes/*
                set name (string split -r -m1 '.' (basename $file))[1]
                if not string match -r $name $current_themes
                    bat cache --build
                    break
                end
            end
        end
    end
end

if type -q yazi
    function y
        set tmp (mktemp -t "yazi-cwd.XXXXXX")
        yazi $argv --cwd-file="$tmp"
        if set cwd (command cat -- "$tmp"); and [ -n "$cwd" ]; and [ "$cwd" != "$PWD" ]
            builtin cd -- "$cwd"
        end
        rm -f -- "$tmp"
    end
end

if type -q lazygit
    set -gx CONFIG_DIR $XDG_CONFIG_HOME/lazygit
    abbr lg lazygit
end

if type -q fzf
    if type -q fzf_configure_bindings
        fzf_configure_bindings --directory=\cf --git_log=\cl --git_status=\cs --history=\cr --processes=\cp --variables=\cv
    end
end

if type -q eza
    set -gx EZA_CONFIG_DIR $XDG_CONFIG_HOME/eza
    alias ls="eza -l --icons=always --group-directories-first --octal-permissions --no-permissions --time-style='relative' --all"
end

if type -q dua
    set -gx EZA_CONFIG_DIR $XDG_CONFIG_HOME/eza
    abbr --add du dua
    abbr --add dui dua i
end
