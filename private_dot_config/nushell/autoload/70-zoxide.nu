# zoxide keybinding

if (which zoxide | is-empty) { return }

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
