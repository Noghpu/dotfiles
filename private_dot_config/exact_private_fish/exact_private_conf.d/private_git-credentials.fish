status is-interactive; or return

# GPG needs the current terminal when Git Credential Manager invokes it.
if type -q git-credential-manager
    set -gx GPG_TTY (tty)
end
