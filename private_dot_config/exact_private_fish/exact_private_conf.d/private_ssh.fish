# ssh_agent.fish — Start ssh-agent once per session, auto-add default key.

# Reuse existing agent if it's alive
if test -n "$SSH_AUTH_SOCK"; and ssh-add -l >/dev/null 2>&1
    return
end

# Start a fresh agent
if status is-interactive
    set -gx SSH_AUTH_SOCK $XDG_RUNTIME_DIR/ssh-agent.sock
    if not test -S $SSH_AUTH_SOCK
        ssh-agent -c -a $SSH_AUTH_SOCK >/dev/null
    end
    # ssh-add ~/.ssh/id_ed25519 2>/dev/null
end

# Add default key if it exists
if test -f ~/.ssh/id_ed25519
    ssh-add ~/.ssh/id_ed25519 2>/dev/null
else
    echo "[ssh-agent] No ~/.ssh/id_ed25519 found — generate one with ssh-keygen -t ed25519"
end
