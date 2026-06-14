local G_PRIMARY   = "#f0ebe5" -- main text / locals / numbers (brightest cream)
local G_SECONDARY = "#cdc6bc" -- structure / types / parameters (lighter cream)
local G_TERTIARY  = "#a8a299" -- keywords / statements / constructors (medium warm grey)
local G_MUTED     = "#8a8479" -- operators / punctuation / less important UI (darker warm grey)
local G_COMMENT   = "#5a524d" -- comments / borders / floats

local FRUIT_PEACH   = "#edc99a" -- bright peach for signatures
local FRUIT_CORAL   = "#e07860" -- coral for control flow
local FRUIT_CHERRY  = "#d96060" -- vestige pastel red for errors
local FRUIT_APRICOT = "#d4a574" -- peach for strings
local FRUIT_WARN    = "#d49050" -- vestige pastel orange for warnings

local BRACKET_WHITE = "#faf7f2" -- bright warm white for brackets

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
			-- ===== Variables =====
			["@variable"]            = { fg = G_PRIMARY },
			["@variable.builtin"]    = { fg = G_SECONDARY },
			["@variable.typescript"] = { fg = G_PRIMARY },
			["@variable.parameter"]  = { fg = G_SECONDARY },
			["@variable.member"]     = { fg = G_SECONDARY },
			["@variable.property"]   = { fg = G_SECONDARY },
			["@property"]            = { fg = G_SECONDARY },
			["@field"]               = { fg = G_SECONDARY },
			["@constant.builtin"]    = { fg = G_SECONDARY },
			Identifier               = { fg = G_PRIMARY },
			["@lsp.type.variable"]   = { fg = G_PRIMARY },
			["@lsp.type.parameter"]  = { fg = G_SECONDARY },
			["@lsp.type.property"]   = { fg = G_SECONDARY },
			["@lsp.type.class"]      = { fg = G_MUTED },

			-- ===== Types =====
			["@type"]         = { fg = G_SECONDARY },
			["@type.builtin"] = { fg = G_MUTED },
			Type              = { fg = G_SECONDARY },

			-- ===== Functions =====
			["@function"]                         = { fg = G_TERTIARY },
			["@function.call"]                    = { fg = G_TERTIARY },
			["@function.method"]                  = { fg = G_TERTIARY },
			["@function.method.call"]             = { fg = G_TERTIARY },
			Function                              = { fg = G_TERTIARY },
			["@lsp.typemod.function.declaration"] = { fg = FRUIT_PEACH, bold = true },
			["@lsp.typemod.method.declaration"]   = { fg = FRUIT_PEACH, bold = true },

			-- ===== Keywords / control flow =====
			["@keyword"]             = { fg = G_TERTIARY,   italic = true },
			["@keyword.conditional"] = { fg = FRUIT_CORAL,  italic = true },
			["@keyword.repeat"]      = { fg = FRUIT_CORAL,  italic = true },
			["@keyword.return"]      = { fg = FRUIT_CORAL,  italic = true },
			["@statement.return"]    = { fg = FRUIT_CORAL,  italic = true },
			["@keyword.import"]      = { fg = G_TERTIARY,   italic = true },
			["@keyword.export"]      = { fg = G_TERTIARY,   italic = true },
			["@statement.import"]    = { fg = G_TERTIARY,   italic = true },
			["@keyword.function"]    = { fg = G_TERTIARY,   italic = true },
			["@keyword.constructor"] = { fg = G_TERTIARY,   italic = true },
			["@constructor"]         = { fg = G_TERTIARY,   italic = true },
			["@statement"]           = { fg = G_TERTIARY,   italic = true },
			Statement                = { fg = G_TERTIARY,   italic = true },
			Keyword                  = { fg = G_TERTIARY,   italic = true },

			-- ===== Operators / punctuation =====
			["@keyword.operator"]      = { fg = FRUIT_CORAL, italic = true },
			["@operator"]              = { fg = FRUIT_CORAL },
			Operator                   = { fg = FRUIT_CORAL },
			Exception                  = { fg = FRUIT_CORAL },
			["@punctuation.bracket"]   = { fg = BRACKET_WHITE },
			["@punctuation.delimiter"] = { fg = G_MUTED },
			Delimiter                  = { fg = G_MUTED },

			-- ===== Numbers / constants =====
			["@number"]       = { fg = G_PRIMARY },
			["@number.float"] = { fg = G_PRIMARY },
			["@boolean"]      = { fg = G_SECONDARY },
			["@constant"]     = { fg = G_PRIMARY },
			Constant          = { fg = G_PRIMARY },
			Boolean           = { fg = G_SECONDARY },
			Number            = { fg = G_PRIMARY },

			-- ===== Strings =====
			["@string"] = { fg = FRUIT_APRICOT },
			String      = { fg = FRUIT_APRICOT },

			-- ===== Comments =====
			["@comment"] = { fg = G_COMMENT, italic = true },
			Comment      = { fg = G_COMMENT, italic = true },

			-- ===== Normal / UI / Floats =====
			Normal      = { fg = G_PRIMARY },
			NormalFloat = { bg = "#131210", fg = G_PRIMARY },
			FloatTitle  = { bg = "#131210", fg = G_PRIMARY },
			FloatBorder = { bg = "#131210", fg = G_COMMENT },
			NormalDark  = { fg = G_MUTED,   bg = "#131210" },
			LazyNormal  = { bg = "#131210", fg = G_MUTED },
			MasonNormal = { bg = "#131210", fg = G_MUTED },
			Pmenu       = { fg = G_MUTED,   bg = "#181818" },
			PmenuSel    = { fg = G_PRIMARY, bg = "#222222" },
			PmenuSbar   = { bg = "#181818" },
			PmenuThumb  = { bg = "#2a2a2a" },

			-- ===== Diagnostics =====
			DiagnosticVirtualTextHint  = { fg = G_COMMENT,    bg = "none" },
			DiagnosticVirtualTextInfo  = { fg = G_MUTED,      bg = "none" },
			DiagnosticVirtualTextWarn  = { fg = FRUIT_WARN,   bg = "none" },
			DiagnosticVirtualTextError = { fg = FRUIT_CHERRY, bg = "none" },

			-- ===== Telescope =====
			TelescopeTitle         = { fg = G_PRIMARY,   bg = "#131210" },
			TelescopePromptNormal  = { fg = G_PRIMARY,   bg = "#131210" },
			TelescopePromptBorder  = { fg = G_COMMENT,   bg = "#131210" },
			TelescopeResultsNormal = { fg = G_MUTED,     bg = "#181818" },
			TelescopeResultsBorder = { fg = G_COMMENT,   bg = "#181818" },
			TelescopePreviewNormal = { fg = G_PRIMARY,   bg = "#181818" },
			TelescopePreviewBorder = { fg = G_COMMENT,   bg = "#181818" },
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
