function fish_tab_title --description 'Show environment, directory, and active command in the tab title' --argument-names last_command
    set -l title (__prompt_context)' · '(prompt_pwd --dir-length=1 --full-length-dirs=1)
    if test -n "$last_command"
        set title "$title · $last_command"
    end
    printf '%s' "$title"
end
