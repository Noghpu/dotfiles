# Managed by chezmoi (source: private_secrets.fish).
# Loads secrets from the passage store into the environment at shell startup.
# Contains NO secret values — only `passage show` references — so it is safe to
# commit. No-ops unless `passage` is installed AND a local age identity exists at
# ~/.passage/identities. A key this machine cannot decrypt yields an empty var.
#
# To add a key:  ! passage insert api/<name>   then  passage git push
# and uncomment / add a line below.
if type -q passage; and test -r ~/.passage/identities
    # set -gx OPENAI_API_KEY (passage show api/openai 2>/dev/null)
    # set -gx ANTHROPIC_API_KEY (passage show api/anthropic 2>/dev/null)
end
