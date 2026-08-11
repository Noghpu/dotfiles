# Implementation lives in __aur_wrapper (shared with par → paru).
# Named yy because y is the yazi function and ya is yazi's own package CLI.
function yy -d "yay wrapper with package-manager-style subcommands"
    __aur_wrapper yy yay $argv
end
