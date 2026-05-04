export def bat [...args: string] {
    if (which bat | is-not-empty) {
        ^bat ...$args
    } else {
        error make { msg: "bat: bat is required" }
    }
}

export def fd [...args: string] {
    if (which fd | is-not-empty) {
        ^fd ...$args
    } else {
        error make { msg: "fd: fd is required" }
    }
}

export def la [...patterns: glob] {
    if ($patterns | is-empty) {
        ls --all --long
    } else {
        ls --all --long ...$patterns
    }
}

export def ll [...patterns: glob] {
    if ($patterns | is-empty) {
        ls --long
    } else {
        ls --long ...$patterns
    }
}

export def lt [...patterns: string] {
    if ($patterns | is-empty) {
        ls --all **/*
    } else {
        $patterns
        | each {|pattern| glob $pattern }
        | flatten
        | each {|path|
            if ($path | path type) == "dir" {
                let recursive_pattern = $"($path | str replace --all "\\" "/")/**/*"
                [$path] | append (glob $recursive_pattern)
            } else {
                [$path]
            }
        }
        | flatten
        | uniq
        | each {|path| ls --directory $path }
        | flatten
    }
}

export def "l." [] {
    ls --all | where name =~ '(^|[\\/])\.'
}

export def cm [...args: string] {
    ^chezmoi ...$args
}

export def cmca [] {
    ^chezmoi re-add .
    ^chezmoi git add .
    ^chezmoi git commit -- -a -m update
}

export def lg [...args: string] {
    ^lazygit ...$args
}

export def tug [] {
    ^jj bookmark move --from "heads(::@- & bookmarks())" --to @-
}

export def uvim [...args: string] {
    ^uv run nvim ...$args
}

export def uvr [...args: string] {
    ^uv run ...$args
}
