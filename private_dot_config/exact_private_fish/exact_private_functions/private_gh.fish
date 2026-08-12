# Decrypts the token per call instead of exporting it, so GH_TOKEN exists only in
# the gh process for the duration of that one command — deliberately not the
# session-wide pattern in conf.d/secrets.fish. Entry git/github.com is shared with
# the credential helper from conf.d/git-credentials.fish: first line = token.
function gh -d "gh with a per-call GH_TOKEN from passage"
    # An inherited GH_TOKEN already takes precedence in gh, so leave it alone.
    if set -q GH_TOKEN; or not type -q passage
        command gh $argv
        return
    end

    set -l token (passage show git/github.com 2>/dev/null | head -n1)
    if test -z "$token"
        command gh $argv
        return
    end

    set -lx GH_TOKEN $token
    command gh $argv
end
