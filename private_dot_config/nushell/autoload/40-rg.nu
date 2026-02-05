# ripgrep aliases

if (which rg | is-empty) { return }

alias rgi = rg -i
alias rgf = rg --files-with-matches
alias rgh = rg --hidden
