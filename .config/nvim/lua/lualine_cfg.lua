-- Palette mirrored from cynored_cfg.lua, which is the source of truth. lualine
-- needs plain values rather than highlight groups, so these are duplicated
-- rather than derived; if a token changes there, change it here too.
local INK_DATA    = "#f0ebe5"
local INK_BODY    = "#cdc6bc"
local INK_MACHINE = "#a8a299"
local INK_FRAME   = "#7a746a"
local DECL        = "#edc99a"
local VERMILION   = "#D9534A" -- the desktop accent
local WARN        = "#d49050"
local EMBER       = "#F28C46" -- lifted, matching the editor's numeric literals
local BUILTIN     = "#949fb5"
-- The error colour. No *mode* borrows it -- a mode indicator wearing
-- the error colour is a bad idea -- but the diagnostics chip on the right is
-- an actual error count, so it is the one place it belongs.
local ERROR = "#d96060"

-- The bar sits one step *above* the buffer rather than below it. kanagawa's
-- default was #0d0c0c, darker than the terminal background, which read as a
-- black slab under a transparent editor; fully transparent removed the edge
-- entirely. These are the same surfaces the theme sets on StatusLine.
--
-- Warm, now that the terminal paints #131111 under the editor. The previous
-- #22242b was a cool blue-grey inherited from kanagawa.
local BAR      = "#1A1716" -- the status bar plane
local FILL     = "#2E2725" -- the open tab's fill; visibly a box

-- `theme = 'auto'` resolved to kanagawa's own lualine theme, built from
-- kanagawa's palette rather than this one -- insert mode came out green.
--
-- Modes take the token that already means the thing, in rough order of how
-- much care the mode demands. ERROR is deliberately absent: a mode indicator
-- wearing the error colour is a bad idea.
--
--   VERMILION     normal     -- the accent, per the panel at :55
--   VERMILION     insert
--   BUILTIN       visual     -- selecting is non-destructive, so it takes the
--                               one cool note
--   EMBER         replace    -- the harshest token left, for the mode that
--                               overwrites
--   DECL          command
--   WARN          terminal
--
-- Normal was on INK_MACHINE grey, on cynosure's logic that the resting state
-- should sit low on the ramp. The design does not do that: the mode block is
-- the accent, and it is the only red on the bar.
--
-- Visual and replace were both warm oranges and read as the same mode at a
-- glance. Putting visual on the blue separates them by hue rather than by a
-- shade, matching the fact that one is safe and the other overwrites.
--
-- Both bars mark the active thing with a solid fill, not a rule:
--
--   statusline mode   token fill, surface-colour text   (Crucible.dc.html:55)
--   tabline file      charcoal fill, cream text         (:43)
--
-- Underlines were tried and abandoned. neovim does emit the colour as SGR 58,
-- but tmux only forwards it when the terminal entry advertises `Setulc`, and
-- neither the alacritty nor the tmux-256color terminfo does -- so the rule
-- arrived stripped and rendered in the text colour. Fills always work.
local SURFACE = "#131111" -- the buffer surface; the mode block knocks out to it

local function mode(token)
    return {
        a = { bg = token, fg = SURFACE, gui = "bold" },
        b = { bg = BAR,   fg = INK_BODY },
        c = { bg = BAR,   fg = INK_FRAME },
    }
end

local MODE_TOKEN = {
    normal   = VERMILION,
    insert   = VERMILION,
    visual   = BUILTIN,
    replace  = EMBER,
    command  = DECL,
    terminal = WARN,
}

local cynosure = {
    normal   = mode(MODE_TOKEN.normal),
    insert   = mode(MODE_TOKEN.insert),
    visual   = mode(MODE_TOKEN.visual),
    replace  = mode(MODE_TOKEN.replace),
    command  = mode(MODE_TOKEN.command),
    terminal = mode(MODE_TOKEN.terminal),
    -- Idle sections sit in ink with no fill, so the only marked thing on the
    -- bar is the mode block.
    inactive = {
        a = { bg = BAR, fg = INK_FRAME },
        b = { bg = BAR, fg = INK_FRAME },
        c = { bg = BAR, fg = INK_FRAME },
    },
}

-- Plain text on the bar: no fill, no block. Only the mode is a block.
local plain = { fg = INK_FRAME,   bg = BAR }
local bright = { fg = INK_DATA, bg = BAR }

return require('lualine').setup {
    options = {
	icons_enabled = true,
	theme = cynosure,
	-- The design's bar is one continuous plane with a single block on it,
	-- so nothing is chevroned or angled between sections.
	section_separators = '',
	component_separators = '',
    },

    -- Left: mode block, branch and diff, filename.
    -- Right: diagnostics as filled chips, filetype, position.
    sections = {
	lualine_a = {'mode'},
	lualine_b = {
	    { 'branch', color = plain },
	    { 'diff',   color = plain },
	},
	lualine_c = {{ 'filename', color = bright }},
	lualine_x = {{
	    'diagnostics',
	    -- Counts sit in chips, as the panel draws them: error rose, warning
	    -- amber, each knocked out to the surface.
	    diagnostics_color = {
		error = { fg = SURFACE, bg = ERROR, gui = 'bold' },
		warn  = { fg = SURFACE, bg = WARN,   gui = 'bold' },
		info  = { fg = INK_BODY, bg = BAR },
		hint  = { fg = INK_FRAME,     bg = BAR },
	    },
	}},
	lualine_y = {{ 'filetype', color = plain, icon_only = false }},
	lualine_z = {{ 'location', color = bright }},
    },

    -- Open buffers along the top. The number shown is the buffer number, so
    -- :b3 jumps straight to it.
    tabline = {
	lualine_a = {{
	    'buffers', mode = 2, show_filename_only = true,
	    -- The open file is a solid fill, not an underline: a charcoal box
	    -- with cream text on it. Closed files are bare ink on the surface.
	    buffers_color = {
		active   = { fg = INK_DATA,  bg = FILL,   gui = 'bold' },
		inactive = { fg = INK_FRAME, bg = 'NONE' },
	    },
	}},
    }
}
