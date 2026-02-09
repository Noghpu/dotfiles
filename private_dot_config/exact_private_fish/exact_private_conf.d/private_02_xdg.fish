# XDG Base Directory Specification
# https://specifications.freedesktop.org/basedir-spec/basedir-spec-latest.html

# User directories
set -q XDG_CONFIG_HOME; or set -gx XDG_CONFIG_HOME ~/.config
set -q XDG_DATA_HOME; or set -gx XDG_DATA_HOME ~/.local/share
set -q XDG_CACHE_HOME; or set -gx XDG_CACHE_HOME ~/.cache
set -q XDG_STATE_HOME; or set -gx XDG_STATE_HOME ~/.local/state

# System directories
set -q XDG_DATA_DIRS; or set -gx XDG_DATA_DIRS /usr/local/share:/usr/share
set -q XDG_CONFIG_DIRS; or set -gx XDG_CONFIG_DIRS /etc/xdg
