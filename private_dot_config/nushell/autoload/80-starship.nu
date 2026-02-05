# starship prompt

$env.STARSHIP_CONFIG = ($nu.home-dir | path join ".config" "starship" "starship.toml")

if (which starship | is-empty) { return }

$env.PROMPT_COMMAND = {|| starship prompt }
$env.PROMPT_COMMAND_RIGHT = {|| starship prompt --right }
$env.PROMPT_INDICATOR = ""
$env.PROMPT_INDICATOR_VI_INSERT = ""
$env.PROMPT_INDICATOR_VI_NORMAL = ""
$env.PROMPT_MULTILINE_INDICATOR = {|| starship prompt --continuation }
$env.TRANSIENT_PROMPT_COMMAND = {|| starship module character }
