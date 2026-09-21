-- ===== THE CLEANED CYNOSURE CORE =====
local G_PRIMARY   = "#f0ebe5" -- Raw Data Content: Variables, Identifiers (Brightest Cream)
local G_SECONDARY = "#cdc6bc" -- Secondary Scaffolding: Types, Parameters, Built-ins (Lighter Cream)
local G_TERTIARY  = "#a8a299" -- Machine Commands: Keywords, Statements, Core Logic (Medium Warm Grey)
local G_QUATERNARY = "#918b82" -- High-Frequency Filler: const, let, extends, get, set, static (Recessed Warm Grey)
local G_MUTED     = "#7a746a" -- Structural Frame: Punctuation, Delimiters, Less Important UI (Stepped Down Warm Grey)
local G_COMMENT   = "#5a524d" -- Inactive Text: Floating Borders, Gutter Elements
local COMMENT_TEAL = "#485656" -- Comment Prose: G_COMMENT's luminance with a cool cast, C 6 against C 4.7

-- ===== THE ISOLATED FRUIT TOKENS =====
local FRUIT_PEACH   = "#edc99a" -- Function Declarations Only (The Header Signature)
local FRUIT_CORAL   = "#e07860" -- Control Flow Logic Only (return, if, loop loops)
local FRUIT_CHERRY  = "#d96060" -- Critical Exceptions & Errors (High-Contrast Diagnostic Crimson)
local FRUIT_APRICOT = "#d4a574" -- Text Literals & Strings (The Soft Ochre Ink)
local FRUIT_WARN    = "#d49050" -- Transitory Alerts & Warnings (Pastel Warning Amber)
local FRUIT_EMBER   = "#de7c47" -- Numeric & Boolean Literals (Hot Metal)
-- Ember fills the one gap in the warm band: cherry and coral hold 26-39 degrees,
-- warn holds 66. Below L* 54 this hue is brown; below C 52 it merges with warn.

local DRAGON_TEAL = "#949fb5" -- kanagawa's dragonTeal: method calls, interpolation, dirs

