status is-interactive; or return

if command -q lazygit
    # No CONFIG_DIR export: lazygit already resolves $XDG_CONFIG_HOME/lazygit on
    # its own, and CONFIG_DIR is a generic name that leaks into every child
    # process (other tools read it too). Use `lazygit -ucd` for a one-off dir.
    abbr lg lazygit
end
