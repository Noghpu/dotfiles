# bat configuration with Catppuccin theming
# Rebuild the theme cache manually with `bat cache --build` after adding themes.

if type -q batcat
    alias bat='batcat'
end

if type -q bat
    set -x MANPAGER "sh -c 'col -bx | bat -l man -p'"
    set -gx BAT_THEME "Catppuccin Mocha"
    set -gx BAT_CONFIG_DIR $XDG_CONFIG_HOME/bat
    set -gx BAT_CONFIG_PATH $XDG_CONFIG_HOME/bat/config
    set -l _bat_cache (set -q XDG_CACHE_HOME; and echo $XDG_CACHE_HOME; or echo $HOME/.cache)
    if not test -f $_bat_cache/bat/themes.bin
        bat cache --build >/dev/null 2>&1
    end
end
