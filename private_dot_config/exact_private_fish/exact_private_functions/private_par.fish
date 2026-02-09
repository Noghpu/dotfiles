function par -d "paru wrapper with package-manager-style subcommands"
    switch "$argv[1]"
        case install i
            paru -S $argv[2..]
        case remove r
            paru -Rns $argv[2..]
        case autoremove
            set -l orphans (paru -Qdtq)
            if test -z "$orphans"
                echo "No orphaned packages to remove."
            else
                echo "Orphaned packages:"
                printf '  %s\n' $orphans
                paru -Rns $orphans
            end
        case upgrade u
            paru -Syu $argv[2..]
        case search s
            paru -Ss $argv[2..]
        case info
            # local first, fall back to remote
            if paru -Qi $argv[2..] 2>/dev/null
                return
            end
            paru -Si $argv[2..]
        case which w
            paru -Qs $argv[2..]
        case list
            paru -Qe $argv[2..]
        case orphans
            paru -Qdtq
        case clean
            paru -Sc $argv[2..]
        case files
            paru -Ql $argv[2..]
        case owner
            paru -Qo $argv[2..]
        case ''
            echo "par — paru wrapper"
            echo ""
            echo "Usage: par <command> [args...]"
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
            echo "Unrecognized commands are passed through to paru."
            echo "Note: paru handles sudo internally — never run par with sudo."
        case '*'
            paru $argv
    end
end
