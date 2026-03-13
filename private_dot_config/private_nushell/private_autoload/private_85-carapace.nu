# carapace external completer

if (which carapace | is-empty) { return }

$env.CARAPACE_BRIDGES = 'zsh,fish,bash,inshellisense'

let carapace_completer = {|spans: list<string>|
    carapace $spans.0 nushell ...$spans | from json | sort-by value
}

$env.config.completions.external.enable = true
$env.config.completions.external.completer = $carapace_completer
