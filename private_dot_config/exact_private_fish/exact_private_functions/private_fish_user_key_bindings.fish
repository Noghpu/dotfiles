function fish_user_key_bindings --description "User-defined key bindings"
    # Ctrl+J: justfile recipe picker
    bind \cj fzf_just

    # Ctrl+S: zmx session picker
    bind \cs fzf_zmx

    # Vi mode support: also bind in insert mode
    if bind --mode insert &>/dev/null 2>&1
        bind --mode insert \cj fzf_just
        bind --mode insert \cs fzf_zmx
    end

end
