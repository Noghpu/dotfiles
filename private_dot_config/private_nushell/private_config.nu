# Nushell Configuration
# Location: ~/.config/nushell/config.nu
# Environment setup in autoload/00-env.nu
# Tool-specific configs are in autoload/

# =============================================================================
# MAIN CONFIGURATION (dot-notation style)
# =============================================================================

$env.config.show_banner = false

# Vi editing mode
$env.config.edit_mode = vi
$env.config.cursor_shape.vi_insert = line
$env.config.cursor_shape.vi_normal = block
$env.config.cursor_shape.emacs = line
$env.config.buffer_editor = 'nvim'

# History settings
$env.config.history.file_format = sqlite
$env.config.history.max_size = 100000
$env.config.history.sync_on_enter = true
$env.config.history.isolation = false

# Completions
$env.config.completions.case_sensitive = false
$env.config.completions.quick = true
$env.config.completions.partial = true
$env.config.completions.algorithm = fuzzy
$env.config.completions.use_ls_colors = true

# Table display
$env.config.table.mode = rounded
$env.config.table.index_mode = auto
$env.config.table.show_empty = true
$env.config.table.padding = { left: 1, right: 1 }
$env.config.table.trim = {
    methodology: wrapping
    wrapping_try_keep_words: true
}
$env.config.table.header_on_separator = false

# Error display
$env.config.error_style = fancy

# Shell integration (Windows Terminal)
$env.config.shell_integration.osc2 = true
$env.config.shell_integration.osc7 = true
$env.config.shell_integration.osc8 = true
$env.config.shell_integration.osc9_9 = false
$env.config.shell_integration.osc133 = true
$env.config.shell_integration.osc633 = true
$env.config.shell_integration.reset_application_mode = true

# =============================================================================
# COMPLETIONS
# =============================================================================

use ($nu.default-config-dir | path join "completions" "ssh-completions.nu") *
