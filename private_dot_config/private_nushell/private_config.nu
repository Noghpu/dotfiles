# Keep config.nu focused on Nushell/Reedline behavior; commands live in autoload.

source ~/.config/nushell/autoload/00-env.nu
source ~/.config/nushell/autoload/01-core.nu
source ~/.config/nushell/autoload/05-prompt.nu
source ~/.config/nushell/autoload/10-tools.nu
source ~/.config/nushell/autoload/20-yazi.nu
source ~/.config/nushell/autoload/30-carapace.nu
source ~/.config/nushell/autoload/40-fzf.nu
source ~/.config/nushell/autoload/50-codex.nu

$env.config = ($env.config | merge {
    show_banner: false
    edit_mode: vi
    buffer_editor: "nvim"
    cursor_shape: {
        vi_insert: line
        vi_normal: block
    }
    history: {
        max_size: 100000
        sync_on_enter: true
        file_format: sqlite
        isolation: false
    }
    completions: {
        case_sensitive: false
        quick: true
        partial: true
        algorithm: fuzzy
        external: {
            enable: true
            max_results: 100
            completer: (if (which carapace | is-not-empty) {
                {|spans| carapace-complete $spans }
            } else {
                null
            })
        }
    }
    table: {
        mode: rounded
        index_mode: auto
        show_empty: true
        padding: { left: 1, right: 1 }
    }
    shell_integration: {
        osc2: true
        osc7: true
        osc8: true
        osc9_9: false
        osc133: true
        osc633: true
        reset_application_mode: true
    }
    hooks: {
        pre_prompt: []
        pre_execution: []
        env_change: {
            PWD: []
        }
        display_output: "if (term size).columns >= 100 { table -e } else { table }"
        command_not_found: null
    }
    keybindings: [
        {
            name: fzf_just
            modifier: control
            keycode: char_j
            mode: [vi_insert vi_normal emacs]
            event: { send: executehostcommand, cmd: "fzf_just" }
        }
    ]
})

if (which zoxide | is-not-empty) {
    source ~/.cache/zoxide.nu
}

source ~/.config/nushell/local.nu

use-native-prompt
