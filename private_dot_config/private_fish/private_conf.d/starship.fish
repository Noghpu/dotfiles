if type -q starship
    set -gx STARSHIP_CONFIG "$XDG_CONFIG_HOME/starship/starship.toml"
    starship init fish | source
end
