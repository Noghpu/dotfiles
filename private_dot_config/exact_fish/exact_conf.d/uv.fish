if type -q uv
    abbr --add uvim uv run nvim
    if not test -f ~/.config/fish/completions/uv.fish
        echo 'uv generate-shell-completion fish | source' >~/.config/fish/completions/uv.fish
    end
    if not test -f ~/.config/fish/completions/uvx.fish
        echo 'uvx --generate-shell-completion fish | source' >~/.config/fish/completions/uvx.fish
    end
end
