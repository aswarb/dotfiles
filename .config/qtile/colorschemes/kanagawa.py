from collections import namedtuple


_colourSet = namedtuple(
    "colours", ["black", "red", "green", "yellow", "blue", "magenta", "cyan", "white"]
)
_darkColours = _colourSet(
    black="#0d0c0c",
    blue="#8ba4b0",
    cyan="#8ea4a2",
    green="#8a9a7b",
    magenta="#a292a3",
    red="#c4746e",
    white="#C8C093",
    yellow="#c4b28a",
)
_brightColours = _colourSet(
    black="#a6a69c",
    blue="#7FB4CA",
    cyan="#7AA89F",
    green="#87a987",
    magenta="#938AA9",
    red="#E46876",
    white="#c5c9c5",
    yellow="#E6C384",
)
_primaryColourSet = namedtuple("colours", ["foreground", "background"])
_primaryColours = _primaryColourSet(background="#181616", foreground="#c5c9c5")
_colourType = namedtuple("colourType", ["bright", "dark", "primary"])
colours = _colourType(_brightColours, _darkColours, _primaryColours)
TRANSPARENT = "#00000000"

widget_background = colours.primary.background
icon_colour = colours.bright.yellow
groupbox_border_active = icon_colour
groupbox_border_inactive = colours.bright.black
bar_opacity = 0.90
bar_height = 24
bar_background = colours.primary.background
bar_font_color = '#ffffff'
border_inactive = colours.bright.black
border_active = colours.bright.white
border_width = 1
border_marign = 4
font = "JetBrains Mono Nerd Font Bold"
font_icon_size = 17
font_size = 12
bar_widget_padding = 3

widget_defaults = dict(
    font=font,
    fontsize=font_size,
    padding=bar_widget_padding,
    update_interval=2,
    foreground=colours.primary.foreground,
)
