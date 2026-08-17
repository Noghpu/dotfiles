# Niri configuration rules

- Never modify or manage the CachyOS default configuration. Treat
  `~/.config/niri/config.kdl`, `~/.config/niri/cfg/**`, and CachyOS backup files
  as read-only. Put every customization or override in the chezmoi-managed
  `private_user.kdl`; override inherited bindings there instead of editing the
  default file.
- To unbind a CachyOS default, override the same key in `private_user.kdl` with
  a non-repeating no-op: `Key repeat=false { spawn; }`. An empty binding block
  is invalid, but zero-argument `spawn;` is accepted and returns without
  creating a process. Never remove the binding from the CachyOS file because
  updates can restore it.
- Do not add, remove, or update `hotkey-overlay-title` properties. The custom
  keybind overlay is the authoritative shortcut reference.
