# Turn on the local HTTP(S) proxy (cntlm/squid on 127.0.0.1:3128).
# Snapshots the originals so px_off can restore them.
function px_on --description 'Set http/https proxy to 127.0.0.1:3128'
    # Snapshot the originals once so px_off can restore them.
    if not set -q __proxy_saved
        set -g __proxy_saved 1
        set -g __proxy_old_http $http_proxy
        set -g __proxy_old_https $https_proxy
        set -g __proxy_old_no $no_proxy
    end

    set -gx http_proxy http://127.0.0.1:3128
    set -gx https_proxy http://127.0.0.1:3128
    set -gx HTTP_PROXY http://127.0.0.1:3128
    set -gx HTTPS_PROXY http://127.0.0.1:3128

    # Append localhost entries to no_proxy without clobbering what's already there.
    for host in localhost 127.0.0.1 ::1
        if not string match -q "*$host*" -- "$no_proxy"
            if test -n "$no_proxy"
                set -gx no_proxy "$no_proxy,$host"
            else
                set -gx no_proxy "$host"
            end
        end
    end
    set -gx NO_PROXY "$no_proxy"
    echo "proxy on -> 127.0.0.1:3128"
end
