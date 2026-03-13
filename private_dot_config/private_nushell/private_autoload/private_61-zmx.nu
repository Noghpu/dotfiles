# zmx session picker

if (which zmx | is-empty) or (which fzf | is-empty) { return }

# Ctrl+S - Fuzzy zmx session picker/creator
$env.config.keybindings ++= [
    {
        name: fzf_zmx
        modifier: control
        keycode: char_s
        mode: [emacs, vi_normal, vi_insert]
        event: {
            send: executehostcommand
            cmd: "let sessions = (
                do { zmx list } | complete | get stdout
                | lines
                | where { $in != '' }
                | each {|line|
                    let name = ($line | parse --regex 'session_name=(?P<v>\S+)' | get -i 0.v | default '')
                    let pid = ($line | parse --regex 'pid=(?P<v>\S+)' | get -i 0.v | default '')
                    let clients = ($line | parse --regex 'clients=(?P<v>\S+)' | get -i 0.v | default '')
                    let dir = ($line | parse --regex 'started_in=(?P<v>\S+)' | get -i 0.v | default '')
                    $'($name | fill -w 20)  pid:($pid | fill -w 8)  clients:($clients | fill -w 2)  ($dir)'
                }
                | str join (char nl)
            ); let result = (
                $sessions
                | fzf --print-query --expect=ctrl-n --height=80% --layout=reverse --border=rounded --prompt='zmx › ' --header='Enter: attach │ Ctrl-N: new session' --preview='zmx history {1}' --preview-window='right:60%:follow'
                | decode utf-8
                | str trim
                | lines
            ); let query = ($result | get -i 0 | default ''); let key = ($result | get -i 1 | default ''); let selected = ($result | get -i 2 | default ''); let session = (
                if $key == 'ctrl-n' and ($query | is-not-empty) { $query }
                else if ($selected | is-not-empty) { $selected | split row ' ' | get 0 }
                else if ($query | is-not-empty) { $query }
                else { '' }
            ); if ($session | is-not-empty) { zmx attach $session }"
        }
    }
]
