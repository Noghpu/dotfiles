# Force-clear all proxy variables and the px_on snapshot (no restore).
function proxy_wipe --description 'Force-clear all proxy variables and saved snapshot'
    set -e http_proxy https_proxy HTTP_PROXY HTTPS_PROXY no_proxy NO_PROXY
    set -e __proxy_saved __proxy_old_http __proxy_old_https __proxy_old_no
    echo "proxy wiped"
end
