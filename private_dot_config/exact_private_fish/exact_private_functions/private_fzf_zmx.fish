function fzf_zmx --description "Pick or create a zmx session using fzf"
    if not command -q fzf
        echo "fzf_zmx: fzf is required but not installed" >&2
        return 1
    end

    if not command -q zmx
        echo "fzf_zmx: zmx is required but not installed" >&2
        return 1
    end

    set -l display (zmx list 2>/dev/null | while read -l line
        set -l name (string match -r 'session_name=(\S+)' $line)[2]
        set -l pid (string match -r 'pid=(\S+)' $line)[2]
        set -l clients (string match -r 'clients=(\S+)' $line)[2]
        set -l dir (string match -r 'started_in=(\S+)' $line)[2]
        printf "%-20s pid:%-8s clients:%-2s %s\n" $name $pid $clients $dir
    end)

    set -l output (
        printf '%s\n' $display | fzf \
            --print-query \
            --expect=ctrl-n,ctrl-k \
            --height=80% \
            --layout=reverse \
            --border=rounded \
            --prompt='zmx › ' \
            --header='Enter: attach │ Ctrl-N: new │ Ctrl-K: kill' \
            --preview='zmx history {1}' \
            --preview-window='right:60%:follow'
    )
    set -l rc $status

    set -l query $output[1]
    set -l key $output[2]
    set -l selected $output[3]

    set -l session_name

    if test "$key" = ctrl-k -a -n "$selected"
        set session_name (string split --fields=1 ' ' -- $selected)
        commandline --replace "zmx kill $session_name"
        commandline --function execute
        return
    end

    if test "$key" = ctrl-n -a -n "$query"
        set session_name $query
    else if test $rc -eq 0 -a -n "$selected"
        set session_name (string split --fields=1 ' ' -- $selected)
    else if test -n "$query"
        set session_name $query
    else
        commandline --function repaint
        return 0
    end

    commandline --replace "zmx detach && zmx attach $session_name"
    commandline --function execute
end
