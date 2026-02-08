# ~/.config/fish/completions/par.fish

set -l subcmds install i remove r autoremove upgrade u search s info which w list orphans clean files owner

# no file completions by default
complete -c par -f

# subcommands (only when no subcommand given yet)
complete -c par -n "not __fish_seen_subcommand_from $subcmds" -a install -d "Install packages"
complete -c par -n "not __fish_seen_subcommand_from $subcmds" -a remove -d "Remove packages + deps"
complete -c par -n "not __fish_seen_subcommand_from $subcmds" -a autoremove -d "Remove orphans"
complete -c par -n "not __fish_seen_subcommand_from $subcmds" -a upgrade -d "System upgrade"
complete -c par -n "not __fish_seen_subcommand_from $subcmds" -a search -d "Search repos/AUR"
complete -c par -n "not __fish_seen_subcommand_from $subcmds" -a info -d "Package info"
complete -c par -n "not __fish_seen_subcommand_from $subcmds" -a which -d "Search installed"
complete -c par -n "not __fish_seen_subcommand_from $subcmds" -a list -d "List explicit packages"
complete -c par -n "not __fish_seen_subcommand_from $subcmds" -a orphans -d "List orphans"
complete -c par -n "not __fish_seen_subcommand_from $subcmds" -a clean -d "Clear cache"
complete -c par -n "not __fish_seen_subcommand_from $subcmds" -a files -d "Files owned by pkg"
complete -c par -n "not __fish_seen_subcommand_from $subcmds" -a owner -d "Find pkg owning file"

# complete package names from sync db for install/search/info
complete -c par -n "__fish_seen_subcommand_from install i search s info" \
    -a "(paru -Slq 2>/dev/null)"

# complete installed packages for remove/files/which
complete -c par -n "__fish_seen_subcommand_from remove r files which w" \
    -a "(paru -Qq 2>/dev/null)"

# owner takes file paths
complete -c par -n "__fish_seen_subcommand_from owner" -F
