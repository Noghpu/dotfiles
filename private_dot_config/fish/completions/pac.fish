function __fish_pac_subcommands
    echo install\t"Install packages"
    echo update\t"Update system"
    echo remove\t"Remove packages"
    echo purge\t"Remove packages and configs"
    echo search\t"Search for packages"
    echo info\t"Show package info"
    echo list\t"List installed packages"
    echo clean\t"Clean package cache"
    echo orphans\t"List orphaned packages"
    echo help\t"Show help for pac commands"
end

function __fish_pac_installed_packages
    pacman -Q | string replace -r '(\S+).*' '$1'
end

function __fish_pac_available_packages
    # Cache package list for 60 minutes to avoid slow completions
    set -l cache_file /tmp/pacman_cache
    set -l now (date +%s)

    # Use cached package list if available and less than an hour old
    if test -f $cache_file
        set -l mod_time (stat -c %Y $cache_file)
        set -l age (math $now - $mod_time)

        if test $age -lt 3600
            cat $cache_file
            return
        end
    end

    # Generate new cache
    pacman -Ss | string replace -r '^([^/]+/\S+).*' '$1' | string replace / ' ' | string replace -r '(^\S+)\s+(\S+).*' '$2' >$cache_file
    cat $cache_file
end

# Main command completion
complete -c pac -f

# Subcommands
complete -c pac -n __fish_use_subcommand -a "(__fish_pac_subcommands)"

# Arguments for install, search, info
complete -c pac -n "__fish_seen_subcommand_from install search info" -a "(__fish_pac_available_packages)"

# Arguments for remove, purge, list
complete -c pac -n "__fish_seen_subcommand_from remove purge list" -a "(__fish_pac_installed_packages)"

# No additional arguments for these commands
complete -c pac -n "__fish_seen_subcommand_from update clean orphans help" -f
