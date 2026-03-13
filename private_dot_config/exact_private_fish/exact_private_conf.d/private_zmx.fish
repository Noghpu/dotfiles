if type -q zmx
    if not test -f ~/.config/fish/completions/zmx.fish
        echo 'zmx completions fish | source' >~/.config/fish/completions/zmx.fish
    end
end
