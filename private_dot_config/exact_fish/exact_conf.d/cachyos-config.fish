## Set values
## Run fastfetch as welcome message

if type -q fastfetch
    function fish_greeting
        fastfetch
    end
end

# Format man pages
set -x MANROFFOPT -c

# Set settings for https://github.com/franciscolourenco/done
set -U __done_min_cmd_duration 10000
set -U __done_notification_urgency_level low

## Environment setup
# Apply .profile: use this to put fish compatible .profile stuff in
if test -f ~/.fish_profile
    source ~/.fish_profile
end

# Functions needed for !! and !$ https://github.com/oh-my-fish/plugin-bang-bang
function __history_previous_command
    switch (commandline -t)
        case "!"
            commandline -t $history[1]
            commandline -f repaint
        case "*"
            commandline -i !
    end
end

function __history_previous_command_arguments
    switch (commandline -t)
        case "!"
            commandline -t ""
            commandline -f history-token-search-backward
        case "*"
            commandline -i '$'
    end
end

if [ "$fish_key_bindings" = fish_vi_key_bindings ]
    bind -Minsert ! __history_previous_command
    bind -Minsert '$' __history_previous_command_arguments
else
    bind ! __history_previous_command
    bind '$' __history_previous_command_arguments
end

# Common use
abbr -a grubup sudo grub-mkconfig -o /boot/grub/grub.cfg
abbr -a fixpacman sudo rm /var/lib/pacman/db.lck
abbr -a tarnow tar -acf
abbr -a untar tar -zxvf
abbr -a wget wget -c
abbr -a psmem ps auxf | sort -nr -k 4
abbr -a psmem10 ps auxf | sort -nr -k 4 | head -10
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'
alias ......='cd ../../../../..'
abbr -a dir dir --color=auto
abbr -a vdir vdir --color=auto
abbr -a grep grep --color=auto
abbr -a fgrep fgrep --color=auto
abbr -a egrep egrep --color=auto
abbr -a hw hwinfo --short # Hardware Info
abbr -a big "expac -H M '%m\t%n' | sort -h | nl" # Sort installed packages according to size in MB
abbr -a gitpkg "pacman -Q | grep -i "\-git" | wc -l" # List amount of -git packages
abbr -a update "sudo cachyos-rate-mirrors && sudo pacman -Syu"

# Get fastest mirrors
#alias mirror="sudo cachyos-rate-mirrors"

if type -q pacman
    # Help people new to Arch
    alias apt='man pacman'
    alias apt-get='man pacman'
    alias tb='nc termbin.com 9999'

    # Cleanup orphaned packages
    alias cleanup='sudo pacman -Rns (pacman -Qtdq)'
end

# Get the error messages from journalctl
abbr -a jctl "journalctl -p 3 -xb"

# Recent installed packages
abbr -a rip "expac --timefmt='%Y-%m-%d %T' '%l\t%n %v' | sort | tail -200 | nl"
