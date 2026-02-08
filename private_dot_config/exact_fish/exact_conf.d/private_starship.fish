if type -q starship
    set -gx STARSHIP_CONFIG $XDG_CONFIG_HOME/starship/starship.toml
    if not test -r $__fish_cache_dir/starship_init.fish
        starship init fish --print-full-init >$__fish_cache_dir/starship_init.fish
    end
    source $__fish_cache_dir/starship_init.fish
end
