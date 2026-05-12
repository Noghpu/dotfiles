#!/usr/bin/env nu
#
# Download all wheels (every platform/arch) and sdists from a uv.lock file.
#
# For each package:
#   - Downloads every listed wheel.
#   - If no wheels exist, downloads the sdist instead.
#
# Usage:
#   nu download_uv_lock.nu
#   nu download_uv_lock.nu --lock uv.lock --dest dist --threads 16
#   nu download_uv_lock.nu --dry-run

def url-filename []: string -> string {
    split row "/" | last | split row "#" | first | split row "?" | first
}

# Verify a "sha256:hexdigest" hash against a file on disk.
# Returns true when the hash matches or when nothing to verify.
def verify-hash [expected: string]: string -> bool {
    let path = $in
    if ($expected | is-empty) or not ($expected | str contains ":") {
        return true
    }
    let algo = ($expected | split row ":" | first)
    let digest = ($expected | str replace $"($algo):" "")
    if $algo != "sha256" {
        return true  # only sha256 is built-in
    }
    let actual = (open --raw $path | hash sha256)
    $actual == $digest
}

# Parse [[package]] entries from a uv.lock into a flat download table.
def parse-lock []: string -> table {
    let lock = (open --raw $in | from toml)
    let packages = ($lock | get -o package | default [])

    $packages | each {|pkg|
        let name = ($pkg | get -o name | default "<unknown>")
        let version = ($pkg | get -o version | default "0.0.0")
        let wheels = ($pkg | get -o wheels | default [])
        let sdist = ($pkg | get -o sdist)

        if ($wheels | length) > 0 {
            $wheels | each {|whl|
                let url = ($whl | get -o url | default "")
                let hash = ($whl | get -o hash | default "")
                if ($url | is-not-empty) {
                    {name: $name, version: $version, url: $url, hash: $hash, kind: "wheel"}
                }
            }
        } else if $sdist != null {
            let url = ($sdist | get -o url | default "")
            let hash = ($sdist | get -o hash | default "")
            if ($url | is-not-empty) {
                [{name: $name, version: $version, url: $url, hash: $hash, kind: "sdist"}]
            } else {
                []
            }
        } else {
            []
        }
    } | flatten | compact
}

# Download one artifact. Returns a status record for the summary table.
def fetch-one [dest: string, dry_run: bool]: record -> record {
    let dl = $in
    let fname = ($dl.url | url-filename)
    let target = ($dest | path join $fname)

    if ($target | path exists) and ($target | verify-hash $dl.hash) {
        return {status: "skip", file: $fname, msg: "already exists"}
    }

    if ($target | path exists) {
        rm $target
    }

    if $dry_run {
        return {status: "dry-run", file: $fname, msg: "would fetch"}
    }

    try {
        http get $dl.url | save --raw --force $target
    } catch {|e|
        return {status: "FAILED", file: $fname, msg: $e.msg}
    }

    if not ($target | verify-hash $dl.hash) {
        rm $target
        return {status: "HASH MISMATCH", file: $fname, msg: "hash did not match"}
    }

    {status: "ok", file: $fname, msg: ""}
}

# Catppuccin Mocha palette helpers. `(ansi {fg: "#..."})` applies a 24-bit
# foreground; reset closes it. Wrap a string by piping into the helper.
def cat-mauve   []: string -> string { $"(ansi {fg: '#cba6f7'})($in)(ansi reset)" }
def cat-text    []: string -> string { $"(ansi {fg: '#cdd6f4'})($in)(ansi reset)" }
def cat-red     []: string -> string { $"(ansi {fg: '#f38ba8'})($in)(ansi reset)" }
def cat-peach   []: string -> string { $"(ansi {fg: '#fab387'})($in)(ansi reset)" }
def cat-yellow  []: string -> string { $"(ansi {fg: '#f9e2af'})($in)(ansi reset)" }
def cat-green   []: string -> string { $"(ansi {fg: '#a6e3a1'})($in)(ansi reset)" }
def cat-sapphire []: string -> string { $"(ansi {fg: '#74c7ec'})($in)(ansi reset)" }
def cat-blue    []: string -> string { $"(ansi {fg: '#89b4fa'})($in)(ansi reset)" }
def cat-overlay1 []: string -> string { $"(ansi {fg: '#7f849c'})($in)(ansi reset)" }
def cat-subtext0 []: string -> string { $"(ansi {fg: '#a6adc8'})($in)(ansi reset)" }

def trunc [n: int]: string -> string {
    let s = $in
    if ($s | str length) > $n {
        ($s | str substring 0..($n - 2)) + "…"
    } else { $s }
}

def dist-key []: string -> string {
    str downcase | str replace --all "-" "_"
}

