# Implementation lives in __aur_wrapper (shared with yy → yay).
function par -d "paru wrapper with package-manager-style subcommands"
    __aur_wrapper par paru $argv
end
