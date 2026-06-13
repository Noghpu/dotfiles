# Restore proxy vars to their pre-px_on state (see px_on, proxy_wipe).
function px_off --description 'Restore proxy vars to their pre-px_on state'
    if not set -q __proxy_saved
        echo "px_off: nothing to restore (px_on was not run)"
        return
    end

    # Restore each var: set it back if it had a value, otherwise erase it.
    if test -n "$__proxy_old_http"
        set -gx http_proxy $__proxy_old_http
        set -gx HTTP_PROXY $__proxy_old_http
    else
        set -e http_proxy HTTP_PROXY
    end
    if test -n "$__proxy_old_https"
        set -gx https_proxy $__proxy_old_https
        set -gx HTTPS_PROXY $__proxy_old_https
    else
        set -e https_proxy HTTPS_PROXY
    end
    if test -n "$__proxy_old_no"
        set -gx no_proxy $__proxy_old_no
        set -gx NO_PROXY $__proxy_old_no
    else
        set -e no_proxy NO_PROXY
    end

    set -e __proxy_saved __proxy_old_http __proxy_old_https __proxy_old_no
    echo "proxy off (restored previous values)"
end
