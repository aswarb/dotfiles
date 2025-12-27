#Copyright (c) 2010 Aldo Cortesi
# Copyright (c) 2010, 2014 dequis
# Copyright (c) 2012 Randall Ma
# Copyright (c) 2012-2014 Tycho Andersen
# Copyright (c) 2012 Craig Barnes
# Copyright (c) 2013 horsik
# Copyright (c) 2013 Tao Sauvage
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

from libqtile.layout.floating import Floating
import colorschemes.kanagawa as colorscheme

import subprocess
import os
from libqtile import bar, layout, widget, hook, qtile
from libqtile.config import Click, Drag, Group, Key, Match, Screen
from libqtile.lazy import lazy
from libqtile.utils import guess_terminal

from custom.widgets.ip_addr import IpAddr

DATETIME_FORMAT = "%Y-%m-%d %H:%M:%S"
DISTRO_NAME = "Arch"
SPAWN_HINT = "Press &lt;M-r&gt; to spawn"
CONFIG_LABEL = "default config"
CONFIG_NAME = "default"
NET_INTERFACE = "wlan0"


mod = "mod4"
terminal = guess_terminal()

rofi_cmd = 'rofi -show combi -combi-modes "drun,window" -modes combi'
rofimoji_cmd = 'rofimoji'

def rofimoji_search():
    qtile.cmd_spawan(rofi_cmd)


def rofi_search():
    qtile.cmd_spawn(rofi_cmd)


nvidia_settings_cmd = "nvidia-settings"


def spawn_nvidia_settings():
    qtile.cmd_spawn(nvidia_settings_cmd)


dunst_show_next = "dunstctl history-pop"
dunst_hide_all = "dunstctl close-all"
dunst_clear_all = "dunstctl history-clear"


def show_next_notif():
    qtile.cmd_spawn(dunst_show_next)


def hide_all_notif():
    qtile.cmd_spawn(dunst_hide_all)


def clear_all_notif():
    hide_all_notif()
    qtile.cmd_spawn(dunst_clear_all)


keys = [
    # A list of available commands that can be bound to keys can be found
    # at https://docs.qtile.org/en/latest/manual/config/lazy.html
    # Switch between windows
    Key([mod], "h", lazy.layout.left(), desc="Move focus to left"),
    Key([mod], "l", lazy.layout.right(), desc="Move focus to right"),
    Key([mod], "j", lazy.layout.down(), desc="Move focus down"),
    Key([mod], "k", lazy.layout.up(), desc="Move focus up"),
    Key([mod], "space", lazy.layout.next(), desc="Move window focus to other window"),
    # Move windows between left/right columns or move up/down in current stack.
    # Moving out of range in Columns layout will create new column.
    Key(
        [mod, "shift"], "h", lazy.layout.shuffle_left(), desc="Move window to the left"
    ),
    Key(
        [mod, "shift"],
        "l",
        lazy.layout.shuffle_right(),
        desc="Move window to the right",
    ),
    Key([mod, "shift"], "j", lazy.layout.shuffle_down(), desc="Move window down"),
    Key([mod, "shift"], "k", lazy.layout.shuffle_up(), desc="Move window up"),
    # Grow windows. If current window is on the edge of screen and direction
    # will be to screen edge - window would shrink.
    Key([mod, "control"], "h", lazy.layout.grow_left(), desc="Grow window to the left"),
    Key(
        [mod, "control"], "l", lazy.layout.grow_right(), desc="Grow window to the right"
    ),
    Key([mod, "control"], "j", lazy.layout.grow_down(), desc="Grow window down"),
    Key([mod, "control"], "k", lazy.layout.grow_up(), desc="Grow window up"),
    Key([mod], "n", lazy.layout.normalize(), desc="Reset all window sizes"),
    # Toggle between split and unsplit sides of stack.
    # Split = all windows displayed
    # Unsplit = 1 window displayed, like Max layout, but still with
    # multiple stack panes
    Key(
        [mod, "shift"],
        "Return",
        lazy.layout.toggle_split(),
        desc="Toggle between split and unsplit sides of stack",
    ),
    Key([mod], "Return", lazy.spawn(terminal), desc="Launch terminal"),
    # Toggle betweenr different layouts as defined below
    Key([mod], "Tab", lazy.next_layout(), desc="Toggle between layouts"),
    Key([mod], "w", lazy.window.kill(), desc="Kill focused window"),
    Key([mod, "control"], "r", lazy.reload_config(), desc="Reload the config"),
    Key([mod, "control"], "q", lazy.shutdown(), desc="Shutdown Qtile"),
    # Custom keybinds
    Key([mod], "r", lazy.spawncmd(), desc="Spawn a command using a prompt widget"),
    Key([mod], "f", lazy.window.toggle_floating(), desc="Toggle window floating mode"),
    Key([mod], "a", lazy.spawn(rofi_cmd), desc="Toggle window floating mode"),
    Key([mod], "e", lazy.spawn(rofimoji_cmd), desc="Toggle window floating mode"),
    Key(
        [mod, "shift"], "p", lazy.spawn("spectacle"), desc="Toggle window floating mode"
    ),
    # Volume keybinds
    Key(
        [],
        "XF86AudioLowerVolume",
        lazy.spawn("pamixer -d 2"),
        desc="Raise Volume by 2%",
    ),
    Key(
        [],
        "XF86AudioRaiseVolume",
        lazy.spawn("pamixer -i 2"),
        desc="Lower Volume by 2%",
    ),
    Key([], "XF86AudioMute", lazy.spawn("pamixer -t"), desc="Toggle Mute"),
]

