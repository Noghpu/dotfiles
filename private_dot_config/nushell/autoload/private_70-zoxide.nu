# zoxide integration

if (which zoxide | is-empty) { return }

# z - jump to directory
def --env z [...rest: string] {
    if ($rest | is-empty) {
        cd ~
    } else {
        let result = (zoxide query ...$rest)
        cd $result
    }
}

# zi - interactive jump
def --env zi [...rest: string] {
    let result = (zoxide query -i ...$rest)
    cd $result
}

# Hook to add directories to zoxide database
$env.config.hooks.env_change.PWD = (
    $env.config.hooks.env_change
    | get -i PWD
    | default []
    | append {||
        zoxide add -- $env.PWD
    }
)

# Ctrl+F - Zoxide interactive
$env.config.keybindings ++= [
    {
        name: zoxide_interactive
        modifier: control
        keycode: char_f
        mode: [emacs, vi_normal, vi_insert]
        event: {
            send: executehostcommand
            cmd: "zi"
        }
    }
]
