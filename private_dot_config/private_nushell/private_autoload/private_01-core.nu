# Core aliases and commands (no external dependencies)

# Navigation aliases
alias .. = cd ..
alias ... = cd ../..
alias .... = cd ../../..
alias ..... = cd ../../../..
alias ...... = cd ../../../../..

# Listing aliases (nushell's ls returns structured data)
alias la = ls -a
alias ll = ls -l
alias lla = ls -la

# Dotfiles only (nushell-native filtering)
def "l." [...args] { ls -a ...$args | where name =~ '^\.' }

# Create directory and cd into it
def --env mkcd [dir: string] {
    mkdir $dir
    cd $dir
}

# Display PATH entries as a table
def showpath [] { $env.PATH }
