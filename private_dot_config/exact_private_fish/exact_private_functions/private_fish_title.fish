function fish_title --description 'Show environment, directory, and active command in the window title' --argument-names last_command
    fish_tab_title "$last_command"
end
