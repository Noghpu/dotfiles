# Reliably bypass any corporate HTTP proxy inherited from Windows for loopback
# and the generic private network. WSL inherits no_proxy/http_proxy from the
# Windows environment, but the WinINET "<local>" token and glob forms are not
# honored by curl / most HTTP libraries, so we prepend explicit entries here.
# The proxy listens on :8080 (same port as the local searxng container); without
# this, requests to localhost:8080 are routed to the proxy and rejected as
# self-referential. 192.168.0.0/16 is direct-routable on any LAN and over the
# full-tunnel VPN, so it never needs the egress proxy. This is generic and safe
# everywhere, so it stays in synced config. Company-only ranges/domains live in
# the unsynced user_config.fish, which config.fish sources after conf.d and which
# appends to whatever we set here. Idempotent: skips if localhost already present.
# Handles both case variants of the inherited variable.
for var in no_proxy NO_PROXY
    set -l current $$var
    if not string match -qi "*localhost*" -- "$current"
        set -l prefix localhost,127.0.0.1,::1,192.168.0.0/16
        if test -n "$current"
            set -gx $var "$prefix,$current"
        else
            set -gx $var "$prefix"
        end
    end
end
