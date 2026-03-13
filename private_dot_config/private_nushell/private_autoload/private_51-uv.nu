# uv (Python package manager) aliases

if (which uv | is-empty) { return }

alias uvr = uv run

if (which nvim | is-not-empty) {
    def uvim [...args] { uv run nvim ...$args }
}
