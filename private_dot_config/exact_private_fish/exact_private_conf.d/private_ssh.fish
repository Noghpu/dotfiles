# Keep any usable inherited or forwarded agent.
if set -q SSH_AUTH_SOCK; and test -S "$SSH_AUTH_SOCK"
    return
end

# Otherwise use the conventional socket from systemd's ssh-agent.socket unit.
if set -q XDG_RUNTIME_DIR
    set -l systemd_socket $XDG_RUNTIME_DIR/ssh-agent.socket
    if test -S "$systemd_socket"
        set -gx SSH_AUTH_SOCK $systemd_socket
        return
    end
end

set -e SSH_AUTH_SOCK
if status is-interactive
    echo 'No SSH agent socket is available.' >&2
    echo 'Enable the systemd user agent with:' >&2
    echo '  systemctl --user enable --now ssh-agent.socket' >&2
end
