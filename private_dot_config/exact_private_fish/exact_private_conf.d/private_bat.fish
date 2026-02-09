# bat configuration with Catppuccin theming
# Rebuild cache if Catppuccin themes haven't been cached yet

if type -q batcat
    alias bat='batcat'
end

if type -q bat
    set -x MANPAGER "sh -c 'col -bx | bat -l man -p'"
    set -gx BAT_THEME Catppuccin-mocha
    set -gx BAT_CONFIG_DIR $XDG_CONFIG_HOME/bat
    set -gx BAT_CONFIG_PATH $XDG_CONFIG_HOME/bat/config
    if not bat --list-themes 2>/dev/null | string match -q '*Catppuccin*'
        bat cache --build >/dev/null 2>&1
    end
end
