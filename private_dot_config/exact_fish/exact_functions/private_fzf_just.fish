function fzf_just --description "Pick and insert a justfile recipe using fzf"
    # Verify dependencies
    if not command -q fzf
        echo "fzf_just: fzf is required but not installed" >&2
        return 1
    end

    if not command -q just
        echo "fzf_just: just is required but not installed" >&2
        return 1
    end

    # Check if justfile exists in current directory or parent directories
    if not just --summary &>/dev/null
        echo "fzf_just: No justfile found" >&2
        commandline --function repaint
        return 1
    end

    # Get recipes with their full signatures (name + args + comments)
    # --list-heading '' removes "Available recipes:" header
    # --list-prefix '' removes leading whitespace
    set -l recipes (just --list --list-heading '' --list-prefix '' 2>/dev/null | string trim)

    if test -z "$recipes"
        echo "fzf_just: No recipes found in justfile" >&2
        commandline --function repaint
        return 1
    end

    # Run fzf with bottom layout
    # Preview calls _fzf_just_preview helper function (fish spawns new shell for preview)
    set -l selection (
        printf '%s\n' $recipes | fzf \
            --height=40% \
            --layout=reverse \
            --border=rounded \
            --info=inline \
            --prompt='just › ' \
            --header='Ctrl-/ toggle preview │ Enter select' \
            --preview='_fzf_just_preview {}' \
            --preview-window='right:50%:border-left:nowrap' \
            --bind='ctrl-/:toggle-preview' \
            $fzf_just_opts
    )

    # Exit if no selection (user cancelled)
    if test -z "$selection"
        commandline --function repaint
        return 0
    end

    # Extract recipe name (first word)
    set -l recipe_name (string split --fields=1 ' ' -- $selection)

    # Insert "just <recipe>" into the command line at cursor position
    commandline --insert "just $recipe_name "
    commandline --function repaint
end
