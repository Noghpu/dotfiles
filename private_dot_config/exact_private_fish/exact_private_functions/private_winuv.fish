function winuv
    set wsl_path (pwd)
    set win_path (string replace --regex '^/home' 'W:\\home' $wsl_path | string replace --all '/' '\\')
    set uv_exe /mnt/c/Users/$USER/scoop/shims/uv.exe
    $uv_exe run --directory $win_path $argv
end
