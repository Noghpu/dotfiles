# bat configuration with Catppuccin theming
# Rebuild cache if Catppuccin themes haven't been cached yet

if type -q bat
    if not bat --list-themes 2>/dev/null | string match -q '*Catppuccin*'
        bat cache --build >/dev/null 2>&1
    end
    set -x MANPAGER "sh -c 'col -bx | bat -l man -p'"
    set -gx BAT_THEME Catppuccin-mocha
end
