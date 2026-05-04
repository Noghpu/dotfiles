def fzf-present [] {
    if (which fzf | is-empty) {
        error make { msg: "fzf is required" }
    }
}

export def fzf_just [] {
    fzf-present
    if (which just | is-empty) {
        error make { msg: "fzf_just: just is required" }
    }

    let summary = (^just --summary | complete)
    if $summary.exit_code != 0 {
        print -e "fzf_just: No justfile found"
        return
    }

    let recipes = (
        ^just --list --list-heading "" --list-prefix ""
        | lines
        | each {|line| $line | str trim }
        | where {|line| $line | is-not-empty }
    )

    if ($recipes | is-empty) {
        print -e "fzf_just: No recipes found in justfile"
        return
    }

    let selection = (
        $recipes
        | str join "\n"
        | ^fzf --height=40% --layout=reverse --border=rounded --info=inline --prompt="just > " --header="Enter select" --preview="just --show {1}" --preview-window="right:50%:border-left:nowrap"
    )

    if ($selection | str trim | is-empty) {
        return
    }

    let recipe = ($selection | split row " " | first)
    commandline edit --insert $"just ($recipe) "
}

export def ssh-hosts [] {
    let config_files = [
        ($nu.home-dir | path join ".ssh" "config")
        "/etc/ssh/ssh_config"
    ]

    $config_files
    | where {|file| $file | path exists }
    | each {|file| open --raw $file | lines }
    | flatten
    | each {|line| $line | str trim }
    | where {|line| $line =~ '^(?i)host\\s+' }
    | each {|line| $line | str replace --regex '^(?i)host\\s+' "" | split row --regex "\\s+" }
    | flatten
    | where {|host| $host !~ '[*?]' }
    | uniq
    | sort
}

export extern "ssh" [
    host?: string@ssh-hosts
    ...args: string
]
