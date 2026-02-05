function fishconfig --description "Edit fish config files in nvim and reload"
    set -l config_dir ~/.config/fish

    # Open nvim with working directory set to fish config dir
    nvim -c "cd $config_dir" $config_dir/config.fish $config_dir/conf.d/*

    # Source main config
    source $config_dir/config.fish

    # Source all conf.d files
    for file in $config_dir/conf.d/*.fish
        source $file
    end

    echo "Fish config reloaded."
end