require("kanagawa").setup({
	-- Compiled highlights cache to disk and ignore edits until :KanagawaCompile.
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
			all = { ui = { fg = G_PRIMARY } },
		},
	},
	overrides = function(colors)
		return {
			-- ===== Data Nouns (Primary Content Ledger) =====
			["@variable"]            = { fg = G_PRIMARY },
			Identifier               = { fg = G_PRIMARY },
			["@lsp.type.variable"]   = { fg = G_PRIMARY },
			["@constant"]            = { fg = G_PRIMARY },
			Constant                 = { fg = G_PRIMARY },
			["@number"]              = { fg = FRUIT_EMBER },
			["@number.float"]        = { fg = FRUIT_EMBER },
			Number                   = { fg = FRUIT_EMBER },

			-- ===== Architectural Scaffolding (Secondary Tier) =====
			["@variable.builtin"]    = { fg = G_SECONDARY },
			["@variable.parameter"]  = { fg = G_SECONDARY },
			["@variable.member"]     = { fg = G_SECONDARY },
			["@variable.property"]   = { fg = G_SECONDARY },
			["@property"]            = { fg = G_SECONDARY },
			["@field"]               = { fg = G_SECONDARY },
			["@constant.builtin"]    = { fg = FRUIT_EMBER }, -- NULL / null / undefined are literals
			["@constant.macro"]      = { fg = G_PRIMARY },   -- a #define'd name is a named constant
			["@lsp.type.parameter"]  = { fg = G_SECONDARY },
			["@lsp.type.property"]   = { fg = G_SECONDARY },
			["@boolean"]             = { fg = FRUIT_EMBER },
			Boolean                  = { fg = FRUIT_EMBER },

			-- ===== Type Expression Structure =====
			["@type"]                = { fg = G_SECONDARY },
			Type                     = { fg = G_SECONDARY },
			["@lsp.type.interface"]  = { fg = G_SECONDARY },
			["@lsp.type.type"]       = { fg = G_SECONDARY }, -- what tsc actually emits; class/interface never arrive

			-- Type parameters are bound names, the analogue of variables in value
			-- code. Treesitter captures every type_identifier as @type, so only the
			-- semantic tokens can separate them from the concrete types around them.
			["@lsp.type.typeParameter"] = { fg = G_PRIMARY },
			["@type.parameter"]         = { fg = G_PRIMARY },

			-- Primitives recede: they are the most repeated tokens in an annotation.
			["@type.builtin"]         = { fg = G_QUATERNARY },
			["@lsp.type.builtinType"] = { fg = G_QUATERNARY },

			-- ===== Callables: Declaration vs Call Site =====
			["@function"]             = { fg = FRUIT_PEACH },
			["@function.method"]      = { fg = FRUIT_PEACH },
			Function                  = { fg = FRUIT_PEACH },
			["@function.call"]        = { fg = G_TERTIARY, bold = true },
			["@function.method.call"] = { fg = DRAGON_TEAL },
			["@lsp.type.method"]      = { fg = DRAGON_TEAL },

			-- Peach is declarations only. These two outrank the treesitter line
			-- above (125 and 127), so without them every call renders peach -- and
			-- peach sits only deltaE 13.5 from the strings.
			["@lsp.type.function"]             = { fg = G_TERTIARY, bold = true },
			["@lsp.typemod.function.readonly"] = { fg = G_TERTIARY, bold = true }, -- imports are const bindings

			["@lsp.typemod.function.declaration"] = { fg = FRUIT_PEACH, bold = true },
			["@lsp.typemod.method.declaration"]   = { fg = FRUIT_PEACH, bold = true },
			-- `definition` is gopls's spelling of `declaration`.
			["@lsp.typemod.function.definition"]  = { fg = FRUIT_PEACH, bold = true },
			["@lsp.typemod.method.definition"]    = { fg = FRUIT_PEACH, bold = true },

			-- Standard-library callables, from treesitter and the LSP alike.
			["@function.builtin"]                    = { fg = DRAGON_TEAL },
			["@module.builtin"]                      = { fg = DRAGON_TEAL },
			["@lsp.typemod.method.defaultLibrary"]   = { fg = DRAGON_TEAL },
			["@lsp.typemod.function.defaultLibrary"] = { fg = DRAGON_TEAL },
			["@lsp.typemod.variable.defaultLibrary"] = { fg = DRAGON_TEAL },

			-- ===== Keyword Ramp =====
			-- Separation by step, not hue: keywords are too frequent for an accent.
			-- Declaration boundary: export / import / class / interface / function.
			["@keyword.import"]      = { fg = G_TERTIARY, italic = true },
			["@keyword.export"]      = { fg = G_TERTIARY, italic = true },
			["@statement.import"]    = { fg = G_TERTIARY, italic = true },
			["@keyword.type"]        = { fg = G_TERTIARY, italic = true },
			["@keyword.function"]    = { fg = G_TERTIARY, italic = true },
			["@keyword.constructor"] = { fg = G_TERTIARY, italic = true },
			["@constructor"]         = { fg = G_SECONDARY, italic = true }, -- `new Map()`; the LSP calls this a class

			-- High-frequency filler: const / let / var / extends / static / get / set.
			["@keyword"]   = { fg = G_QUATERNARY, italic = true },
			["@statement"] = { fg = G_QUATERNARY, italic = true },
			Statement      = { fg = G_QUATERNARY, italic = true },
			Keyword        = { fg = G_QUATERNARY, italic = true },

			["@keyword.conditional"] = { fg = FRUIT_CORAL, italic = true },
			["@keyword.repeat"]      = { fg = FRUIT_CORAL, italic = true },
			["@keyword.return"]      = { fg = FRUIT_CORAL, italic = true },
			["@statement.return"]    = { fg = FRUIT_CORAL, italic = true },
			["@keyword.exception"]   = { fg = FRUIT_CHERRY, italic = true },

			-- ===== Literals =====
			["@string"]             = { fg = FRUIT_APRICOT },
			String                  = { fg = FRUIT_APRICOT },
			["@string.regexp"]      = { fg = FRUIT_APRICOT },
			["@string.escape"]      = { fg = FRUIT_WARN },
			["@character.special"]  = { fg = FRUIT_WARN },
			["@string.special.url"] = { fg = FRUIT_APRICOT, underline = true },

			-- ===== Mechanical Hardening (The Punctuation Layer) =====
			["@punctuation.bracket"]   = { fg = G_PRIMARY }, -- structural, so they stay at content weight
			["@punctuation.delimiter"] = { fg = G_MUTED },
			["@punctuation.special"]   = { fg = DRAGON_TEAL }, -- `${}`: where a string stops being text
			Delimiter                  = { fg = G_MUTED },
			["@keyword.operator"]      = { fg = G_MUTED },   -- word operators: as / keyof / satisfies
			["@operator"]              = { fg = G_TERTIARY }, -- symbols carry meaning; 4.04:1 was separator level
			Operator                   = { fg = G_TERTIARY },
			Exception                  = { fg = FRUIT_CHERRY, bold = true },

			-- The only three language-suffixed groups kanagawa defines. Pinned to
			-- their bases, since a suffixed group outranks the base one.
			["@constructor.lua"]         = { fg = G_SECONDARY, italic = true },
			["@keyword.lua"]             = { fg = G_QUATERNARY, italic = true },
			["@lsp.type.decorator.rust"] = { fg = G_PRIMARY },

			-- ===== Inactive Canvas Layers =====
			["@comment"] = { fg = COMMENT_TEAL, italic = true },
			Comment      = { fg = COMMENT_TEAL, italic = true },
			["@lsp.type.class"] = { fg = G_SECONDARY },

			-- ===== File Listings (netrw) and the Vim Groups Behind Them =====
			-- netrw links to stock vim groups, so these are set rather than netrw*.
			-- Dirs and executables match what `ls` does in the terminal theme.
			Directory  = { fg = DRAGON_TEAL },
			netrwExe   = { fg = G_SECONDARY }, -- direct: PreProc is also every #include in C
			PreProc    = { fg = G_TERTIARY },
			Question   = { fg = G_TERTIARY },  -- netrwSymLink
			Title      = { fg = G_PRIMARY },
			Folded     = { fg = G_MUTED },
			WarningMsg = { fg = FRUIT_WARN },
			TabLineSel = { fg = G_PRIMARY, bg = "NONE" },
			netrwGray  = { fg = G_MUTED },     -- hard-coded to gray70 in netrw's syntax file

			-- ===== Highlighting =====
			-- Both fills are DRAGON_TEAL's hue taken dark: in a warm palette, only
			-- leaving the warm band is findable peripherally. Search replaces the
			-- foreground, so the fill can be strong. Warn marks the item under
			-- focus, the same thing it means on MatchParen -- weight alone was not
			-- enough to spot it under `:s///gc`, which uses IncSearch.
			Search     = { fg = G_PRIMARY, bg = "#2d486c" },
			CurSearch  = { fg = "#16161a", bg = FRUIT_WARN, bold = true },
			IncSearch  = { fg = "#16161a", bg = FRUIT_WARN, bold = true },
			Substitute = { fg = G_PRIMARY, bg = FRUIT_CHERRY, bold = true }, -- bold: cream on cherry is 3.06:1

			-- Visual keeps the foreground, so the fill sits under every token.
			-- Comments land within ~2:1 of it at any darkness.
			Visual     = { bg = "#243145" },
			VisualNOS  = { bg = "#243145" },
			MatchParen = { fg = FRUIT_WARN, bold = true },

			-- ===== Statusline / Tabline =====
			-- `transparent` clears Normal but not these; kanagawa left them at
			-- #0d0c0c, darker than the terminal, so the bar read as a black slab.
			-- Lifted one step above the buffer instead.
			StatusLine   = { fg = G_SECONDARY, bg = "#22242b" },
			StatusLineNC = { fg = G_MUTED,     bg = "#22242b" },
			TabLine      = { fg = G_MUTED,     bg = "#22242b" },
			TabLineFill  = { bg = "#22242b" },
			WinBar       = { fg = G_SECONDARY, bg = "#22242b" },
			WinBarNC     = { fg = G_MUTED,     bg = "#22242b" },

			-- ===== UI Windows / Panes / Floating Layouts =====
			Normal      = { fg = G_PRIMARY },
			NormalFloat = { bg = "#111215", fg = G_PRIMARY },
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
			TelescopeBorder        = { fg = G_COMMENT,   bg = "#16161a" },
			TelescopeSelection     = { fg = G_PRIMARY,   bg = "#22242b" },
			TelescopeSelectionCaret = { fg = FRUIT_PEACH, bg = "#22242b" },
			TelescopeMultiSelection = { fg = FRUIT_WARN, bg = "#22242b" },
			TelescopeMultiIcon     = { fg = FRUIT_WARN },
			TelescopeMatching      = { fg = FRUIT_WARN,  bold = true },
			TelescopePromptPrefix  = { fg = FRUIT_PEACH, bg = "#111215" },
			TelescopePromptCounter = { fg = G_MUTED,     bg = "#111215" },
			TelescopePreviewHyphen = { fg = G_MUTED },
			TelescopePreviewLine   = { bg = "#22242b" },
			TelescopePreviewMatch  = { fg = G_PRIMARY,   bg = "#22242b" },
			TelescopeResultsLineNr = { fg = G_MUTED,     bg = "#16161a" },

			-- Success is brightness, never green.
			TelescopeResultsDiffAdd       = { fg = G_PRIMARY },
			TelescopeResultsDiffChange    = { fg = FRUIT_WARN },
			TelescopeResultsDiffDelete    = { fg = FRUIT_CHERRY },
			TelescopeResultsDiffUntracked = { fg = G_MUTED },
		}
	end,
	theme = "dragon",
	background = { dark = "dragon", light = "lotus" },
})

-- Emptied so treesitter's finer captures win; after the colorscheme, since
-- kanagawa's overrides merge rather than replace.
vim.api.nvim_create_autocmd("ColorScheme", {
	group = vim.api.nvim_create_augroup("cynosure_lsp_neutralise", { clear = true }),
	callback = function()
		for _, group in ipairs({ "@lsp.type.macro", "@lsp.type.keyword" }) do
			vim.api.nvim_set_hl(0, group, {})
		end
	end,
})
