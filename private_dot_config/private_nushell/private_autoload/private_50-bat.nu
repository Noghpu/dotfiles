# bat (syntax highlighting) alias and env vars

if (which bat | is-empty) { return }

$env.BAT_THEME = "catppuccin-mocha"
$env.BAT_CONFIG_DIR = ($env.XDG_CONFIG_HOME | path join "bat")
$env.BAT_CONFIG_PATH = ($env.XDG_CONFIG_HOME | path join "bat" "config")

alias cat = bat
