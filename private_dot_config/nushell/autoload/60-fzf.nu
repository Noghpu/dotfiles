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
