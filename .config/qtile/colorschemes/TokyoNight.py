from collections import namedtuple


_colourSet = namedtuple("colours",[
    "black",
    "red",
    "green",
    "yellow",
    "blue",
    "magenta",
    "cyan",
    "white"])
_darkColours = _colourSet(
        black   = "#12e127",
        red     = "#e06c75",
        green   = "#98c379",
        yellow  = "#d19a66",
        blue    = "#61afef",
        magenta = "#8f77e5",
        cyan    = "#56b6c2",
        white   = "#c5cddb"
        )
_brightColours = _colourSet(
        black   = "#5c6370",
        red     = "#e06c75",
        green   = "#98c379",
        yellow  = "#d19a66",
        blue    = "#5586a6",
        magenta = "#8f77e5",
        cyan    = "#4cd9eb",
        white   = "#ffffff",
        )
_primaryColourSet = namedtuple("colours", ["foreground", "background"])
_primaryColours = _primaryColourSet(background = "#1e2127", foreground = "#c5cddb")
_colourType = namedtuple("colourType", ["bright", "dark", "primary"])
colours = _colourType(_brightColours, _darkColours, _primaryColours)

icon_colour = colours.bright.cyan[1::]
groupbox_border_active = icon_colour
groupbox_border_inactive = colours.primary.foreground[1::]
bar_opacity = 0.80
bar_height = 21 
bar_font_color = colours.bright.white[1::]
border_inactive = colours.bright.black[1::]
border_active = colours.bright.blue[1::]
border_width = 2
border_marign = 5
font = "JetBrains Mono Nerd Font Bold"
font_icon_size = 17
font_size = 12
bar_widget_padding = 3

widget_defaults = dict(
            font=font,
            fontsize = font_size,
            padding=bar_widget_padding,
            update_interval = 2
            
        )
