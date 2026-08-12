function __prompt_context --description 'Print a stable label for the current execution environment'
    if set -q __prompt_context_label
        printf '%s' "$__prompt_context_label"
        return
    end

    set -l host (prompt_hostname)

    if set -q SSH_CONNECTION; or set -q SSH_CLIENT; or set -q SSH_TTY
        set -g __prompt_context_label "ssh:$host"
    else if set -q WSL_DISTRO_NAME
        set -g __prompt_context_label "wsl:$WSL_DISTRO_NAME"
    else if string match -qi '*microsoft*' -- (uname -r)
        set -g __prompt_context_label wsl
    else
        set -l container_type
        if command -sq systemd-detect-virt
            set container_type (systemd-detect-virt --container 2>/dev/null)
            test "$container_type" = none; and set container_type
        end
        if test -z "$container_type"; and test -e /.dockerenv
            set container_type docker
        else if test -z "$container_type"; and test -e /run/.containerenv
            set container_type container
        end

        if test -n "$container_type"
            set -g __prompt_context_label "$container_type:$host"
        else
            set -g __prompt_context_label $host
        end
    end

    printf '%s' "$__prompt_context_label"
end

function __prompt_context_symbol --description 'Print a symbol for the current execution environment'
    set -l context (__prompt_context)
    switch $context
        case 'ssh:*'
            printf '󰢹'
        case 'wsl' 'wsl:*'
            printf ''
        case 'docker:*'
            printf ''
        case '*:*'
            printf '⬢'
        case '*'
            printf '󰌢'
    end
end
