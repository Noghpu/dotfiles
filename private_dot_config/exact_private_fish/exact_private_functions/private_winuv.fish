function winuv
    set -l wsl_path (pwd)
    set -l win_path (string replace '/home' 'G:\\home' $wsl_path | string replace --all '/' '\\')
    echo $win_path
    set -l uv_exe /mnt/c/Users/$USER/scoop/shims/uv.exe
    $uv_exe run --directory $win_path $argv
end