groups = [Group(i) for i in "123456"]

for i in groups:
    keys.extend(
        [
            # mod1 + letter of group = switch to group
            Key(
                [mod],
                i.name,
                lazy.group[i.name].toscreen(),
                desc="Switch to group {}".format(i.name),
            ),
            # mod1 + shift + letter of group = switch to & move focused window to group
            Key(
                [mod, "shift"],
                i.name,
                lazy.window.togroup(i.name, switch_group=True),
                desc="Switch to & move focused window to group {}".format(i.name),
            ),
            # Or, use below if you prefer not to switch to that group.
            # # mod1 + shift + letter of group = move focused window to group
            # Key([mod, "shift"], i.name, lazy.window.togroup(i.name),
            #     desc="move focused window to group {}".format(i.name)),
        ]
    )

layouts = [
    layout.Columns(
        border_focus=colorscheme.border_active,
        border_normal=colorscheme.border_inactive,
        border_on_single=True,
        border_width=colorscheme.border_width,
        margin=colorscheme.border_marign,
    ),
    layout.Max(),
    # Try more layouts by unleashing below layouts.
    # layout.Stack(num_stacks=2),
    # layout.Bsp(),
    # layout.Matrix(),
    # layout.MonadTall(),
    # layout.MonadWide(),
    # layout.RatioTile(),
    # layout.Tile(border_focus=colorscheme.border_active,
    #            border_normal="#"+colorscheme.border_inactive,
    #            border_on_single=True,
    #            border_width=colorscheme.border_width,
    #            margin=colorscheme.border_marign),
    # layout.TreeTab(),
    # layout.VerticalTile(),
    # layout.Zoomy(),
]

