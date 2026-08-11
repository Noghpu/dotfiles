function fish_user_key_bindings --description "User-defined key bindings"
    # Ctrl+J: justfile recipe picker
    bind \cj fzf_just

    # Ctrl+S: zmx session picker
    bind \cs fzf_zmx

    # Vi mode support: also bind in insert mode.
    # (`bind --mode insert` with no key just lists bindings and always succeeds,
    # so it never tested anything — check the active binding set instead.)
    if test "$fish_key_bindings" = fish_vi_key_bindings
        bind --mode insert \cj fzf_just
        bind --mode insert \cs fzf_zmx
    end

end
