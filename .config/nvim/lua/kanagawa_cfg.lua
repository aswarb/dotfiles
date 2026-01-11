-- Cynosure Kanagawa Config: Warm Cream Palette
local G_PRIMARY   = "#f0ebe5" -- main text / locals / numbers (brightest cream)
local G_SECONDARY = "#cdc6bc" -- structure / types / conditionals / parameters (lighter cream)
local G_TERTIARY  = "#a8a299" -- keywords / statements / constructors (medium warm grey)
local G_MUTED     = "#8a8479" -- operators / punctuation / less important UI (darker warm grey)
local G_COMMENT   = "#5a524d" -- comments / borders / floats (lighter warm grey)

local FRUIT_PEACH = "#edc99a" -- bright peach/apricot for signatures
local FRUIT_CORAL = "#e07860" -- bright coral/salmon for control flow
local FRUIT_CHERRY = "#c85a5a" -- deep cherry for emphasis
local FRUIT_APRICOT = "#d4a574" -- normal peach for strings

local BRACKET_WHITE = "#faf7f2" -- bright warm white for brackets

require("kanagawa").setup({
	compile = false,
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
			-- ===== Variables =====
			["@variable"] = { fg = G_PRIMARY },
			["@variable.builtin"] = { fg = G_SECONDARY },
			["@variable.parameter"] = { fg = G_SECONDARY },
			["@variable.member"] = { fg = G_SECONDARY },
			["@variable.property"] = { fg = G_SECONDARY },
			["@property"] = { fg = G_SECONDARY },
			["@field"] = { fg = G_SECONDARY },
			["@constant.builtin"] = { fg = G_SECONDARY },
			Identifier = { fg = G_PRIMARY },
			["@lsp.type.variable"] = { fg = G_PRIMARY },
			["@lsp.type.parameter"] = { fg = G_SECONDARY },
			["@lsp.type.property"] = { fg = G_SECONDARY },
			
			-- ===== Functions =====
			["@function"] = { fg = G_TERTIARY }, -- calls in warm grey
			["@function.call"] = { fg = G_TERTIARY },
			["@function.method"] = { fg = G_TERTIARY },
			["@function.method.call"] = { fg = G_TERTIARY },
			Function = { fg = G_TERTIARY },
			["@lsp.typemod.function.declaration"] = { fg = FRUIT_PEACH, bold = true }, -- signatures in bright peach
			["@lsp.typemod.method.declaration"] = { fg = FRUIT_PEACH, bold = true },
			
			-- ===== Keywords / control flow =====
			["@keyword.conditional"] = { fg = FRUIT_CORAL, italic = true }, -- if/else in coral
			["@keyword.repeat"] = { fg = FRUIT_CORAL, italic = true }, -- for/while in coral
			["@keyword.return"] = { fg = FRUIT_CORAL, italic = true }, -- return in coral
			["@statement.return"] = { fg = FRUIT_CORAL, italic = true },
			["@keyword.import"] = { fg = G_TERTIARY, italic = true }, -- import/export fade
			["@keyword.export"] = { fg = G_TERTIARY, italic = true },
			["@statement.import"] = { fg = G_TERTIARY, italic = true },
			["@keyword.function"] = { fg = G_TERTIARY, italic = true },
			["@keyword.constructor"] = { fg = G_TERTIARY, italic = true },
			["@constructor"] = { fg = G_TERTIARY, italic = true },
			["@keyword"] = { fg = G_TERTIARY, italic = true },
			["@statement"] = { fg = G_TERTIARY, italic = true },
			Statement = { fg = G_TERTIARY, italic = true },
			Keyword = { fg = G_TERTIARY, italic = true },
			
			-- ===== Operators / punctuation =====
			["@keyword.operator"] = { fg = FRUIT_CORAL, italic = true }, -- operators in coral (like control flow)
			["@operator"] = { fg = FRUIT_CORAL },
			Operator = { fg = FRUIT_CORAL },
			Exception = { fg = FRUIT_CORAL },
			["@punctuation.bracket"] = { fg = BRACKET_WHITE }, -- bright warm white for brackets
			["@punctuation.delimiter"] = { fg = G_MUTED },
			Delimiter = { fg = G_MUTED },
			
			-- ===== Types =====
			["@type"] = { fg = G_SECONDARY },
			Type = { fg = G_SECONDARY },
			
			-- ===== Numbers / constants =====
			["@number"] = { fg = G_PRIMARY },
			["@constant"] = { fg = G_PRIMARY },
			Number = { fg = G_PRIMARY },
			Constant = { fg = G_PRIMARY },
			
			-- ===== Strings =====
			["@string"] = { fg = FRUIT_APRICOT }, -- strings in warm peachy tone
			String = { fg = FRUIT_APRICOT },
			
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
			DiagnosticVirtualTextWarn = { fg = FRUIT_APRICOT, bg = "none" }, -- warnings in peach
			DiagnosticVirtualTextError = { fg = FRUIT_CHERRY, bg = "none" }, -- errors in cherry red
			
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
