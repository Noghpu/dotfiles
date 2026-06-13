# ssh_agent.fish — Start ssh-agent once per session, auto-add default key.

# Reuse existing agent if it's alive
if test -n "$SSH_AUTH_SOCK"; and ssh-add -l >/dev/null 2>&1
    return
end

# ssh_agent.fish — reuse one agent per user; never spawn duplicates.
# Only manage an agent for interactive shells (skip `fish -c`, scripts, scp).
if status is-interactive
    # Is an agent already reachable? (e.g. forwarded via ForwardAgent, or inherited)
    ssh-add -l >/dev/null 2>&1
    set -l agent_status $status
    if test $agent_status -eq 2
        # No usable agent in the environment → use a stable per-user socket.
        if set -q XDG_RUNTIME_DIR
            set -gx SSH_AUTH_SOCK $XDG_RUNTIME_DIR/ssh-agent.sock
        else
            set -gx SSH_AUTH_SOCK /tmp/ssh-agent-(id -u).sock
        end
        # (Re)start only if nothing is listening on that socket.
        ssh-add -l >/dev/null 2>&1
        if test $status -eq 2
            rm -f $SSH_AUTH_SOCK
            ssh-agent -a $SSH_AUTH_SOCK >/dev/null 2>&1
        end
        # Load default key once, if present.
        if test -f ~/.ssh/id_ed25519
            ssh-add ~/.ssh/id_ed25519 2>/dev/null
        end
    end
end

# Add default key if it exists
if test -f ~/.ssh/id_ed25519
    ssh-add ~/.ssh/id_ed25519 2>/dev/null
else
    echo "[ssh-agent] No ~/.ssh/id_ed25519 found — generate one with ssh-keygen -t ed25519"
end
