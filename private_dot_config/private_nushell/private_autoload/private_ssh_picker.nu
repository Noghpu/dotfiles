# SSH host picker using fzf

if (which fzf | is-empty) { return }

# Extract SSH hosts from config and present via fzf
def ssh-hosts []: nothing -> string {
    let config_file = $"($env.HOMEPATH)/.ssh/config"

    if not ($config_file | path exists) {
        print -e "No SSH config found"
        return ""
    }

    let lines = open $config_file | lines

    # Extract hosts with preceding comment as description
    let hosts = $lines
        | enumerate
        | where {|r| $r.item =~ '(?i)^Host\s+' }
        | each {|r|
            let host = $r.item | parse --regex '(?i)^Host\s+(?<host>.+)$' | get 0.host | str trim
            let comment = if $r.index > 0 {
                let prev = $lines | get ($r.index - 1)
                if ($prev =~ '^\s*#') {
                    $prev | str replace '^\s*#\s*' '' | str trim
                } else { "" }
            } else { "" }
            { host: $host, comment: $comment }
        }
        | where {|r| $r.host !~ '\*' }

    if ($hosts | is-empty) {
        print -e "No hosts found in SSH config"
        return ""
    }

    # Format: "hostname -- comment" or just "hostname"
    let display = $hosts
        | each {|r|
            if ($r.comment | is-empty) { $r.host } else { $"($r.host) -- ($r.comment)" }
        }
        | str join (char nl)

    let selected = (
        $display
        | ^fzf --height=40%
              --layout=reverse
              --border
              --prompt="SSH > "
        | decode utf-8
        | str trim
        | split row ' -- '
        | get 0
    )

    $selected
}

# Keybinding configuration
$env.config.keybindings ++= [
    {
        name: ssh_host_picker
        modifier: control
        keycode: char_s
        mode: [vi_insert vi_normal]
        event: {
            send: executehostcommand
            cmd: "let host = (ssh-hosts); if ($host | is-not-empty) { commandline edit --insert $'ssh ($host)' }"
        }
    }
]
