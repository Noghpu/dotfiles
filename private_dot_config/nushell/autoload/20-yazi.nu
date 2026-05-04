export def --env y [...args: string] {
    if (which yazi | is-empty) {
        error make { msg: "y: yazi is required" }
    }

    let tmp = (mktemp -t "yazi-cwd.XXXXXX")
    ^yazi ...$args --cwd-file $tmp

    let cwd = if ($tmp | path exists) { open --raw $tmp | str trim } else { "" }
    rm -f $tmp

    if ($cwd | is-not-empty) and $cwd != (pwd) {
        cd $cwd
    }
}
