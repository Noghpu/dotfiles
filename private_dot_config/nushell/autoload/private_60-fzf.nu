# fzf keybindings

if (which fzf | is-empty) { return }

# Ctrl+R - Fuzzy history search (fzf only)
$env.config.keybindings ++= [
    {
        name: fuzzy_history
        modifier: control
        keycode: char_r
        mode: [emacs, vi_normal, vi_insert]
        event: {
            send: executehostcommand
            cmd: "commandline edit --replace (
                history
                | get command
                | reverse
                | uniq
                | str join (char -i 0)
                | fzf --read0 --layout=reverse --height=40% -q (commandline)
                | decode utf-8
                | str trim
            )"
        }
    }
]

# Ctrl+T and Alt+C require fd
if (which fd | is-not-empty) {
    $env.config.keybindings ++= [
        # Ctrl+T - Fuzzy file search with fd + fzf
        {
            name: fuzzy_file
            modifier: control
            keycode: char_t
            mode: [emacs, vi_normal, vi_insert]
            event: {
                send: executehostcommand
                cmd: "commandline edit --insert (fd --type f --hidden --exclude .git | fzf --layout=reverse --height=40% | str trim)"
            }
        }
        # Alt+C - Fuzzy directory cd with fd + fzf
        {
            name: fuzzy_cd
            modifier: alt
            keycode: char_c
            mode: [emacs, vi_normal, vi_insert]
            event: {
                send: executehostcommand
                cmd: "cd (fd --type d --hidden --exclude .git | fzf --layout=reverse --height=40% | str trim)"
            }
        }
    ]
}

# Ctrl+J - Fuzzy just recipe picker (requires just)
if (which just | is-not-empty) {
    $env.config.keybindings ++= [
        {
            name: fzf_just
            modifier: control
            keycode: char_j
            mode: [emacs, vi_normal, vi_insert]
            event: {
                send: executehostcommand
                cmd: "let recipe = (
                    do { just --list --list-heading '' --list-prefix '' } | complete | get stdout
                    | lines
                    | each { str trim }
                    | where { $in != '' }
                    | str join (char nl)
                    | fzf --height=40% --layout=reverse --border=rounded --info=inline --prompt='just › ' --header='Ctrl-/ toggle preview │ Enter select' --preview='just --show {1}' --preview-window='right:50%:border-left:nowrap' --bind='ctrl-/:toggle-preview'
                    | decode utf-8
                    | str trim
                    | split row ' '
                    | get 0
                ); if ($recipe | is-not-empty) { commandline edit --insert $'just ($recipe) ' }"
            }
        }
    ]
}
