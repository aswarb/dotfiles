-- ===== THE CLEANED CYNOSURE CORE =====
local G_PRIMARY   = "#f0ebe5" -- Raw Data Content: Variables, Identifiers, Numbers (Brightest Cream)
local G_SECONDARY = "#cdc6bc" -- Secondary Scaffolding: Types, Parameters, Built-ins (Lighter Cream)
local G_TERTIARY  = "#a8a299" -- Machine Commands: Keywords, Statements, Core Logic (Medium Warm Grey)
local G_MUTED     = "#7a746a" -- Structural Frame: Punctuation, Delimiters, Less Important UI (Stepped Down Warm Grey)
local G_COMMENT   = "#5a524d" -- Inactive Text: Comments, Floating Borders, Gutter Elements

-- ===== THE ISOLATED FRUIT TOKENS =====
local FRUIT_PEACH   = "#edc99a" -- Function Declarations Only (The Header Signature)
local FRUIT_CORAL   = "#e07860" -- Control Flow Logic Only (return, if, loop loops)
local FRUIT_CHERRY  = "#d96060" -- Critical Exceptions & Errors (High-Contrast Diagnostic Crimson)
local FRUIT_APRICOT = "#d4a574" -- Text Literals & Strings (The Soft Ochre Ink)
local FRUIT_WARN    = "#d49050" -- Transitory Alerts & Warnings (Pastel Warning Amber)

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
			all = { ui = { fg = G_PRIMARY } },
		},
	},
	overrides = function(colors)
		return {
			-- ===== Data Nouns (Primary Content Ledger) =====
			["@variable"]            = { fg = G_PRIMARY },
			["@variable.typescript"] = { fg = G_PRIMARY },
			Identifier               = { fg = G_PRIMARY },
			["@lsp.type.variable"]   = { fg = G_PRIMARY },
			["@constant"]            = { fg = G_PRIMARY },
			Constant                 = { fg = G_PRIMARY },
			["@number"]              = { fg = G_PRIMARY },
			["@number.float"] = { fg = G_PRIMARY },
			Number                   = { fg = G_PRIMARY },

			-- ===== Architectural Scaffolding (Secondary Tier) =====
			["@variable.builtin"]    = { fg = G_SECONDARY },
			["@variable.parameter"]  = { fg = G_SECONDARY },
			["@variable.member"]     = { fg = G_SECONDARY },
			["@variable.property"]   = { fg = G_SECONDARY },
			["@property"]            = { fg = G_SECONDARY },
			["@field"]               = { fg = G_SECONDARY },
			["@constant.builtin"]    = { fg = G_SECONDARY },
			["@lsp.type.parameter"]  = { fg = G_SECONDARY },
			["@lsp.type.property"]   = { fg = G_SECONDARY },
			["@boolean"]             = { fg = G_SECONDARY },
			Boolean                  = { fg = G_SECONDARY },
			["@type"]                = { fg = G_SECONDARY },
			Type                     = { fg = G_SECONDARY },

			-- ===== Machine Code Logic (The Grey Baseline) =====
			["@function"]             = { fg = G_TERTIARY },
			["@function.call"]        = { fg = G_TERTIARY },
			["@function.method"]      = { fg = G_TERTIARY },
			["@function.method.call"] = { fg = G_TERTIARY },
			Function                  = { fg = G_TERTIARY },
			["@keyword"]              = { fg = G_TERTIARY, italic = true },
			["@keyword.import"]       = { fg = G_TERTIARY, italic = true },
			["@keyword.export"]       = { fg = G_TERTIARY, italic = true },
			["@statement.import"]     = { fg = G_TERTIARY, italic = true },
			["@keyword.function"]     = { fg = G_TERTIARY, italic = true },
			["@keyword.constructor"]  = { fg = G_TERTIARY, italic = true },
			["@constructor"]          = { fg = G_TERTIARY, italic = true },
			["@statement"]            = { fg = G_TERTIARY, italic = true },
			Statement                 = { fg = G_TERTIARY, italic = true },
			Keyword                   = { fg = G_TERTIARY, italic = true },
			["@type.builtin"]         = { fg = G_MUTED },

			-- ===== Active Fruit Highlights (Isolated Semantics) =====
			["@lsp.typemod.function.declaration"] = { fg = FRUIT_PEACH, bold = true },
			["@lsp.typemod.method.declaration"]   = { fg = FRUIT_PEACH, bold = true },
			["@keyword.conditional"]              = { fg = FRUIT_CORAL, italic = true },
			["@keyword.repeat"]                   = { fg = FRUIT_CORAL, italic = true },
			["@keyword.return"]                   = { fg = FRUIT_CORAL, italic = true },
			["@statement.return"]                 = { fg = FRUIT_CORAL, italic = true },
			["@string"]                           = { fg = FRUIT_APRICOT },
			String                                = { fg = FRUIT_APRICOT },

			-- ===== Mechanical Hardening (The Punctuation Layer) =====
			["@punctuation.bracket"]   = { fg = G_PRIMARY }, -- Rejoined to content white to prevent double-cream noise
			["@punctuation.delimiter"] = { fg = G_MUTED },
			Delimiter                  = { fg = G_MUTED },
			["@keyword.operator"]      = { fg = G_MUTED }, -- Softened to grey to keep large code screens resting
			["@operator"]              = { fg = G_MUTED },
			Operator                   = { fg = G_MUTED },
			Exception                  = { fg = FRUIT_CHERRY, bold = true }, -- Exception maps natively to failure crimson

			-- ===== Inactive Canvas Layers =====
			["@comment"] = { fg = G_COMMENT, italic = true },
			Comment      = { fg = G_COMMENT, italic = true },
			["@lsp.type.class"]      = { fg = G_COMMENT },

			-- ===== UI Windows / Panes / Floating Layouts =====
			Normal      = { fg = G_PRIMARY },
			NormalFloat = { bg = "#111215", fg = G_PRIMARY }, -- Tightened obsidian black to match your terminal base
			FloatTitle  = { bg = "#111215", fg = G_PRIMARY },
			FloatBorder = { bg = "#111215", fg = G_COMMENT },
			NormalDark  = { fg = G_MUTED,   bg = "#111215" },
			LazyNormal  = { bg = "#111215", fg = G_MUTED },
			MasonNormal = { bg = "#111215", fg = G_MUTED },
			Pmenu       = { fg = G_MUTED,   bg = "#16161a" },
			PmenuSel    = { fg = G_PRIMARY, bg = "#22242b" },
			PmenuSbar   = { bg = "#16161a" },
			PmenuThumb  = { bg = "#262930" },

			-- ===== Real-Time Diagnostic Channels =====
			DiagnosticVirtualTextHint  = { fg = G_COMMENT,    bg = "none" },
			DiagnosticVirtualTextInfo  = { fg = G_MUTED,      bg = "none" },
			DiagnosticVirtualTextWarn  = { fg = FRUIT_WARN,   bg = "none" },
			DiagnosticVirtualTextError = { fg = FRUIT_CHERRY, bg = "none" },

			-- ===== Telescope Command Windows =====
			TelescopeTitle         = { fg = G_PRIMARY,   bg = "#111215" },
			TelescopePromptNormal  = { fg = G_PRIMARY,   bg = "#111215" },
			TelescopePromptBorder  = { fg = G_COMMENT,   bg = "#111215" },
			TelescopeResultsNormal = { fg = G_MUTED,     bg = "#16161a" },
			TelescopeResultsBorder = { fg = G_COMMENT,   bg = "#16161a" },
			TelescopePreviewNormal = { fg = G_PRIMARY,   bg = "#16161a" },
			TelescopePreviewBorder = { fg = G_COMMENT,   bg = "#16161a" },
		}
	end,
	theme = "dragon",
	background = { dark = "dragon", light = "lotus" },
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

