# gcm_gpg.fish — Conditional GCM + GPG credential store setup for headless servers.
# Drop into ~/.config/fish/conf.d/

# Gate on required binaries — hint at install commands for anything missing
for cmd in gpg pass git git-credential-manager
    if not command -q $cmd
        return
    end
end

# Gate on an existing GPG secret key
if not gpg --list-secret-keys --keyid-format long 2>/dev/null | string match -q '*sec*'
    echo "[gcm-gpg] Skipping setup — no GPG secret key found"
    echo "  → Generate one:                    gpg --full-generate-key"
    return
end

# Gate on an initialized password store
if not test -d ~/.password-store
    set -l key_id (gpg --list-secret-keys --keyid-format long 2>/dev/null \
            | string match -r '(?<=sec\s{3}rsa\d{4}/)([A-F0-9]+)' | head -1)
    echo "[gcm-gpg] Skipping setup — ~/.password-store not found"
    if test -n "$key_id"
        echo "  → Initialize with your key:        pass init $key_id"
    else
        echo "  → Initialize:                      pass init <YOUR_GPG_KEY_ID>"
    end
    return
end

# --- All prerequisites met — configure ---

# Ensure GPG agent doesn't try to open a GUI pinentry
set -gx GPG_TTY (tty)

# Point GCM at the gpg/pass store
if test (git config --global credential.credentialStore 2>/dev/null) != gpg/pass
    git config --global credential.credentialStore gpg/pass
end

# Register GCM as the credential helper if not already set
if not git config --global credential.helper 2>/dev/null | string match -q '*git-credential-manager*'
    git-credential-manager configure 2>/dev/null
end

__gcm_gpg_setup
