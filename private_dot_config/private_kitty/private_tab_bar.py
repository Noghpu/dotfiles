"""Tab titles for kitty, driven by {custom} in tab_title_template.

fish_tab_title already hands kitty a well formed title:

    <context> · <prompt_pwd> [· <last command>]

so nothing here re-derives the path; fish's own prompt_pwd shortening is
reused as is. This only drops the context label when it is just the local
hostname (it stays for ssh:/docker:/wsl: contexts), adds the tab index and
elides from the left so the tail - the part that identifies the tab - always
survives.
"""

import socket

SEP = ' · '
ELLIPSIS = '…'

_local_host = None


def local_host() -> str:
    global _local_host
    if _local_host is None:
        _local_host = socket.gethostname().split('.')[0].lower()
    return _local_host


def strip_local_context(title: str) -> str:
    parts = title.split(SEP)
    if len(parts) > 1 and parts[0].lower() == local_host():
        return SEP.join(parts[1:])
    return title


def elide(text: str, limit: int) -> str:
    """Trim from the left; the tail identifies the tab, the head repeats."""
    if limit <= 0 or len(text) <= limit:
        return text
    kept = text[-(limit - 1):]
    # Never leave a dangling separator fragment behind the ellipsis.
    stripped = kept.lstrip(SEP.strip() + ' ')
    if stripped and len(kept) - len(stripped) < len(SEP) + 1:
        kept = stripped
    return ELLIPSIS + kept


def draw_title(data) -> str:
    prefix = f" {data['sup'].index} "
    progress = data['tab'].last_focused_progress_percent
    budget = data['max_title_length'] - len(prefix) - len(progress) - 1
    label = elide(strip_local_context(data['title']), budget)
    return f'{prefix}{label} {progress}'.rstrip() + ' '
