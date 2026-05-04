def prompt-style [color: string, text: string, --bold] {
    let style = if $bold {
        ansi --escape { fg: $color, attr: b }
    } else {
        ansi --escape { fg: $color }
    }

    $"($style)($text)(ansi reset)"
}

def prompt-short-path [] {
    let home = ($nu.home-dir)
    let raw_path = (pwd)
    let display_path = if ($raw_path | str starts-with $home) {
        $raw_path | str replace $home "~"
    } else {
        $raw_path
    }

    let substituted = (
        $display_path
        | str replace "Documents" "󰈙 "
        | str replace "Downloads" " "
        | str replace "Music" "󰝚 "
        | str replace "Pictures" " "
        | str replace "Developer" "󰓓 "
    )

    let separator = if ($substituted | str contains "\\") { "\\" } else { "/" }
    let parts = ($substituted | split row --regex '[\\/]')

    if ($parts | length) > 3 {
        let tail = ($parts | last 3 | str join $separator)
        $"…($separator)($tail)"
    } else {
        $substituted
    }
}

def prompt-duration [] {
    let raw = ($env.CMD_DURATION_MS? | default "0")
    let ms = if $raw == "0823" { 0 } else { $raw | into int }

    if $ms < 1000 {
        ""
    } else if $ms < 60000 {
        let seconds = (($ms / 1000.0) | math round --precision 1)
        $" ($seconds)s"
    } else {
        let minutes = ($ms // 60000)
        let seconds = (($ms mod 60000) // 1000)
        $" ($minutes)m($seconds)s"
    }
}

def native-left-prompt [] {
    let tmux = if ($env.TMUX? | default "" | is-not-empty) {
        prompt-style "#f9e2af" " "
    } else {
        ""
    }

    let os = (prompt-style "#b4befe" "")
    let username = (prompt-style "#f5c2e7" $" ($env.USERNAME? | default $env.USER? | default '')")
    let hostname = if ($env.SSH_CONNECTION? | default "" | is-not-empty) {
        prompt-style "#cba6f7" $"@($env.COMPUTERNAME? | default $env.HOSTNAME? | default '') "
    } else {
        ""
    }
    let directory = (prompt-style "#a6e3a1" $" (prompt-short-path)")
    let time = (prompt-style "#89dceb" $"  ((date now) | format date '%H:%M')")
    let duration = (prompt-style "#94e2d5" (prompt-duration))
    let status = ($env.LAST_EXIT_CODE? | default 0)
    let character_color = if $status == 0 { "#a6e3a1" } else { "#f38ba8" }
    let character = (prompt-style $character_color "❯" --bold)

    $"($tmux)($os)($username)($hostname)($directory)($time)($duration)\n($character) "
}

def native-right-prompt [] {
    ""
}

def native-multiline-indicator [] {
    "::: "
}

def native-transient-prompt [] {
    let status = ($env.LAST_EXIT_CODE? | default 0)
    let character_color = if $status == 0 { "#a6e3a1" } else { "#f38ba8" }

    $"(prompt-style $character_color "❯" --bold) "
}

def --env use-native-prompt [] {
    $env.PROMPT_COMMAND = {|| native-left-prompt }
    $env.PROMPT_COMMAND_RIGHT = {|| native-right-prompt }
    $env.PROMPT_INDICATOR = ""
    $env.PROMPT_INDICATOR_VI_INSERT = ""
    $env.PROMPT_INDICATOR_VI_NORMAL = ""
    $env.PROMPT_MULTILINE_INDICATOR = {|| native-multiline-indicator }
    $env.TRANSIENT_PROMPT_COMMAND = {|| native-transient-prompt }
    $env.TRANSIENT_PROMPT_COMMAND_RIGHT = ""
    $env.TRANSIENT_PROMPT_INDICATOR = ""
    $env.TRANSIENT_PROMPT_INDICATOR_VI_INSERT = ""
    $env.TRANSIENT_PROMPT_INDICATOR_VI_NORMAL = ""
    $env.TRANSIENT_PROMPT_MULTILINE_INDICATOR = ""
}
