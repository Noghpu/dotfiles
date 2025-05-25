function pac --description 'Pacman wrapper with simplified syntax'
    switch $argv[1]
        case install
            sudo pacman -S $argv[2..-1]
        case update
            sudo pacman -Syu
        case remove
            sudo pacman -R $argv[2..-1]
        case purge
            sudo pacman -Rns $argv[2..-1]
        case search
            pacman -Ss $argv[2..-1]
        case info
            pacman -Si $argv[2..-1]
        case list
            pacman -Qqe $argv[2..-1]
        case clean
            sudo pacman -Sc
        case orphans
            pacman -Qtdq
        case help
            echo "Usage: pac [command] [options]"
            echo "Commands:"
            echo "  install   - Install packages (pacman -S)"
            echo "  update    - Update system (pacman -Syu)"
            echo "  remove    - Remove packages (pacman -R)"
            echo "  purge     - Remove packages and configs (pacman -Rns)"
            echo "  search    - Search for packages (pacman -Ss)"
            echo "  info      - Show package info (pacman -Si)"
            echo "  list      - List installed packages (pacman -Qqe)"
            echo "  clean     - Clean package cache (pacman -Sc)"
            echo "  orphans   - List orphaned packages (pacman -Qtdq)"
        case '*'
            echo "Unknown command: $argv[1]"
            pac help
    end
end
