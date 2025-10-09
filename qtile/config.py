import os
import subprocess
import socket

from libqtile import bar, layout, qtile, widget, hook
from libqtile.config import Click, Drag, DropDown, Group, Key, Match, ScratchPad, Screen, KeyChord
from libqtile.lazy import lazy
from libqtile.backend.wayland.inputs import InputConfig
from qtile_extras.widget import StatusNotifier

from functions import (
    smart_swap,
    float_all_windows,
    tile_all_windows,
    toggle_floating_all,
    update_visible_groups,
    refresh_groups,
)

# --- Environment ---
hostname = socket.gethostname()

# --- Mod Keys ---
mod = "mod4"
mod1 = "control"

# --- Key Bindings ---
keys = [
    Key([mod], "Return", lazy.spawn("/home/edward/AppImages/wezterm.appimage"), desc="Launch terminal"),
    Key([mod], "space", lazy.spawn("rofi -show drun"), desc="Launch app launcher (rofi)"),
    Key([mod], "b", lazy.spawn("floorp"), desc="Launch web browser"),
    Key([mod], "n", lazy.spawn("thunar"), desc="Launch Thunar"),
    Key([mod], "h", lazy.spawn("wezterm -e yazi"), desc="Launch Yazi"),
    Key([mod], "y", lazy.spawn("/opt/floorp/floorp --profile '/home/array/.floorp/0d2b7do3.default-release' --start-ssb '{2069eacc-9e0e-48f1-b592-e07e40ec4ad6}'"), desc="Launch YouTube Music"),
    Key([mod], "m", lazy.spawn("wezterm -e /home/array/.cargo/bin/jellyfin-tui"), desc="Launch rmpc"),
    Key([mod], "d", lazy.spawn("legcord --ozone-platform=wayland"), desc="Launch Discord"),
    Key([mod], "l", lazy.spawn("emacsclient -c -a 'emacs'"), desc="Launch Doom Emacs"),
    Key([mod], "t", lazy.spawn("wezterm -e tmux"), desc="Launch tmux"),
    Key([mod], "p", lazy.spawn("flatpak run com.protonvpn.www"), desc="Launch ProtonVPN"),

    Key([mod], "S", lazy.spawn("bash -c '/home/$USER/.config/qtile/scripts/screenshot.sh'"), desc="Take full screenshot"),
    Key([mod, "shift"], "p", lazy.spawn("bash -c '/home/$USER/.config/qtile/scripts/power.sh'"), desc="Power Menu"),
    Key([mod], "p", lazy.spawn("bash -c '/home/$USER/.config/qtile/scripts/powerprofile.sh'"), desc="Power Menu"),
    Key([mod, "shift"], "c", lazy.spawn("bash -c '/home/$USER/.config/qtile/scripts/colorpicker.sh'"), desc="ColorPicker"),
    Key([mod], "k", lazy.spawn("bash -c /home/$USER/.config/qtile/scripts/clipboard.sh"), desc="Clipboard Manager"),

    # --- Qtile Specific ---
    Key([mod], "o", lazy.hide_show_bar(), desc="Hide the bar"),
    Key([mod], "q", lazy.window.kill(), desc="Kill focused window"),
    Key([mod, "shift"], "r", lazy.reload_config(), desc="Reload config"),
    Key([mod, "shift"], "f", lazy.window.toggle_fullscreen(), desc="Toggle fullscreen"),
    Key([mod], "Tab", lazy.function(smart_swap), desc="Smart swap with master"),
    Key([mod], "Down", lazy.layout.down(), desc="Focus down"),
    Key([mod], "Up", lazy.layout.up(), desc="Focus up"),
    Key([mod], "Left", lazy.layout.shrink(), desc="Shrink window"),
    Key([mod], "Right", lazy.layout.grow(), desc="Grow window"),
    Key([mod], "r", lazy.layout.reset(), desc="Reset layout"),
    Key([mod, "shift"], "Down", lazy.layout.shuffle_down(), desc="Move window down"),
    Key([mod, "shift"], "Up", lazy.layout.shuffle_up(), desc="Move window up"),
    Key([mod], "period", lazy.next_layout(), desc="Next layout"),
    Key([mod], "comma", lazy.prev_layout(), desc="Previous layout"),
    Key([mod, "shift"], "Space", toggle_floating_all(), desc="Toggle float/tile all"),
    Key([mod], "f", float_all_windows(), desc="Float all windows"),
    Key([mod, "shift"], "t", tile_all_windows(), desc="Tile all windows"),
    KeyChord([mod], "i", [Key([mod], "i", lazy.ungrab_all_chords())], name='VM Mode'),

    # --- Volume / Brightness ---
    Key([], "XF86AudioRaiseVolume", lazy.spawn("pactl set-sink-volume @DEFAULT_SINK@ +2%"), desc="Volume up"),
    Key([], "XF86AudioLowerVolume", lazy.spawn("pactl set-sink-volume @DEFAULT_SINK@ -2%"), desc="Volume down"),
    Key([], "XF86AudioMute", lazy.spawn("pactl set-sink-mute @DEFAULT_SINK@ toggle"), desc="Toggle mute"),
    Key([], "XF86MonBrightnessUp", lazy.spawn("brightnessctl set 150+%"), desc="Brightness up"),
    Key([], "XF86MonBrightnessDown", lazy.spawn("brightnessctl set 5-%"), desc="Brightness down"),
]

# --- Mouse Bindings ---
mouse = [
    Drag([mod], "Button1", lazy.window.set_position_floating(), start=lazy.window.get_position()),
    Drag([mod], "Button3", lazy.window.set_size_floating(), start=lazy.window.get_size()),
    Click([mod], "Button2", lazy.window.bring_to_front()),
]

