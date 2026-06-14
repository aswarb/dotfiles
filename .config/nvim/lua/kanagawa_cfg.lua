local T0 = "#f4f5f8"  -- primary: variables, types, brackets
local T1 = "#c4c7ce"  -- secondary text
local T2 = "#9aa0ad"  -- tertiary: keywords
local T3 = "#888d99"  -- muted: params, props, punctuation
local T4 = "#4f535e"  -- comment / border

local AMBER   = "#edc99a"  -- primitives: numbers, booleans
local APRICOT = "#d4a574"  -- strings
local CYAN    = "#8ad0d4"  -- functions, class declarations
local CORAL   = "#e07860"  -- control flow, operators, warnings
local CHERRY  = "#c85a5a"  -- errors

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
					fg = T0,
				},
			},
		},
	},
	overrides = function(colors)
		local theme = colors.theme
		return {
			-- ===== Variables =====
			["@variable"]            = { fg = T0 },
			["@variable.builtin"]    = { fg = T2 },
			["@variable.typescript"] = { fg = T0 },
			["@variable.parameter"]  = { fg = T3 },
			["@variable.member"]     = { fg = T3 },
			["@variable.property"]   = { fg = T3 },
			["@property"]            = { fg = T3 },
			["@field"]               = { fg = T3 },
			["@constant.builtin"]    = { fg = AMBER },
			Identifier               = { fg = T0 },
			["@lsp.type.variable"]   = { fg = T0 },
			["@lsp.type.parameter"]  = { fg = T3 },
			["@lsp.type.property"]   = { fg = T3 },
			["@lsp.type.class"]      = { fg = CYAN },

			-- ===== Types =====
			["@type"]         = { fg = T0 },
			["@type.builtin"] = { fg = T0 },
			Type              = { fg = T0 },

			-- ===== Functions =====
			["@function"]                         = { fg = CYAN },
			["@function.call"]                    = { fg = CYAN },
			["@function.method"]                  = { fg = CYAN },
			["@function.method.call"]             = { fg = CYAN },
			Function                              = { fg = CYAN },
			["@lsp.typemod.function.declaration"] = { fg = CYAN, bold = true },
			["@lsp.typemod.method.declaration"]   = { fg = CYAN, bold = true },

			-- ===== Keywords / control flow =====
			["@keyword"]             = { fg = T2,    italic = true },
			["@keyword.conditional"] = { fg = CORAL, italic = true },
			["@keyword.repeat"]      = { fg = CORAL, italic = true },
			["@keyword.return"]      = { fg = CORAL, italic = true },
			["@statement.return"]    = { fg = CORAL, italic = true },
			["@keyword.import"]      = { fg = T2,    italic = true },
			["@keyword.export"]      = { fg = T2,    italic = true },
			["@statement.import"]    = { fg = T2,    italic = true },
			["@keyword.function"]    = { fg = T2,    italic = true },
			["@keyword.constructor"] = { fg = T2,    italic = true },
			["@constructor"]         = { fg = CYAN },
			["@keyword.exception"]   = { fg = CORAL, italic = true },
			["@statement"]           = { fg = T2,    italic = true },
			Statement                = { fg = T2,    italic = true },
			Keyword                  = { fg = T2,    italic = true },

			-- ===== Operators / punctuation =====
			["@keyword.operator"]      = { fg = CORAL, italic = true },
			["@operator"]              = { fg = CORAL },
			Operator                   = { fg = CORAL },
			Exception                  = { fg = CORAL },
			["@punctuation.bracket"]   = { fg = T0 },
			["@punctuation.delimiter"] = { fg = T3 },
			Delimiter                  = { fg = T3 },

			-- ===== Numbers / constants =====
			["@number"]       = { fg = AMBER },
			["@number.float"] = { fg = AMBER },
			["@boolean"]      = { fg = AMBER },
			["@constant"]     = { fg = T0 },
			Constant          = { fg = T0 },
			Boolean           = { fg = AMBER },
			Number            = { fg = AMBER },

			-- ===== Strings =====
			["@string"] = { fg = APRICOT },
			String      = { fg = APRICOT },

			-- ===== Comments =====
			["@comment"] = { fg = T4, italic = true },
			Comment      = { fg = T4, italic = true },

			-- ===== Normal / UI / Floats =====
			Normal      = { fg = T0 },
			NormalFloat = { bg = "#0c0f13", fg = T0 },
			FloatTitle  = { bg = "#0c0f13", fg = T0 },
			FloatBorder = { bg = "#0c0f13", fg = T4 },
			NormalDark  = { fg = T3,        bg = "#0c0f13" },
			LazyNormal  = { bg = "#0c0f13", fg = T3 },
			MasonNormal = { bg = "#0c0f13", fg = T3 },
			Pmenu       = { fg = T3,        bg = "#12151a" },
			PmenuSel    = { fg = T0,        bg = "#1e2128" },
			PmenuSbar   = { bg = "#12151a" },
			PmenuThumb  = { bg = "#2a2d33" },

			-- ===== Diagnostics =====
			DiagnosticVirtualTextHint  = { fg = T4,     bg = "none" },
			DiagnosticVirtualTextInfo  = { fg = T3,     bg = "none" },
			DiagnosticVirtualTextWarn  = { fg = CORAL,  bg = "none" },
			DiagnosticVirtualTextError = { fg = CHERRY, bg = "none" },

			-- ===== Telescope =====
			TelescopeTitle         = { fg = T0, bg = "#0c0f13" },
			TelescopePromptNormal  = { fg = T0, bg = "#0c0f13" },
			TelescopePromptBorder  = { fg = T4, bg = "#0c0f13" },
			TelescopeResultsNormal = { fg = T3, bg = "#12151a" },
			TelescopeResultsBorder = { fg = T4, bg = "#12151a" },
			TelescopePreviewNormal = { fg = T0, bg = "#12151a" },
			TelescopePreviewBorder = { fg = T4, bg = "#12151a" },
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
