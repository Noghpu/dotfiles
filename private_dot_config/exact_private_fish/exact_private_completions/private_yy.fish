# ~/.config/fish/completions/yy.fish
# Mirror of completions/par.fish, against yay instead of paru.

set -l subcmds install i remove r autoremove upgrade u search s info which w list orphans clean files owner

# no file completions by default
complete -c yy -f

# subcommands (only when no subcommand given yet)
complete -c yy -n "not __fish_seen_subcommand_from $subcmds" -a install -d "Install packages"
complete -c yy -n "not __fish_seen_subcommand_from $subcmds" -a remove -d "Remove packages + deps"
complete -c yy -n "not __fish_seen_subcommand_from $subcmds" -a autoremove -d "Remove orphans"
complete -c yy -n "not __fish_seen_subcommand_from $subcmds" -a upgrade -d "System upgrade"
complete -c yy -n "not __fish_seen_subcommand_from $subcmds" -a search -d "Search repos/AUR"
complete -c yy -n "not __fish_seen_subcommand_from $subcmds" -a info -d "Package info"
complete -c yy -n "not __fish_seen_subcommand_from $subcmds" -a which -d "Search installed"
complete -c yy -n "not __fish_seen_subcommand_from $subcmds" -a list -d "List explicit packages"
complete -c yy -n "not __fish_seen_subcommand_from $subcmds" -a orphans -d "List orphans"
complete -c yy -n "not __fish_seen_subcommand_from $subcmds" -a clean -d "Clear cache"
complete -c yy -n "not __fish_seen_subcommand_from $subcmds" -a files -d "Files owned by pkg"
complete -c yy -n "not __fish_seen_subcommand_from $subcmds" -a owner -d "Find pkg owning file"

# complete package names from sync db for install/search/info
complete -c yy -n "__fish_seen_subcommand_from install i search s info" \
    -a "(yay -Slq 2>/dev/null)"

# complete installed packages for remove/files/which
complete -c yy -n "__fish_seen_subcommand_from remove r files which w" \
    -a "(yay -Qq 2>/dev/null)"

# owner takes file paths
complete -c yy -n "__fish_seen_subcommand_from owner" -F
