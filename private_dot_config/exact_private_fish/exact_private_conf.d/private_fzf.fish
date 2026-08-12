if type -q fzf
    set -gx FZF_DEFAULT_OPTS \
        '--color=bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8' \
        '--color=fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc' \
        '--color=marker:#b4befe,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8' \
        '--color=selected-bg:#45475a,border:#6c7086,label:#cdd6f4'

    if not test -r $__fish_cache_dir/fzf_init.fish
        fzf --fish >$__fish_cache_dir/fzf_init.fish
    end
    source $__fish_cache_dir/fzf_init.fish
end
