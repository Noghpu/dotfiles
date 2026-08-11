# API keys from passage. Each `passage show` is a separate age decryption, so
# this file is careful about when it runs at all:
#
#   * Non-interactive shells (scripts, `fish -c`, editor/tool subshells) get
#     nothing decrypted. They inherit the exported vars from their parent when
#     one exists, which is the normal case.
#   * Nested interactive shells skip the work too — exported variables are
#     already in the environment, so re-decrypting would be pure overhead.
#
# Net effect: at most one decryption per key per login session instead of three
# on every single shell start.

status is-interactive; or return
type -q passage; and test -r ~/.passage/identities; or return

for pair in EXA_API_KEY:api/exa JINA_API_KEY:api/jina PARALLEL_API_KEY:api/parallel
    set -l var (string split -f1 : -- $pair)
    set -l entry (string split -f2 : -- $pair)

    # Already inherited (or set by hand)? Leave it alone.
    set -q $var; and continue

    set -l secret (passage show $entry 2>/dev/null | head -n1)
    test -n "$secret"; and set -gx $var $secret
end
