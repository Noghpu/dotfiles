# gcm_gpg.fish — Conditional GCM + GPG credential store setup for headless servers.
# Skip everything if not explicitly enabled
not set -q GCM_GPG; and return

# Gate on required binaries — report all missing at once
set -l missing
for cmd in gpg pass git git-credential-manager
    command -q $cmd; or set -a missing $cmd
end
if test (count $missing) -gt 0
    echo "[gcm-gpg] Skipping — missing: $missing"
    return
end

# Gate on an existing GPG secret key (machine-parseable output, works for any key type)
set -l key_id (gpg --list-secret-keys --with-colons --keyid-format long 2>/dev/null \
    | string match -r '^fpr:::::::::([A-F0-9]+):' --groups-only)[1]

if test -z "$key_id"
    echo "[gcm-gpg] Skipping — no GPG secret key found"
    echo "  → gpg --full-generate-key"
    return
end

# Gate on an initialized password store
if not test -d ~/.password-store
    echo "[gcm-gpg] Skipping — ~/.password-store not found"
    echo "  → pass init $key_id"
    return
end

# --- All prerequisites met ---

set -gx GPG_TTY (tty)

if not git config --global credential.credentialStore 2>/dev/null | string match -q gpg
    git config --global credential.credentialStore gpg
end

if not git config --global credential.helper 2>/dev/null | string match -q '*git-credential-manager*'
    git-credential-manager configure 2>/dev/null
end
