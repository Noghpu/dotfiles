status is-interactive; or return

if type -q zmx
    abbr --add mx zmx
    if test -n "$ZMX_SESSION"
        abbr --add detach zmx detach
    end
end