# --- Groups ---
groups = [Group(str(i)) for i in range(1, 10)]

for i in groups:
    keys.extend([
        Key([mod], i.name, lazy.group[i.name].toscreen(), desc=f"Switch to group {i.name}"),
        Key([mod, "shift"], i.name, lazy.window.togroup(i.name, switch_group=False), desc=f"Move window to group {i.name}"),
    ])

# --- ScratchPad ---
groups.append(ScratchPad("scratchpad", [
    DropDown("term", "/home/edward/AppImages/wezterm.appimage", width=0.8, height=0.8, x=0.1, y=0.1, opacity=1.0),
]))

# --- ScratchPad Keybinds ---
keys.extend([
    Key([mod, "shift"], "Return", lazy.group["scratchpad"].dropdown_toggle("term")),
    Key([mod], "x", lazy.group["scratchpad"].hide_all()),
])

# --- Layouts ---
layout_conf = {
    "border_focus": "#91ACD1",
    "border_normal": "#13141C",
    "border_width": 2,
    "margin": 4,
}

layouts = [
    layout.MonadTall(**layout_conf),
    layout.MonadWide(**layout_conf),
    layout.MonadThreeCol(**layout_conf),
    layout.Bsp(**layout_conf),
    layout.RatioTile(**layout_conf),
    layout.Spiral(**layout_conf),
]

# --- Widgets & Bar ---
widget_defaults = dict(
    font="Ubuntu Nerd Font Bold",
    fontsize=14 ,
    padding=2,
    background="#13141C",
    foreground="#D2D4DE",
)
extension_defaults = widget_defaults.copy()

screens = [
    Screen(
        top=bar.Bar(
            [
                widget.Spacer(length=6),
                widget.GroupBox(
                    font="Ubuntu Nerd Font Bold",
                    fontsize=12,
                    padding_x=3,
                    padding_y=2,
                    margin_y=4,
                    disable_drag=True,
                    active="#D2D4DE",
                    inactive="#D2D4DE",
                    rounded=True,
                    highlight_method="line",
                    highlight_color="#13141C",
                    this_current_screen_border="#91ACD1",
                    this_screen_border="#91ACD1",
                    other_screen_border="#91ACD1",
                    other_current_screen_border="#91ACD1",
                    visible_groups=[g.name for g in groups if g.name in [str(i) for i in range(1, 6)]],
                ),
                widget.Spacer(),
                widget.Clock(format="%A %H:%M"),
                widget.Spacer(),
                StatusNotifier(icon_size=16, padding=6),
                widget.TextBox(text=' ︱ ', font="Ubuntu Mono", padding=2, fontsize=10),
                widget.TextBox(fmt="◨", font="JetBrainsMonoNF", fontsize=18),
                widget.CurrentLayout(fontsize=13),
                widget.TextBox(text=' ︱ ', font="Ubuntu Mono", padding=2, fontsize=10),
                widget.Battery(
                    format="{char} {percent:2.0%}",
                    low_percentage=0.2,
                    show_short_text=False,
                    notify_below=30,
                    update_interval=30,
                    charge_char=" 󰂄",
                    discharge_char=" 󰁿",
                    empty_char=" 󰂎",
                    not_charging_char=" 󰂊",
                ),
                widget.TextBox(text=' ︱ ', font="Ubuntu Mono", padding=2, fontsize=10),
                widget.Volume(fmt=" {}"),
                widget.TextBox(text=' ︱ ', font="Ubuntu Mono", padding=2, fontsize=10),
                widget.TextBox(
                    text='󰂯',
                    fontsize=17,
                    font='Ubuntu Nerd Font Bold',
                    mouse_callbacks={'Button1': lambda: qtile.cmd_spawn('wezterm -e bluetuith')}
                ),
                widget.Spacer(length=1),
                widget.TextBox(
                    text="󰖩",
                    font="Ubuntu Nerd Font Bold",
                    fontsize=15 ,
                    mouse_callbacks={'Button1': lambda: qtile.cmd_spawn('wezterm -e nmtui')}
                ),
                widget.Spacer(length=12),
            ],
            32,
            background="#161821",
            opacity=1.0,
            margin=[0, -2, 0, -2],
        ),
    ),
]

floating_layout = layout.Floating(
    border_width=2,
    border_focus="#91ACD1",
    border_normal="#91ACD1",
    float_rules=[
        *layout.Floating.default_float_rules,
        Match(wm_class="confirmreset"),
        Match(wm_class="makebranch"),
        Match(wm_class="maketag"),
        Match(wm_class="ssh-askpass"),
        Match(title="branchdialog"),
        Match(title="pinentry"),
        Match(wm_class="feh"),
        Match(wm_class="net-runelite-client-RuneLite"),
        Match(wm_class=".protonvpn-app-wrapped"),
        Match(wm_class="VirtViewer"),
    ],
)

# --- Wayland Input Configs ---
wl_input_rules = {
    "type:keyboard": InputConfig(kb_layout="gb" if hostname in ("fedora", "thinknix") else "us"),
    "type:touchpad": InputConfig(
        tap=True,
        natural_scroll=False,
        dwt=True,
        accel_profile="adaptive",
        pointer_accel=0.2,
    ),
}

# --- Autostart ---
@hook.subscribe.startup_once
def autostart():
    autostart_script = os.path.expanduser('~/.config/qtile/scripts/wayland.sh')
    if os.path.isfile(autostart_script):
        subprocess.Popen(['bash', autostart_script])

# --- Other Settings ---
dgroups_key_binder = None
dgroups_app_rules = []
follow_mouse_focus = True
bring_front_click = True
floats_kept_above = True
cursor_warp = False
auto_fullscreen = True
focus_on_window_activation = "smart"
reconfigure_screens = True
auto_minimize = True
wmname = "QTILE"
