# Check if ssh-agent is running, start if not
if not pgrep -u $USER ssh-agent >/dev/null
    eval (ssh-agent -c) >/dev/null
end

# Set SSH_AUTH_SOCK if not already set
if test -z "$SSH_AUTH_SOCK"
    set -gx SSH_AUTH_SOCK (ls -t /tmp/ssh-*/agent.* 2>/dev/null | head -1)
end

# Add key if not already added
if not ssh-add -l >/dev/null 2>&1
    if not test -g ~/.ssh/id_ed25519
        echo 'No default ssh private key found to add to agent. Generate one with ssh-keygen.'
    end
    ssh-add ~/.ssh/id_ed25519 2>/dev/null
end
