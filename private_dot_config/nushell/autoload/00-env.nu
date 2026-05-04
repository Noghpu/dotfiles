export-env {
    let home = $nu.home-dir

    load-env {
        XDG_CONFIG_HOME: ($env.XDG_CONFIG_HOME? | default ($home | path join ".config"))
        XDG_DATA_HOME: ($env.XDG_DATA_HOME? | default ($home | path join ".local" "share"))
        XDG_CACHE_HOME: ($env.XDG_CACHE_HOME? | default ($home | path join ".cache"))
        XDG_STATE_HOME: ($env.XDG_STATE_HOME? | default ($home | path join ".local" "state"))
        XDG_DATA_DIRS: ($env.XDG_DATA_DIRS? | default "/usr/local/share:/usr/share")
        XDG_CONFIG_DIRS: ($env.XDG_CONFIG_DIRS? | default "/etc/xdg")
        EDITOR: ($env.EDITOR? | default "nvim")
        VISUAL: ($env.VISUAL? | default "nvim")
        MANROFFOPT: "-c"
    }

    let path_additions = [
        ($home | path join ".local" "bin")
        ($home | path join ".cargo" "bin")
        ($home | path join "Applications" "depot_tools")
    ]

    let current_path = (
        $env.PATH?
        | default []
        | if ($in | describe) == "string" { split row (char esep) } else { $in }
    )

    $env.PATH = (
        $path_additions
        | where {|p| $p != "" and ($p | path exists) }
        | append $current_path
        | uniq
    )

    if (which nvim | is-not-empty) {
        $env.EDITOR = "nvim"
        $env.VISUAL = "nvim"
    }

    if (which bat | is-not-empty) {
        $env.MANPAGER = "sh -c 'col -bx | bat -l man -p'"
        $env.BAT_THEME = "catppuccin-mocha"
        $env.BAT_CONFIG_DIR = ($env.XDG_CONFIG_HOME | path join "bat")
        $env.BAT_CONFIG_PATH = ($env.XDG_CONFIG_HOME | path join "bat" "config")
    }

    if (which rg | is-not-empty) {
        $env.RIPGREP_CONFIG_PATH = ($env.XDG_CONFIG_HOME | path join "ripgrep" ".ripgreprc")
    }

    if (which lazygit | is-not-empty) {
        $env.CONFIG_DIR = ($env.XDG_CONFIG_HOME | path join "lazygit")
    }

    if (which zoxide | is-not-empty) {
        zoxide init nushell | save -f ($env.XDG_CACHE_HOME | path join "zoxide.nu")
    } else if not (($env.XDG_CACHE_HOME | path join "zoxide.nu") | path exists) {
        "" | save -f ($env.XDG_CACHE_HOME | path join "zoxide.nu")
    }

    let local_config = ($env.XDG_CONFIG_HOME | path join "nushell" "local.nu")
    if not ($local_config | path exists) {
        "" | save -f $local_config
    }
}
