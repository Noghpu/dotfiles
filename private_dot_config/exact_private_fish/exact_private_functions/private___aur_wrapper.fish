# Shared implementation behind the AUR-helper wrappers:
#   par → paru   (functions/par.fish)
#   yy  → yay    (functions/yy.fish)
#
# paru and yay take identical pacman-style flags, so the only things that differ
# are the binary invoked and the name printed in the help text. Keeping one
# implementation here stops the two wrappers from drifting apart.
#
#   $argv[1]   = wrapper name shown in help  (par / yy)
#   $argv[2]   = AUR helper binary to invoke (paru / yay)
#   $argv[3..] = the user's own arguments

function __aur_wrapper -a name helper
    set -l rest $argv[3..]

    if not command -q $helper
        echo "$name: $helper is not installed" >&2
        return 127
    end

    switch "$rest[1]"
        case install i
            $helper -S $rest[2..]
        case remove r
            $helper -Rns $rest[2..]
        case autoremove
            set -l orphans ($helper -Qdtq)
            if test -z "$orphans"
                echo "No orphaned packages to remove."
            else
                echo "Orphaned packages:"
                printf '  %s\n' $orphans
                $helper -Rns $orphans
            end
        case upgrade u
            $helper -Syu $rest[2..]
        case search s
            $helper -Ss $rest[2..]
        case info
            # local first, fall back to remote
            if $helper -Qi $rest[2..] 2>/dev/null
                return
            end
            $helper -Si $rest[2..]
        case which w
            $helper -Qs $rest[2..]
        case list
            $helper -Qe $rest[2..]
        case orphans
            $helper -Qdtq
        case clean
            $helper -Sc $rest[2..]
        case files
            $helper -Ql $rest[2..]
        case owner
            $helper -Qo $rest[2..]
        case ''
            echo "$name — $helper wrapper"
            echo ""
            echo "Usage: $name <command> [args...]"
            echo ""
            echo "  install, i    Install packages              (-S)"
            echo "  remove, r     Remove packages + deps        (-Rns)"
            echo "  autoremove    Remove orphaned packages       (-Rns orphans)"
            echo "  upgrade, u    Full system upgrade            (-Syu)"
            echo "  search, s     Search repos/AUR               (-Ss)"
            echo "  info          Package info (local → remote)  (-Qi/-Si)"
            echo "  which, w      Search installed packages       (-Qs)"
            echo "  list          List installed (explicit)       (-Qe)"
            echo "  orphans       List orphaned packages          (-Qdtq)"
            echo "  clean         Clear package cache             (-Sc)"
            echo "  files         List files owned by pkg         (-Ql)"
            echo "  owner         Find which pkg owns file        (-Qo)"
            echo ""
            echo "Unrecognized commands are passed through to $helper."
            echo "Note: $helper handles sudo internally — never run $name with sudo."
        case '*'
            $helper $rest
    end
end
