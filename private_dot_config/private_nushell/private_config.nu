# Nushell Configuration
# Location: ~/.config/nushell/config.nu
# Tool-specific configs are in autoload/

# =============================================================================
# ENVIRONMENT VARIABLES
# =============================================================================

$env.EDITOR = 'nvim'
$env.VISUAL = 'nvim'

# User directories
$env.XDG_CONFIG_HOME = ($nu.home-dir | path join ".config")
$env.XDG_DATA_HOME = ($nu.home-dir | path join ".local/share")
$env.XDG_CACHE_HOME = ($nu.home-dir | path join ".cache")
$env.XDG_STATE_HOME = ($nu.home-dir | path join ".local/state")

# =============================================================================
# MAIN CONFIGURATION
# =============================================================================

$env.config = {
    show_banner: false

    # Vi editing mode
    edit_mode: vi
    cursor_shape: {
        vi_insert: line
        vi_normal: block
        emacs: line
    }
    buffer_editor: 'nvim'

    # History settings
    history: {
        file_format: sqlite
        max_size: 100000
        sync_on_enter: true
        isolation: false
    }

    # Completions
    completions: {
        case_sensitive: false
        quick: true
        partial: true
        algorithm: fuzzy
        use_ls_colors: true
    }

    # Table display
    table: {
        mode: rounded
        index_mode: auto
        show_empty: true
        padding: { left: 1, right: 1 }
        trim: {
            methodology: wrapping
            wrapping_try_keep_words: true
        }
        header_on_separator: false
    }

    # Error display
    error_style: fancy

    # Shell integration (Windows Terminal)
    shell_integration: {
        osc2: true
        osc7: true
        osc8: true
        osc9_9: false
        osc133: true
        osc633: true
        reset_application_mode: true
    }

    # Hooks
    hooks: {
        pre_prompt: []
        pre_execution: []
        env_change: {}
    }

    # Keybindings (tool-specific keybindings are in autoload/)
    keybindings: []
}

# =============================================================================
# COMPLETIONS
# =============================================================================

use ($nu.default-config-dir | path join "completions" "ssh-completions.nu") *
