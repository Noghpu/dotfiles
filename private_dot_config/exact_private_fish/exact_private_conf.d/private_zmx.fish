if type -q zmx
    abbr --add mx zmx
    if test -n "$ZMX_SESSION"
        abbr --add detach zmx detach
    end
    if not test -f ~/.config/fish/completions/zmx.fish
        echo 'zmx completions fish | source' >~/.config/fish/completions/zmx.fish
    end
end
