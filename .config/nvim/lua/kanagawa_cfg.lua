-- Perigee Kanagawa Config: Cool Teal Palette
local G_PRIMARY = "#dceef0" -- main text / variables / function defs (bright)
local G_SECONDARY = "#aabec2" -- parameters / members / properties (body text)
local G_TERTIARY = "#6a9aaa" -- regular function/method calls (lighter teal)
local G_MUTED = "#5a6a70" -- punctuation / types / less important UI
local G_COMMENT = "#2e3038" -- comments / borders / floats

local P_RED = "#e04848" -- operators / control flow / errors
local P_ORANGE = "#b87830" -- primitives / magic numbers / warnings
local P_GREEN = "#38b868" -- builtin functions (int, len, print etc.)
local P_STRING = "#6ab0a8" -- strings
local P_BRIGHT = "#dceef0" -- function declarations / brackets

require("kanagawa").setup({
	compile = true,
	undercurl = true,
	commentStyle = { italic = true },
	functionStyle = { italic = false, bold = false },
	keywordStyle = { italic = true },
	statementStyle = { italic = true },
	typeStyle = { italic = false },
	transparent = true,
	dimInactive = true,
	terminalColors = true,
	colors = {
		palette = {},
		theme = {
			wave = {},
			lotus = {},
			dragon = {},
			all = {
				ui = {
					fg = G_PRIMARY,
				},
			},
		},
	},
	overrides = function(colors)
		local theme = colors.theme
		return {
			-- ===== Types =====
			["@type"] = { fg = G_MUTED },
			["@type.builtin"] = { fg = G_MUTED },
			Type = { fg = G_MUTED },

			-- ===== Variables =====
			["@variable"] = { fg = G_PRIMARY },
			["@variable.builtin"] = { fg = G_SECONDARY },
			["@variable.typescript"] = { fg = G_PRIMARY },
			["@variable.parameter"] = { fg = G_SECONDARY },
			["@variable.member"] = { fg = G_SECONDARY },
			["@variable.property"] = { fg = G_SECONDARY },
			["@property"] = { fg = G_SECONDARY },
			["@field"] = { fg = G_SECONDARY },
			Identifier = { fg = G_PRIMARY },
			["@lsp.type.variable"] = { fg = G_PRIMARY },
			["@lsp.type.parameter"] = { fg = G_SECONDARY },
			["@lsp.type.property"] = { fg = G_SECONDARY },
			["@lsp.type.class"] = { fg = G_MUTED },

			-- ===== Functions =====
			["@function"] = { fg = P_BRIGHT },
			["@function.call"] = { fg = G_TERTIARY },
			["@function.method"] = { fg = G_TERTIARY },
			["@function.method.call"] = { fg = G_TERTIARY },
			["@function.builtin"] = { fg = P_GREEN }, -- int, len, print etc.
			Function = { fg = P_BRIGHT },
			["@lsp.typemod.function.declaration"] = { fg = P_BRIGHT }, -- function definitions
			["@lsp.typemod.method.declaration"] = { fg = P_BRIGHT },

			-- ===== Keywords / control flow =====
			["@keyword"] = { fg = G_MUTED, italic = true },
			["@keyword.conditional"] = { fg = P_RED, italic = true },
			["@keyword.repeat"] = { fg = P_RED, italic = true },
			["@keyword.return"] = { fg = P_RED, italic = true },
			["@statement.return"] = { fg = P_RED, italic = true },
			["@keyword.import"] = { fg = G_MUTED, italic = true },
			["@keyword.export"] = { fg = G_MUTED, italic = true },
			["@statement.import"] = { fg = G_MUTED, italic = true },
			["@keyword.function"] = { fg = P_RED, italic = true },
			["@keyword.constructor"] = { fg = G_MUTED, italic = true },
			["@constructor"] = { fg = G_MUTED, italic = true },
			["@statement"] = { fg = G_MUTED, italic = true },
			Statement = { fg = G_MUTED, italic = true },
			Keyword = { fg = G_MUTED, italic = true },

			-- ===== Operators / punctuation =====
			["@keyword.operator"] = { fg = P_RED },
			["@operator"] = { fg = P_RED },
			Operator = { fg = P_RED },
			Exception = { fg = P_RED },
			["@punctuation.bracket"] = { fg = P_BRIGHT },
			["@punctuation.delimiter"] = { fg = G_MUTED },
			Delimiter = { fg = G_MUTED },

			-- ===== Numbers / constants / primitives =====
			["@number"] = { fg = P_ORANGE },
			["@number.float"] = { fg = P_ORANGE },
			["@boolean"] = { fg = P_ORANGE },
			["@constant"] = { fg = G_PRIMARY }, -- back to body text
			["@constant.builtin"] = { fg = P_ORANGE }, -- True/False/None/null still orange
			Constant = { fg = G_PRIMARY },
			Boolean = { fg = P_ORANGE },

			-- ===== Strings =====
			["@string"] = { fg = P_STRING },
			String = { fg = P_STRING },

			-- ===== Comments =====
			["@comment"] = { fg = G_COMMENT, italic = true },
			Comment = { fg = G_COMMENT, italic = true },

			-- ===== Normal / UI / Floats =====
			Normal = { fg = G_PRIMARY },
			NormalFloat = { bg = "none", fg = G_PRIMARY },
			FloatTitle = { bg = "none", fg = G_PRIMARY },
			FloatBorder = { bg = "none", fg = G_COMMENT },
			NormalDark = { fg = G_MUTED, bg = theme.ui.bg },
			LazyNormal = { bg = theme.ui.bg, fg = G_MUTED },
			MasonNormal = { bg = theme.ui.bg, fg = G_MUTED },
			Pmenu = { fg = G_MUTED, bg = theme.ui.bg },
			PmenuSel = { fg = G_PRIMARY, bg = theme.ui.bg_p1 },
			PmenuSbar = { bg = theme.ui.bg },
			PmenuThumb = { bg = theme.ui.bg_p1 },

			-- ===== Diagnostics =====
			DiagnosticVirtualTextHint = { fg = G_COMMENT, bg = "none" },
			DiagnosticVirtualTextInfo = { fg = G_MUTED, bg = "none" },
			DiagnosticVirtualTextWarn = { fg = P_ORANGE, bg = "none" },
			DiagnosticVirtualTextError = { fg = P_RED, bg = "none" },

			-- ===== Telescope =====
			TelescopeTitle = { fg = G_PRIMARY },
			TelescopePromptNormal = { fg = G_PRIMARY, bg = theme.ui.bg },
			TelescopePromptBorder = { fg = G_COMMENT, bg = theme.ui.bg },
			TelescopeResultsNormal = { fg = G_MUTED, bg = theme.ui.bg },
			TelescopeResultsBorder = { fg = G_COMMENT, bg = theme.ui.bg },
			TelescopePreviewNormal = { fg = G_PRIMARY, bg = theme.ui.bg },
			TelescopePreviewBorder = { fg = G_COMMENT, bg = theme.ui.bg },
		}
	end,
	theme = "dragon",
	background = {
		dark = "dragon",
		light = "lotus",
	},
})

vim.treesitter.query.set(
	"typescript",
	"highlights",
	[[
; extends
((type_identifier) @type (#set! priority 99))
((identifier) @variable (#set! priority 101))
]]
)
