# chezmoi aliases

if (which chezmoi | is-empty) { return }

alias cm = chezmoi

def cmca [] {
    chezmoi re-add .
    chezmoi git add .
    chezmoi git commit -- -a -m 'update'
}
