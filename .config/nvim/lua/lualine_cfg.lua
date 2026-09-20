-- Palette mirrored from kanagawa_cfg.lua, which is the source of truth. lualine
-- needs plain values rather than highlight groups, so these are duplicated
-- rather than derived; if a token changes there, change it here too.
local G_SECONDARY = "#cdc6bc"
local G_TERTIARY  = "#a8a299"
local G_MUTED     = "#7a746a"
local FRUIT_PEACH = "#edc99a"
local FRUIT_CORAL = "#e07860"
local FRUIT_WARN  = "#d49050"
local FRUIT_EMBER = "#de7c47"
local DRAGON_TEAL = "#949fb5"
-- FRUIT_CHERRY is deliberately not mirrored here: it is the error colour, and
-- no mode borrows it.

-- The bar sits one step *above* the buffer rather than below it. kanagawa's
-- default was #0d0c0c, darker than the terminal background, which read as a
-- black slab under a transparent editor; fully transparent removed the edge
-- entirely. These are the same surfaces the theme sets on StatusLine.
local BAR = "#22242b" -- one surface for the whole bar, matching StatusLine

-- `theme = 'auto'` resolved to kanagawa's own lualine theme, which is built
-- from kanagawa's palette rather than this one -- insert mode was #98BB6C, a
-- green, and normal mode was #8ba4b0. Modes now run on the fruit tokens, in
-- rough order of how much care the mode demands: calm cream for normal, the
-- cool note for insert, amber for visual, cherry for replace.
-- Modes are assigned by what each token already means, in rough order of how
-- much care the mode demands. Cherry is deliberately absent: it is reserved for
-- errors, and a mode indicator that borrows the error colour is a bad idea.
--
--   coral    insert    -- the active state
--   teal     visual    -- selection is non-destructive, so it takes the cool note
--   ember    replace   -- the harshest token left, for the destructive mode
--   peach    command
--   warn     terminal
--   cream    normal    -- resting
--
-- Visual and replace were both warm oranges and read as the same mode at a
-- glance. Putting visual on the blue separates them on hue rather than on a
-- shade, and matches the fact that one is safe and the other overwrites.
--
-- The token itself carries the block, at full strength -- the point of choosing
-- by meaning is that the colour reads as coral or warn or ember. The text on it
-- is the bar surface rather than black, so the block looks cut out of the bar
-- instead of pairing the brightest thing on screen with the darkest.
local function mode(token)
    return {
        a = { bg = token, fg = BAR, gui = "bold" },
        b = { bg = BAR,   fg = G_SECONDARY },
        c = { bg = BAR,   fg = G_MUTED },
    }
end

local cynosure = {
    -- Normal is the state you are in most of the time, so its block sits low on
    -- the ramp rather than on the secondary cream. It still needs to be a block:
    -- the tabline uses this same slot to mark the active buffer, so matching it
    -- to the bar would make the tabs indistinguishable.
    normal   = mode(G_TERTIARY),
    insert   = mode(FRUIT_CORAL),
    visual   = mode(DRAGON_TEAL),
    replace  = mode(FRUIT_EMBER),
    command  = mode(FRUIT_PEACH),
    terminal = mode(FRUIT_WARN),
    inactive = {
        a = { bg = BAR, fg = G_MUTED },
        b = { bg = BAR, fg = G_MUTED },
        c = { bg = BAR, fg = G_MUTED },
    },
}

return require('lualine').setup {
    options = {
	icons_enabled = true,
	theme = cynosure,

    },

    sections = {
	lualine_a = {'mode'},
	lualine_b = {'branch', 'diff', 'diagnostics'},
	lualine_c = {'filename'},
	lualine_x = {'encoding', 'fileformat', 'filetype'},
	lualine_y = {'progress'},
	lualine_z = {'location'}
    },

    -- Open buffers along the top. The number shown is the buffer number, so
    -- :b3 jumps straight to it.
    tabline = {
	lualine_a = {{ 'buffers', mode = 2, show_filename_only = true }},
	lualine_z = {{ 'tabs', mode = 0 }},
    }
}
