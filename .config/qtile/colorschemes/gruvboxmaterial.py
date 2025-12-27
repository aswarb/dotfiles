from collections import namedtuple


_colourSet = namedtuple(
    "colours", ["black", "red", "green", "yellow", "blue", "magenta", "cyan", "white"]
)
_darkColours = _colourSet(
    black="#4a4543",
    red="#ea6962",
    green="#89b482",
    yellow="#d8a657",
    blue="#7daea3",
    magenta="#d3869b",
    cyan="#89b482",
    white="#d4be98",
)
_brightColours = _colourSet(
    black="#4a4543",
    red="#ea6962",
    green="#89b482",
    yellow="#d8a657",
    blue="#7daea3",
    magenta="#d3869b",
    cyan="#89b482",
    white="#d4be98",
)
_primaryColourSet = namedtuple("colours", ["foreground", "background"])
_primaryColours = _primaryColourSet(background="#222324", foreground="#eddec4")
_colourType = namedtuple("colourType", ["bright", "dark", "primary"])
colours = _colourType(_brightColours, _darkColours, _primaryColours)
TRANSPARENT = "#00000000"

widget_background = colours.primary.background
icon_colour = colours.bright.green
groupbox_border_active = icon_colour
groupbox_border_inactive = colours.primary.background
bar_opacity = 1.00
bar_height = 24
bar_background = TRANSPARENT
bar_font_color = colours.bright.white
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
