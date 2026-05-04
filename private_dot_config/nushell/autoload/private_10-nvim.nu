# Neovim integration

if (which nvim | is-empty) { return }

# Editor aliases
alias v = nvim
alias vi = nvim
alias vim = nvim

# Fuzzy find and open file in neovim (requires fd + fzf)
if (which fd | is-not-empty) and (which fzf | is-not-empty) {
    def vf [] {
        let file = (fd --type f --hidden --exclude .git | fzf --layout=reverse --height=40% | str trim)
        if ($file | is-not-empty) {
            nvim $file
        }
    }
}

# Search content with ripgrep and open in neovim at line (requires rg + fzf)
if (which rg | is-not-empty) and (which fzf | is-not-empty) {
    def rgv [pattern: string] {
        let result = (rg --line-number $pattern | fzf --layout=reverse --height=40% | str trim)
        if ($result | is-not-empty) {
            let parts = ($result | split row ':')
            let file = ($parts | get 0)
            let line = ($parts | get 1)
            nvim $"+($line)" $file
        }
    }
}
