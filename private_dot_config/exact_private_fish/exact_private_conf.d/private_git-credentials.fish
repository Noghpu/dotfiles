# git-credentials.fish — single source of truth for git credential storage.
# Preference order:  passage (age-backed) > git-credential-manager > nothing.
# Replaces the former passage.fish and git-credential-manager.fish.

if type -q passage
    # === passage: the default credential manager when installed ==============
    # Set up everything required: helper on PATH + passage as the global helper.

    set -l bindir $HOME/.local/bin
    test -d $bindir; or mkdir -p $bindir
    contains $bindir $PATH; or fish_add_path -g $bindir

    # Idempotently (re)generate the read-only credential helper.
    # Canonical body lives here; single-quote-free so it embeds without escaping.
    set -l helper $bindir/git-credential-passage
    set -l body '#!/usr/bin/env bash
# git-credential-passage — minimal read-only Git credential helper backed by passage.
# Resolves the entry "git/<host>": first line = password/token,
# optional "login: <user>" line = username.
# Managed by fish conf.d/git-credentials.fish — edit there (the canonical copy), not here.
set -euo pipefail

[ "${1:-}" = "get" ] || exit 0   # only handle \'get\'; ignore store/erase

declare -A req
while IFS="=" read -r key value; do
    [ -n "${key:-}" ] && req["$key"]="$value"
done

host="${req[host]:-}"
[ -n "$host" ] || exit 0

secret="$(passage show "git/$host" 2>/dev/null)" || exit 0
[ -n "$secret" ] || exit 0

password="$(printf "%s\n" "$secret" | head -n1)"
login="$(printf "%s\n" "$secret" | sed -n "s/^login: //p" | head -n1)"

[ -n "$password" ] && printf "password=%s\n" "$password"
[ -n "$login" ]    && printf "username=%s\n" "$login"
exit 0'

    if not test -f $helper; or test (cat $helper | string collect) != "$body"
        printf '%s\n' $body >$helper
        chmod +x $helper
    end
    test -x $helper; or chmod +x $helper

    # Make passage the global git credential helper (idempotent; drops any prior helper).
    # --unset-all clears only the top-level credential.helper; host-scoped keys like
    # credential.'https://my-host.com'.helper live in a subsection and are left intact.
    if test (git config --global --get-all credential.helper 2>/dev/null | string collect) != passage
        git config --global --unset-all credential.helper 2>/dev/null
        git config --global credential.helper passage
    end

else if type -q git-credential-manager
    # === fallback: git-credential-manager with a GPG-backed store ============
    # Works headless (no secretservice). Skips gracefully if prerequisites missing.

    if not command -q gpg
        echo "[git-credentials] GCM found but gpg missing — skipping"
        return
    end

    set -l key_id (gpg --list-secret-keys --with-colons --keyid-format long 2>/dev/null \
        | string match -r '^fpr:::::::::([A-F0-9]+):' --groups-only)[1]
    if test -z "$key_id"
        echo "[git-credentials] GCM: no GPG secret key found"
        echo "  → gpg --full-generate-key"
        return
    end
    if not test -d ~/.password-store
        echo "[git-credentials] GCM: ~/.password-store not found"
        echo "  → pass init $key_id"
        return
    end

    set -gx GPG_TTY (tty)
    if not git config --global credential.credentialStore 2>/dev/null | string match -q gpg
        git config --global credential.credentialStore gpg
    end
    if not git config --global credential.helper 2>/dev/null | string match -q '*git-credential-manager*'
        git-credential-manager configure 2>/dev/null
    end
end

# else: neither installed — do nothing.
