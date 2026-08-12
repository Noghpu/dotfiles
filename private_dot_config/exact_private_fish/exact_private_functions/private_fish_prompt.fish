function __prompt_directory --argument-names repo_root
    set -l path_parts
    set -l prefix /
    set -l truncated 0

    if test -n "$repo_root"; and begin
            test "$PWD" = "$repo_root"; or string match -q -- "$repo_root/*" "$PWD"
        end
        # Starship's `truncate_to_repo` hides everything above the repository.
        set path_parts (path basename "$repo_root")
        set -a path_parts (string split / -- (string replace "$repo_root/" '' "$PWD/"))
        set -e path_parts[-1]
        test "$repo_root" != /; and set truncated 1
    else if test "$PWD" = "$HOME"
        echo '~'
        return
    else if string match -q -- "$HOME/*" "$PWD"
        set prefix '~/'; set path_parts (string split / -- (string replace "$HOME/" '' "$PWD"))
    else
        set path_parts (string split / -- (string trim -l -c / "$PWD"))
    end

    if test (count $path_parts) -gt 3
        set path_parts $path_parts[-3..-1]
        set truncated 1
    end

    for index in (seq (count $path_parts))
        switch $path_parts[$index]
            case Documents
                set path_parts[$index] '󰈙 '
            case Downloads
                set path_parts[$index] ' '
            case Music
                set path_parts[$index] '󰝚 '
            case Pictures
                set path_parts[$index] ' '
            case Developer
                set path_parts[$index] '󰲋 '
        end
    end

    if test $truncated -eq 1
        set prefix '…/'
    end
    string join '' -- $prefix (string join / -- $path_parts)
end

function __prompt_git --argument-names root
    command -sq git; or return
    test -n "$root"; or return

    set -l porcelain (command git status --porcelain=v2 --branch --show-stash 2>/dev/null)
    set -l branch
    set -l oid
    set -l ahead 0
    set -l behind 0
    set -l conflicted 0
    set -l stashed 0
    set -l deleted 0
    set -l renamed 0
    set -l modified 0
    set -l typechanged 0
    set -l staged 0
    set -l untracked 0

    for line in $porcelain
        if string match -qr '^# branch.head ' -- $line
            set branch (string replace '# branch.head ' '' -- $line)
        else if string match -qr '^# branch.oid ' -- $line
            set oid (string replace '# branch.oid ' '' -- $line)
        else if string match -qr '^# branch.ab ' -- $line
            set -l counts (string split ' ' -- $line)
            set ahead (string replace + '' -- $counts[3])
            set behind (string replace - '' -- $counts[4])
        else if string match -qr '^# stash ' -- $line
            set stashed 1
        else if string match -qr '^u ' -- $line
            set conflicted 1
        else if string match -qr '^\? ' -- $line
            set untracked 1
        else if string match -qr '^[12] ' -- $line
            set -l xy (string sub -s 3 -l 2 -- $line)
            set -l index_state (string sub -s 1 -l 1 -- $xy)
            set -l worktree_state (string sub -s 2 -l 1 -- $xy)

            string match -qr '[U]' -- $xy; and set conflicted 1
            string match -qr '[D]' -- $xy; and set deleted 1
            string match -qr '[RC]' -- $xy; and set renamed 1
            test "$worktree_state" = M; and set modified 1
            string match -qr '[T]' -- $xy; and set typechanged 1
            string match -qr '[AMDRCT]' -- $index_state; and set staged 1
        end
    end

    if test "$branch" = '(detached)'
        set branch (string sub -l 7 -- $oid)
    end

    set_color '#fab387'
    printf ' %s' "$branch"
    set_color '#f9e2af'
    test $conflicted -eq 1; and printf '='
    test $stashed -eq 1; and printf '#'
    test $deleted -eq 1; and printf '✘'
    test $renamed -eq 1; and printf '»'
    test $modified -eq 1; and printf '!'
    test $typechanged -eq 1; and printf '~'
    test $staged -eq 1; and printf '+'
    test $untracked -eq 1; and printf '?'

    if test $ahead -gt 0; and test $behind -gt 0
        printf '⇕⇡%s⇣%s' $ahead $behind
    else if test $ahead -gt 0
        printf '⇡%s' $ahead
    else if test $behind -gt 0
        printf '⇣%s' $behind
    end
end

function __prompt_duration --argument-names milliseconds
    test "$milliseconds" -ge 1000 2>/dev/null; or return
    set -l seconds (math -s0 "$milliseconds / 1000")
    set -l days (math -s0 "$seconds / 86400")
    set -l hours (math -s0 "$seconds % 86400 / 3600")
    set -l minutes (math -s0 "$seconds % 3600 / 60")
    set -l remainder (math -s0 "$seconds % 60")

    if test $days -gt 0
        printf '%sd%sh%sm%ss' $days $hours $minutes $remainder
    else if test $hours -gt 0
        printf '%sh%sm%ss' $hours $minutes $remainder
    else if test $minutes -gt 0
        printf '%sm%ss' $minutes $remainder
    else
        printf '%ss' $remainder
    end
end

function fish_prompt
    set -l last_status $status
    set -l duration $CMD_DURATION

    # Match Starship's transient prompt: old commands retain only a chevron.
    if contains -- --final-rendering $argv
        set_color --bold '#a6e3a1'
        printf '❯ '
        set_color normal
        return
    end

    if test -n "$TMUX"
        set_color '#f9e2af'
        printf ' '
    end
    if test -n "$ZMX_SESSION"
        set_color '#cba6f7'
        printf ' (%s) ' "$ZMX_SESSION"
    end

    set_color '#b4befe'
    printf '%s' (__prompt_context)
    set_color '#cba6f7'
    printf ' %s' (__prompt_context_symbol)
    if fish_is_root_user
        set_color '#f38ba8'
    else
        set_color '#f5c2e7'
    end
    printf ' %s' "$USER"

    set -l git_root (command git rev-parse --show-toplevel 2>/dev/null)
    set -l git_segment (__prompt_git "$git_root")
    set_color '#a6e3a1'
    printf ' %s' (__prompt_directory "$git_root")
    printf '%s' "$git_segment"

    set_color '#89dceb'
    printf ' %s' (date +%H:%M)
    set -l formatted_duration (__prompt_duration "$duration")
    if test -n "$formatted_duration"
        set_color '#94e2d5'
        printf ' %s' "$formatted_duration"
    end

    printf '\n'
    if test $last_status -eq 0
        set_color --bold '#a6e3a1'
    else
        set_color --bold '#f38ba8'
    end
    printf '❯'
    set_color normal
    printf ' '
end
