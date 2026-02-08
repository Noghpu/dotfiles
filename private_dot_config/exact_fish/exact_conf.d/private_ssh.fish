# ssh_agent.fish — Start ssh-agent once per session, auto-add default key.

# Reuse existing agent if it's alive
if test -n "$SSH_AUTH_SOCK"; and ssh-add -l >/dev/null 2>&1
    return
end

# Start a fresh agent
eval (ssh-agent -c) >/dev/null

# Add default key if it exists
if test -f ~/.ssh/id_ed25519
    ssh-add ~/.ssh/id_ed25519 2>/dev/null
else
    echo "[ssh-agent] No ~/.ssh/id_ed25519 found — generate one with ssh-keygen -t ed25519"
end
