export alias .. = cd ..
export alias ... = cd ../..
export alias .... = cd ../../..
export alias ..... = cd ../../../..
export alias ...... = cd ../../../../..

export def showpath [] {
    $env.PATH
    | enumerate
    | rename index path
}

export def --env mkcd [path: path] {
    mkdir $path
    cd $path
}

export def tarnow [...args: string] {
    ^tar -acf ...$args
}

export def untar [...args: string] {
    ^tar -zxvf ...$args
}

export def wget [...args: string] {
    ^wget -c ...$args
}

export def psmem [] {
    ps | sort-by -r mem
}

export def psmem10 [] {
    ps | sort-by -r mem | first 10
}
