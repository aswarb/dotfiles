-- crucible · palette
--
-- The vocabulary; colors/crucible.lua is the grammar.
--
-- Surfaces, the ink ramp, the accent and the status colours come from
-- Crucible.dc.html. The code hues do not -- they are chosen here, for
-- separation at small sizes, under the direction doc's constraints: warm
-- darks, one accent, no neon, legible at arm's length. Red is fixed.

local M = {}

M.surface = {
	wall = "#1A1A1F", -- wallpaper base
	bg = "#131111", -- surface
	raised = "#1A1716", -- raised · popover
	sel = "#241C1B", -- selection · cursorline
	rule = "#2C2826", -- rule · inactive border
	-- A split between two live panes is structure you navigate by, so it is
	-- one rung up from the inactive-border rule and actually visible.
	rule2 = "#3B3531",
}

M.ink = {
	-- Bone, not white. A pure bright fg sits on top of the surface; a warm
	-- off-white belongs to it.
	[1] = "#DCD3C6",
	[2] = "#A0968A",
	[3] = "#6A6157",
}

M.accent = {
	base = "#D9534A", -- vermilion. Locked.
	hover = "#F08A6C",
}

-- Code hues.
--
-- Greyed, but not below the ink. The previous set was muted so far that the
-- bone foreground was the most assertive thing on screen and every hue read
-- as tinted grey -- a whole file of oatmeal with a red accent floating on it.
--
-- The family is still lacquer: black, bone, vermilion, matcha, murasaki, ai
-- indigo. What changed is that the pigment is actually on the brush. Each
-- hue now carries clearly more colour than the bone it sits beside, which is
-- the thing kanagawa gets right -- its greens and blues are muted against
-- *white*, but they are still unmistakably green and blue against its own
-- foreground.
--
--   matcha    #9BBF74   strings
--   murasaki  #C49ADE   numbers, booleans, constants
--   ai        #7E9CD8   calls
--   kincha    #C4B180   types you declared
M.code = {
	string = "#9BBF74", -- matcha
	number = "#C49ADE", -- murasaki
	call = "#7E9CD8", -- ai indigo
	type = "#9A9078", -- sumi, builtin annotations
}

M.call_builtin = "#A0968A"
M.type_user = "#C4B180" -- kincha

-- Comments are a greyed clay, warmer than the ink ramp so prose reads as
-- prose rather than as dimmed code.
M.comment = "#7A6F64"

M.status = {
	ok = "#8CB896",
	warn = "#D8B26A",
	error = "#E8456A",
}

-- The rest of the ANSI ramp, for :terminal and for groups that need a hue
-- the code palette does not provide.
M.ansi = {
	blue = "#8FA3B8",
	magenta = "#CF8F9F",
	cyan = "#96BDB2",
	br_black = "#554E4A",
	br_red = "#F08A6C",
	br_green = "#B4D3B0",
	br_yellow = "#ECC890",
	br_blue = "#B2C0D0",
	br_magenta = "#D6A8BA",
	br_cyan = "#B0CFC4",
}

--- Composite `fg` over `bg` at `alpha` (0-1).
--- The doc expresses tints as 8-digit hex (accent + "38"); neovim has no
--- alpha channel, so those are flattened against the surface here.
---@param fg string  "#RRGGBB"
---@param bg string  "#RRGGBB"
---@param alpha number
---@return string
function M.blend(fg, bg, alpha)
	local function split(c)
		return tonumber(c:sub(2, 3), 16), tonumber(c:sub(4, 5), 16), tonumber(c:sub(6, 7), 16)
	end
	local fr, fg_, fb = split(fg)
	local br, bg_, bb = split(bg)
	local function mix(a, b)
		return math.floor(a * alpha + b * (1 - alpha) + 0.5)
	end
	return string.format("#%02X%02X%02X", mix(fr, br), mix(fg_, bg_), mix(fb, bb))
end

-- Tints, flattened against the surface. The doc's alpha suffixes:
--   accent + "38" = 22%   accent + "1c" = 11%
--   error  + "22" = 13%   warn   + "1a" = 10%
M.tint = {
	accent_22 = M.blend(M.accent.base, M.surface.bg, 0x38 / 255),
	-- Not from the doc. A visual selection you are actively dragging needs
	-- to be unmistakable, and 22% sits too close to the surface.
	accent_35 = M.blend(M.accent.base, M.surface.bg, 0.35),
	accent_11 = M.blend(M.accent.base, M.surface.bg, 0x1C / 255),
	error_13 = M.blend(M.status.error, M.surface.bg, 0x22 / 255),
	warn_10 = M.blend(M.status.warn, M.surface.bg, 0x1A / 255),
	ok_13 = M.blend(M.status.ok, M.surface.bg, 0x22 / 255),
}

return M
