if (which carapace | is-not-empty) {
    let carapace_bin = ($env.XDG_CONFIG_HOME | path join "carapace" "bin")
    if ($carapace_bin | path exists) {
        $env.PATH = (
            $env.PATH
            | where {|entry| $entry != $carapace_bin }
            | prepend $carapace_bin
        )
    }
}

export def carapace-complete [spans: list<string>] {
    if (which carapace | is-empty) {
        return []
    }

    let expanded_alias = (scope aliases | where name == ($spans | get 0) | get -o 0 | get -o expansion)
    let expanded_spans = if $expanded_alias != null {
        $spans
        | skip 1
        | prepend ($expanded_alias | split row " " | first | str replace --regex '\.exe$' "")
    } else {
        $spans
        | skip 1
        | prepend (($spans | get 0) | str replace --regex '\.exe$' "")
    }

    with-env {
        CARAPACE_SHELL_BUILTINS: (
            help commands
            | default "" category
            | where category != ""
            | get name
            | each {|name| $name | split row " " | first }
            | uniq
            | str join "\n"
        )
        CARAPACE_SHELL_FUNCTIONS: (
            help commands
            | default "" category
            | where category == ""
            | get name
            | each {|name| $name | split row " " | first }
            | uniq
            | str join "\n"
        )
    } {
        ^carapace ($expanded_spans | get 0) nushell ...$expanded_spans
        | from json
    }
}
