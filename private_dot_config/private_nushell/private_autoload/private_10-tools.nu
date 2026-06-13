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

export def lg [...args: string] {
    ^lazygit ...$args
}

export def uvim [...args: string] {
    ^uv run nvim ...$args
}

export def uvr [...args: string] {
    ^uv run ...$args
}