def artifact-name [module: string, width: int]: string -> string {
    let file = $in
    let shown = ($file | trunc $width)
    let padded = ($shown | fill -a l -w $width)
    let module_len = ($module | str length)
    let shown_len = ($shown | str length)

    if (($file | dist-key) | str starts-with ($module | dist-key)) {
        if (($file | str length) > $width) and ($module_len >= ($width - 1)) {
            return ($padded | cat-mauve)
        }
        let color_len = if $module_len < $shown_len { $module_len } else { $shown_len }
        if $color_len >= $shown_len {
            return ($padded | cat-mauve)
        }
        let head = ($padded | str substring 0..($color_len - 1) | cat-mauve)
        let tail = if ($padded | str length) > $color_len {
            $padded | str substring $color_len.. | cat-text
        } else { "" }
        $"($head)($tail)"
    } else {
        $padded | cat-text
    }
}

def repeat-char [n: int, ch: string]: nothing -> string {
    if $n <= 0 { return "" }
    0..<$n | each { $ch } | str join ""
}

def progress-bar [done: int, total: int, width: int]: nothing -> string {
    let filled = if $total > 0 { ($done * $width) // $total } else { 0 }
    let empty = ($width - $filled)
    let fill = (repeat-char $filled "█")
    let rest = (repeat-char $empty "░")
    $"($fill)($rest)"
}

# Read the current state by scanning per-index event files in $state_dir.
# Returns a record {ended: <list>, active: <list>}.
def read-state [state_dir: string, total: int]: nothing -> record {
    let scan = (0..<$total | each {|i|
        let end_path = ($state_dir | path join $"end-($i).json")
        let start_path = ($state_dir | path join $"start-($i).json")
        if ($end_path | path exists) {
            let rec = (try { open $end_path } catch { null })
            if $rec != null { {kind: "end", rec: $rec} } else { null }
        } else if ($start_path | path exists) {
            let rec = (try { open $start_path } catch { null })
            if $rec != null { {kind: "active", rec: $rec} } else { null }
        } else { null }
    } | compact)
    {
        ended: ($scan | where kind == "end" | get rec),
        active: ($scan | where kind == "active" | get rec)
    }
}

def download-uv-lock [
    --lock: string = "uv.lock"     # Path to the uv.lock file
    --dest: string = "dist"        # Destination directory for downloads
    --threads (-t): int = 16       # Number of parallel download workers
    --dry-run                      # Show what would be downloaded without fetching
] {
    if not ($lock | path exists) {
        error make -u {msg: $"Lock file not found: ($lock)"}
    }

    let downloads = (
        $lock
        | parse-lock
        | enumerate
        | each {|x| $x.item | insert idx $x.index}
    )
    let total = ($downloads | length)

    if $total == 0 {
        print "Nothing to download."
        return
    }

    let wheel_count = ($downloads | where kind == "wheel" | length)
    let sdist_count = ($downloads | where kind == "sdist" | length)
    let pkg_count = ($downloads | get name | uniq | length)

    mkdir $dest

    let mode_tag = if $dry_run { let t = ("[dry-run]" | cat-blue); $" ($t)" } else { "" }
    let h_total = ($"($total)" | cat-mauve)
    let h_pkgs = ($"($pkg_count)" | cat-mauve)
    let h_wheels = ($"($wheel_count) wheels" | cat-green)
    let h_sdists = ($"($sdist_count) sdists" | cat-yellow)
    print $"($h_total) artifacts across ($h_pkgs) packages — ($h_wheels), ($h_sdists)($mode_tag)"

    # Dry-run path: compute cache state for each artifact (in parallel, with
    # full hash verification) and list per-item state. No live UI, no fetch.
    if $dry_run {
        let states = (
            $downloads | par-each --threads $threads --keep-order {|dl|
                let fname = ($dl.url | url-filename)
                let target = ($dest | path join $fname)
                let exists = ($target | path exists)
                let hash_ok = if $exists { $target | verify-hash $dl.hash } else { false }
                $dl | insert file $fname | insert exists $exists | insert hash_ok $hash_ok
            }
        )
        let cached_count = ($states | where {|s| $s.exists and $s.hash_ok } | length)
        let to_fetch_count = ($total - $cached_count)

        let h_cached = ($"─ ($cached_count) already cached" | cat-overlay1)
        let h_tofetch = ($"⇣ ($to_fetch_count) to fetch" | cat-peach)
        print $"  ($h_cached) · ($h_tofetch)"
        print ""

        let file_w = 60

        for it in $states {
            let state = if $it.exists and $it.hash_ok {
                "cached" | cat-overlay1
            } else if $it.exists {
                "hash mismatch — will refetch" | cat-red
            } else {
                "will fetch" | cat-peach
            }
            let fname = ($it.file | artifact-name $it.name $file_w)
            print $"  ($fname)  ($state)"
        }
        print ""
        let s_cached = ($"($cached_count) cached" | cat-overlay1)
        let s_tofetch = ($"($to_fetch_count) would fetch" | cat-peach)
        let s_dest = ($"($dest)/" | cat-sapphire)
        print $"($s_cached), ($s_tofetch) → ($s_dest)"
        return
    }

    let state_dir = (mktemp -d -t "nudl-XXXXXXXX")

    # Workers run in a background job. Cached artifacts go straight to "end";
    # artifacts that need network work write "start" first so the renderer can
    # show them as active.
    let job_id = (
        job spawn {
            $downloads | par-each --threads $threads {|dl|
                let fname = ($dl.url | url-filename)
                let target = ($dest | path join $fname)
                if ($target | path exists) and ($target | verify-hash $dl.hash) {
                    try {
                        {
                            idx: $dl.idx,
                            name: $dl.name,
                            version: $dl.version,
                            file: $fname,
                            kind: $dl.kind,
                            status: "skip",
                            msg: "already exists"
                        } | save --force ($state_dir | path join $"end-($dl.idx).json")
                    }
                    return
                }

                try {
                    {idx: $dl.idx, name: $dl.name, version: $dl.version, file: $fname, kind: $dl.kind}
                        | save --force ($state_dir | path join $"start-($dl.idx).json")
                }
                let result = (try {
                    $dl | fetch-one $dest $dry_run
                } catch {|e|
                    {status: "FAILED", file: $fname, msg: $e.msg}
                })
                try {
                    {
                        idx: $dl.idx,
                        name: $dl.name,
                        version: $dl.version,
                        file: $fname,
                        kind: $dl.kind,
                        status: $result.status,
                        msg: $result.msg
                    } | save --force ($state_dir | path join $"end-($dl.idx).json")
                }
            } | ignore
        }
    )

    let spinner = ["⠋" "⠙" "⠹" "⠸" "⠼" "⠴" "⠦" "⠧" "⠇" "⠏"]
    let max_active_lines = 12
    let bar_width = 30
    let file_w = 60

    print -n $"(ansi cursor_off)"

    mut prev_lines = 0
    mut frame_idx = 0
    mut final_state = {ended: [], active: []}

    try {
        loop {
            let state = (read-state $state_dir $total)
            let done_count = ($state.ended | length)
            let fail_count = ($state.ended | where status in ["FAILED" "HASH MISMATCH"] | length)
            let skip_count = ($state.ended | where status == "skip" | length)

            let spin = ($spinner | get ($frame_idx mod ($spinner | length)))
            let bar = (progress-bar $done_count $total $bar_width)
            let pct = if $total > 0 { ($done_count * 100) // $total } else { 0 }

            let fail_tag = if $fail_count > 0 {
                $" · (ansi red_bold)($fail_count) failed(ansi reset)"
            } else { "" }
            let skip_tag = if $skip_count > 0 {
                $" · (ansi white_dimmed)($skip_count) cached(ansi reset)"
            } else { "" }

            let header = $"  (ansi cyan)[($bar)](ansi reset) (ansi cyan_bold)($done_count)/($total)(ansi reset) ($pct)%($fail_tag)($skip_tag)"

            let visible = ($state.active | first $max_active_lines)
            let hidden = (($state.active | length) - ($visible | length))

            let active_lines = ($visible | each {|a|
                let fname = ($a.file | artifact-name $a.name $file_w)
                let state = ("downloading" | cat-blue)
                $"  (ansi blue)($spin)(ansi reset) ($fname)  ($state)"
            })
            let overflow_line = if $hidden > 0 {
                [$"  (ansi white_dimmed)… ($hidden) more in flight(ansi reset)"]
            } else { [] }

            let frame = ([$header] ++ $active_lines ++ $overflow_line)

            # Clear previous frame in place, then redraw.
            if $prev_lines > 0 {
                print -n $"(ansi csi)($prev_lines)A(ansi csi)0J"
            }
            for line in $frame { print $line }
            $prev_lines = ($frame | length)
            $frame_idx = ($frame_idx + 1)

            if $done_count >= $total {
                $final_state = $state
                break
            }
            sleep 100ms
        }
    } catch {|e|
        print -n $"(ansi cursor_on)"
        print $"(ansi red_bold)Renderer error:(ansi reset) ($e.msg)"
    }

    # Erase the live region so the terminal is clean for the summary.
    if $prev_lines > 0 {
        print -n $"(ansi csi)($prev_lines)A(ansi csi)0J"
    }
    print -n $"(ansi cursor_on)"

    let results = $final_state.ended
    let ok_count = ($results | where status == "ok" | length)
    let skip_count = ($results | where status == "skip" | length)
    let failures = ($results | where status in ["FAILED" "HASH MISMATCH"])
    let fail_count = ($failures | length)

    # Clean up state files (best-effort).
    try { rm -rf $state_dir }

    if $fail_count > 0 {
        print $"(ansi red_bold)error(ansi reset): ($fail_count) of ($total) downloads failed"
        for r in $failures {
            let fname = ($r.file | artifact-name $r.name $file_w)
            let state = ($r.status | cat-red)
            print $"  (ansi red_bold)✗(ansi reset) ($fname)  ($state)"
            print $"      (ansi white_dimmed)($r.msg)(ansi reset)"
        }
        print ""
    }

    let summary_parts = [
        $"(ansi green)($ok_count) ok(ansi reset)"
        $"(ansi white_dimmed)($skip_count) cached(ansi reset)"
        (if $fail_count > 0 { $"(ansi red_bold)($fail_count) failed(ansi reset)" } else { null })
    ] | compact
    let joined = ($summary_parts | str join ", ")
    if $fail_count > 0 {
        print $joined
    } else {
        print $"($joined) → (ansi cyan)($dest)/(ansi reset)"
    }
}
