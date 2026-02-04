function _fzf_just_preview --description "Preview a justfile recipe for fzf"
    # Extract recipe name (first word from the line passed by fzf)
    set -l recipe_name (string split --fields=1 ' ' -- $argv)

    if test -z "$recipe_name"
        return 1
    end

    # Use bat for syntax highlighting if available, otherwise plain output
    if command -q bat
        just --show $recipe_name 2>/dev/null | bat --color=always --style=numbers --line-range=:20
    else
        just --show $recipe_name 2>/dev/null | head -n 20
    end
end