widget_defaults = colorscheme.widget_defaults
extension_defaults = widget_defaults.copy()
right_bottom_bar = bar.Bar(
    [
        widget.TextBox(
            text="󰍛",
            foreground=colorscheme.icon_colour,
            fontsize=colorscheme.font_icon_size,
        ),
        widget.Memory(format="{MemUsed: .0f}{mm}", update_interval=2),
        widget.TextBox(text="|"),
        widget.TextBox(
            text="󰻠",
            foreground=colorscheme.icon_colour,
            fontsize=colorscheme.font_icon_size,
        ),
        widget.CPU(format="{freq_current}GHz {load_percent}%", update_interval=2),
        widget.ThermalSensor(tag_sensor="Tctl", update_interval=2),
        widget.TextBox(text="|"),
        widget.TextBox(text="󰢮", foreground=colorscheme.icon_colour, fontsize=20),
        widget.NvidiaSensors(
            format="{temp}°C {fan_speed} {perf}",
            update_interval=2,
            mouse_callbacks={"Button1": spawn_nvidia_settings},
        ),
        widget.Spacer(),
        widget.Prompt(),
        widget.Spacer(),
        widget.CheckUpdates(
            distro=DISTRO_NAME + "_checkupdates",
            update_interval=600,
            color_have_updates=colorscheme.colours.primary.foreground,
            color_no_updates=colorscheme.colours.primary.foreground,
            foreground=colorscheme.colours.primary.foreground,
            display_format="{updates} Updates",
        ),
        widget.TextBox(text="|"),
        widget.TextBox(
            text="󰑩",
            foreground=colorscheme.icon_colour,
            fontsize=colorscheme.font_icon_size,
        ),
        IpAddr(interface=NET_INTERFACE),
        widget.Wlan(
            format="@ {essid} {percent:1.0%}",
            update_interval=2,
            interface=NET_INTERFACE,
        ),
        widget.Net(
            format="{down:6.2f}{down_suffix}   {up:6.2f}{up_suffix}",
            update_interval=2,
            interface=NET_INTERFACE,
        ),
    ],
    colorscheme.bar_height,
    opacity=colorscheme.bar_opacity,
    background=colorscheme.bar_background,
)
right_top_bar = bar.Bar(
    [
        widget.CurrentLayout(),
        widget.TextBox(text="|"),
        widget.GroupBox(
            highlight_method="line",
            highlight_color=[
                colorscheme.colours.primary.background,
                colorscheme.colours.primary.background,
            ],
            foreground=colorscheme.colours.primary.foreground,
            this_current_screen_border=colorscheme.groupbox_border_active,
            this_screen_border=colorscheme.groupbox_border_active,
            other_current_screen_border=colorscheme.groupbox_border_inactive,
            other_screen_border=colorscheme.groupbox_border_inactive,
            active=colorscheme.colours.primary.foreground,
            inactive="#505050",
            disable_drag=True,
        ),
        widget.TextBox(text="|"),
        widget.TextBox(text="  Apps ", mouse_callbacks={"Button1": rofi_search}),
        widget.Spacer(),
        widget.WindowName(
            scroll=True,
            scroll_repeat=True,
            scroll_step=1,
            width=800,
            format="{name}",
        ),
        widget.Spacer(),
        widget.Systray(background = colorscheme.colours.primary.background),
        widget.TextBox(text="|"),
        widget.TextBox(text=" 󰥔", foreground=colorscheme.icon_colour, fontize=25),
        widget.Clock(format=DATETIME_FORMAT, update_interval=1),
        widget.TextBox(text="|"),
        widget.QuickExit(
            default_text=" ",
            foreground=colorscheme.icon_colour,
            fontsize=14,
            countdown_start=30,
            countdown_format=" {}",
        ),
    ],
    colorscheme.bar_height,
    opacity=colorscheme.bar_opacity,
    background=colorscheme.bar_background,
)

left_bottom_bar = bar.Bar(
    [
        widget.TextBox(
            text="󰍛",
            foreground=colorscheme.icon_colour,
            fontsize=colorscheme.font_icon_size,
        ),
        widget.Memory(format="{MemUsed: .0f}{mm}", update_interval=2),
        widget.TextBox(text="|"),
        widget.TextBox(
            text="󰻠",
            foreground=colorscheme.icon_colour,
            fontsize=colorscheme.font_icon_size,
        ),
        widget.CPU(format="{freq_current}GHz {load_percent}%", update_interval=2),
        widget.ThermalSensor(tag_sensor="Tctl", update_interval=2),
        widget.TextBox(text="|"),
        widget.TextBox(text="󰢮", foreground=colorscheme.icon_colour, fontsize=20),
        widget.NvidiaSensors(
            format="{temp}°C {fan_speed} {perf}",
            update_interval=2,
            mouse_callbacks={"Button1": spawn_nvidia_settings},
        ),
        widget.Spacer(),
        widget.Prompt(),
        widget.Spacer(),
        widget.TextBox(
            text="󰑩",
            foreground=colorscheme.icon_colour,
            fontsize=colorscheme.font_icon_size,
        ),
        IpAddr(interface=NET_INTERFACE),
        widget.Wlan(
            format="@ {essid} {percent:1.0%}",
            update_interval=2,
            interface=NET_INTERFACE,
        ),
        widget.Net(
            format="{down:6.2f}{down_suffix}   {up:6.2f}{up_suffix}",
            update_interval=2,
            interface=NET_INTERFACE,
        ),
    ],
    colorscheme.bar_height,
    opacity=colorscheme.bar_opacity,
    background=colorscheme.bar_background,
)
left_top_bar = bar.Bar(
    [
        widget.CurrentLayout(),
        widget.TextBox(text="|"),
        widget.GroupBox(
            highlight_method="line",
            highlight_color=[
                colorscheme.colours.primary.background,
                colorscheme.colours.primary.background,
            ],
            foreground=colorscheme.colours.primary.foreground,
            this_current_screen_border=colorscheme.groupbox_border_active,
            this_screen_border=colorscheme.groupbox_border_active,
            other_current_screen_border=colorscheme.groupbox_border_inactive,
            other_screen_border=colorscheme.groupbox_border_inactive,
            active=colorscheme.colours.primary.foreground,
            inactive="#505050",
            disable_drag=True,
        ),
        widget.TextBox(text="|"),
        widget.TextBox(text="  Apps ", mouse_callbacks={"Button1": rofi_search}),
        widget.Spacer(),
        widget.WindowName(
            scroll=True,
            scroll_repeat=True,
            scroll_step=1,
            width=800,
            format="{name}",
        ),
        widget.Spacer(),
        # widget.Systray(),
        widget.TextBox(text="|"),
        widget.TextBox(text="󰥔", foreground=colorscheme.icon_colour, fontize=25),
        widget.Clock(
            format=DATETIME_FORMAT,
            update_interval=1,
        ),
        widget.TextBox(text="|"),
        widget.QuickExit(
            default_text=" ",
            fontsize=14,
            foreground=colorscheme.icon_colour,
            countdown_start=30,
            countdown_format=" {}",
        ),
    ],
    colorscheme.bar_height,
    opacity=colorscheme.bar_opacity,
    background=colorscheme.bar_background,
)

