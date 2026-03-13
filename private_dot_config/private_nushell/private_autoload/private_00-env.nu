# Environment variables and PATH setup

$env.EDITOR = 'nvim'
$env.VISUAL = 'nvim'

# XDG Base Directory
$env.XDG_CONFIG_HOME = ($nu.home-dir | path join ".config")
$env.XDG_DATA_HOME = ($nu.home-dir | path join ".local" "share")
$env.XDG_CACHE_HOME = ($nu.home-dir | path join ".cache")
$env.XDG_STATE_HOME = ($nu.home-dir | path join ".local" "state")

# Ripgrep config
$env.RIPGREP_CONFIG_PATH = ($env.XDG_CONFIG_HOME | path join "ripgrep" ".ripgreprc")

# PATH additions (last prepend = highest priority)
$env.PATH = (
    $env.PATH
    | prepend ($nu.home-dir | path join "Applications" "depot_tools")
    | prepend ($nu.home-dir | path join "scoop" "shims")
    | prepend ($nu.home-dir | path join ".cargo" "bin")
    | prepend ($nu.home-dir | path join ".local" "bin")
    | uniq
)
