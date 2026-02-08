# fd (file finder) aliases

if (which fd | is-empty) { return }

alias f = fd
alias ff = fd --type f
alias fd-hidden = fd --hidden
