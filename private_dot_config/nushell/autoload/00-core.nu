# Core aliases and commands (no external dependencies)

# Navigation aliases
alias la = ls -a
alias ll = ls -l
alias lla = ls -la
alias .. = cd ..
alias ... = cd ../..
alias .... = cd ../../..
alias ..... = cd ../../../..
alias ...... = cd ../../../../..

# Create directory and cd into it
def mkcd [dir: string] {
    mkdir $dir
    cd $dir
}

# Display PATH entries one per line
def showpath [] {
    $env.PATH | each { |p| print $p }
}
