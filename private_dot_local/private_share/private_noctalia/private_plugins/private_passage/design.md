# Passage agent — deferred design

**Status: not implemented.** `passage-fill` and this plugin assume an
unencrypted age identity at `~/.passage/identities`, so nothing ever prompts.
This note records how a passphrase would be added later, and the constraints
that shape it, so the decision does not have to be re-derived.

## When this would be worth doing

An encrypted identity defends against **offline** theft: a stolen laptop, a
leaked backup, a disk image. It does nothing against a live compromised
session — once unlocked, anything running as the user can use the agent. age's
own manual makes the point:

> passphrase-protected identity files are not necessary for most use cases,
> where access to the encrypted identity file implies access to the whole
> system.

If the disk is already encrypted at rest, be specific about what the second
lock adds before building this.

## Hard constraint: age prompts on /dev/tty only

age does support passphrase-protected identity files:

```
$ age -d -i id.age msg.age
Enter passphrase for identity file "id.age":
hello
```

It has no askpass hook, no pinentry support, and no environment override.
Without a terminal it fails outright:

```
age: error: could not read passphrase: standard input is not a terminal,
     and /dev/tty is not available: open /dev/tty: no such device or address
```

**A Noctalia panel therefore cannot prompt for the passphrase.** This is the
same reason the community `pass` plugin falls back to `runInTerminal` when GPG
needs an unlock.

## Second constraint: the passphrase must not cross the Luau boundary

At `plugin_api = 9`, `noctalia.runAsync` takes a command *string*; the
argv-table form requires API 24, newer than this machine's build. A passphrase
passed that way would land in `/proc/<pid>/cmdline`, and spawned commands get
no stdin. So the passphrase must never pass through the plugin.

## Design

Unlock is a terminal act. Filling stays a GUI act.

```
Mod+P  ->  panel, locked
           entry list still renders (paths come from filenames)
           preview and fill disabled
           Enter -> noctalia.runInTerminal("passage-agent unlock")
                    kitty opens, age prompts on a real tty, window closes
Mod+P  ->  panel, unlocked: preview and fill work
           ... timeout -> locked again
```

`passage-agent`, a systemd user service:

- decrypts `~/.passage/identities` once and holds the plaintext identity in
  memory, never on disk
- serves it over a unix socket in `$XDG_RUNTIME_DIR` (tmpfs, 0700, gone at
  logout)
- absolute lifetime from unlock, like `ssh-add -t`; 15 minutes is a sane
  default. Idle-reset is the alternative flavour: friendlier, but a busy
  afternoon then never re-prompts
- locks on `noctalia msg session lock`, already bound to `Mod+X`
- must give age a pty to prompt into — spawn it under a pty and let it read
  from the controlling terminal. Roughly 15 lines, and the fiddliest part of
  this design

Changes to the implemented pieces, both small:

- `passage-fill` resolves the identity through the agent instead of reading
  `~/.passage/identities`, and exits with a distinct "locked" status when the
  agent is not running
- the panel gains a locked state keyed off that status

## ssh key passphrases

A separate mechanism, and unlike age, ssh *does* have the hook:

- `SSH_ASKPASS=passage-askpass` with `SSH_ASKPASS_REQUIRE=force` (OpenSSH >= 8.4;
  10.5 on this machine) makes ssh exec a helper and read the passphrase from
  its stdout
- better still: at unlock, the agent runs `ssh-add` using a passphrase stored
  in passage, so ssh never prompts again that session
- `~/.ssh/config` already sets `AddKeysToAgent yes`, and `ssh-agent.socket` is
  active

The cost is that the age passphrase becomes a single master credential, and the
ssh key passphrase stops being an independent factor.

## Alternative: hardware identity

`age-plugin-fido2-hmac` or `age-plugin-yubikey` replace the passphrase with a
touch. If the credential is touch-only, with no PIN, there is no prompt to
route anywhere: the tty constraint disappears instead of being worked around.

## Ordering note

`git-credential-passage` needs the store unlocked, and `chezmoi update` pulls
the private store repo over https using that helper. Unlock has to come before
update.