screens = [
    Screen(top=left_top_bar, bottom=right_bottom_bar),
    Screen(top=right_top_bar, bottom=left_bottom_bar),
]
# Drag floating layouts.
mouse = [
    Drag(
        [mod],
        "Button1",
        lazy.window.set_position_floating(),
        start=lazy.window.get_position(),
    ),
    Drag(
        [mod], "Button3", lazy.window.set_size_floating(), start=lazy.window.get_size()
    ),
    Click([mod], "Button2", lazy.window.bring_to_front()),
    ]

dgroups_key_binder = None
dgroups_app_rules = []  # type: list
follow_mouse_focus = True
bring_front_click = False
cursor_warp = False
floating_layout = layout.Floating(
    float_rules=[
        # Run the utility of `xprop` to see the wm class and name of an X client.
        *layout.Floating.default_float_rules,
        Match(wm_class="confirmreset"),  # gitk
        Match(wm_class="spectacle"),  # Spectacle
        Match(wm_class="makebranch"),  # gitk
        Match(wm_class="maketag"),  # gitk
        Match(wm_class="ssh-askpass"),  # ssh-askpass
        Match(title="branchdialog"),  # gitk
        Match(title="pinentry"),  # GPG key password entry
    ],
    border_normal=colorscheme.colours.primary.background,
    border_focus=colorscheme.colours.bright.green,
)
auto_fullscreen = True
focus_on_window_activation = "smart"
reconfigure_screens = True

# If things like steam games want to auto-minimize themselves when losing
# focus, should we respect this or not?
auto_minimize = True

# When using the Wayland backend, this can be used to configure input devices.
wl_input_rules = None

# XXX: Gasp! We're lying here. In fact, nobody really uses or cares about this
# string besides java UI toolkits; you can see several discussions on the
# mailing lists, GitHub issues, and other WM documentation that suggest setting
# this string if your java app doesn't work correctly. We may as well just lie
# and say that we're a working one by default.
#
# We choose LG3D to maximize irony: it is a 3D non-reparenting WM written in
# java that happens to be on java's whitelist.
wmname = "Qtile"


@hook.subscribe.startup_once
def autostart():
    subprocess.Popen([os.path.expanduser("~/.config/qtile/autostart.sh")])


@hook.subscribe.startup
def apply_bar_properties():
    right_top_bar.window.window.set_property("QTILE_BAR", 1, "CARDINAL", 32)
    right_bottom_bar.window.window.set_property("QTILE_BAR", 1, "CARDINAL", 32)
    left_bottom_bar.window.window.set_property("QTILE_BAR", 1, "CARDINAL", 32)
    left_top_bar.window.window.set_property("QTILE_BAR", 1, "CARDINAL", 32)
