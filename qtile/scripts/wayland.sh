#!/usr/bin/env sh

#way-displays &
swww-daemon &
waypaper --restore &
wl-copy &
wl-paste --type text --watch cliphist store & # Saves text
wl-paste --type image --watch cliphist store & # Saves images
emacs --daemon &
mako &
/usr/libexec/polkit-mate-authentication-agent-1 &
dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP=wlroots
systemctl --user stop pipewire pipewire-media-session xdg-desktop-portal xdg-desktop-portal-wlr
systemctl --user start pipewire-media-session
