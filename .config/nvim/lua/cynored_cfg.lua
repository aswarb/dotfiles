-- ===== CYNOSURE / RED =====
--
-- Cynosure with four changes, and nothing else touched:
--
--   · control flow moves to the desktop's vermilion, so it carries the same
--     red as the bar, the prompt and the focus border
--   · ember is lifted off the surface -- brighter and a little more saturated,
--     so numeric literals read as a glow rather than as a warm grey
--   · control flow splits by what it does. `return`, `continue` and `break`
--     leave the block, so they take weight. `if` and `for` only shape it, so
--     they stay italic at regular weight. `break`/`continue` are
--     @keyword.repeat in every grammar, so after/queries/*/highlights.scm
--     re-captures them onto @keyword.return
--   · imports rise from tertiary grey to the vermilion, italic, no weight
--
-- ===== THE CLEANED CYNOSURE CORE =====
local INK_DATA   = "#f0ebe5" -- Raw Data Content: Variables, Identifiers (Brightest Cream)
local INK_BODY = "#cdc6bc" -- Secondary Scaffolding: Types, Parameters, Built-ins (Lighter Cream)
local INK_MACHINE  = "#a8a299" -- Machine Commands: Keywords, Statements, Core Logic (Medium Warm Grey)
local INK_FILLER = "#918b82" -- High-Frequency Filler: const, let, extends, get, set, static (Recessed Warm Grey)
local INK_FRAME     = "#7a746a" -- Structural Frame: Punctuation, Delimiters, Less Important UI (Stepped Down Warm Grey)
local INK_GUTTER   = "#5a524d" -- Inactive Text: Floating Borders, Gutter Elements
local COMMENT = "#485656" -- Comment Prose: INK_GUTTER's luminance with a cool cast, C 6 against C 4.7

-- ===== THE ISOLATED COLOUR TOKENS =====
-- Each is tied to a role, not to a severity, and each appears in exactly one
-- place. Named for the job rather than the pigment, so a value can be retuned
-- without the name going stale.
local DECL      = "#edc99a" -- function declarations only (the header signature)
local VERMILION = "#D9534A" -- control flow and imports; the desktop's accent
local ERROR     = "#d96060" -- exceptions and diagnostics
local STRING    = "#d4a574" -- text literals (the soft ochre ink)
local WARN      = "#d49050" -- transitory alerts
local EMBER     = "#F28C46" -- numeric and boolean literals; a glow in the night

local BUILTIN = "#949fb5" -- stdlib calls, method calls, interpolation, dirs

-- Two surfaces, per the design's bar spec: the bar itself is a quiet raised
-- plane, and the *open* item on it gets a selection fill. Was one cool
-- blue-grey (#22242b) for both, left over from kanagawa; against the warm
-- #131111 the terminal now paints it read as a cold slab.
local RAISED   = "#1A1716" -- the status bar plane
local FILL     = "#2E2725" -- the open tab / selected row; visibly a box

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
			all = { ui = { fg = INK_DATA } },
		},
	},
	overrides = function(colors)
		return {
			-- ===== Data Nouns (Primary Content Ledger) =====
			["@variable"]            = { fg = INK_DATA },
			Identifier               = { fg = INK_DATA },
			["@lsp.type.variable"]   = { fg = INK_DATA },
			["@constant"]            = { fg = INK_DATA },
			Constant                 = { fg = INK_DATA },
			["@number"]              = { fg = EMBER },
			["@number.float"]        = { fg = EMBER },
			Number                   = { fg = EMBER },

			-- ===== Architectural Scaffolding (Secondary Tier) =====
			["@variable.builtin"]    = { fg = INK_BODY },
			["@variable.parameter"]  = { fg = INK_BODY },
			["@variable.member"]     = { fg = INK_BODY },
			["@variable.property"]   = { fg = INK_BODY },
			["@property"]            = { fg = INK_BODY },
			["@field"]               = { fg = INK_BODY },
			["@constant.builtin"]    = { fg = EMBER }, -- NULL / null / undefined are literals
			["@constant.macro"]      = { fg = INK_DATA },   -- a #define'd name is a named constant
			["@lsp.type.parameter"]  = { fg = INK_BODY },
			["@lsp.type.property"]   = { fg = INK_BODY },
			["@boolean"]             = { fg = EMBER },
			Boolean                  = { fg = EMBER },

			-- ===== Type Expression Structure =====
			["@type"]                = { fg = INK_BODY },
			Type                     = { fg = INK_BODY },
			["@lsp.type.interface"]  = { fg = INK_BODY },
			["@lsp.type.type"]       = { fg = INK_BODY }, -- what tsc actually emits; class/interface never arrive

			-- Type parameters are bound names, the analogue of variables in value
			-- code. Treesitter captures every type_identifier as @type, so only the
			-- semantic tokens can separate them from the concrete types around them.
			["@lsp.type.typeParameter"] = { fg = INK_DATA },
			["@type.parameter"]         = { fg = INK_DATA },

			-- Primitives recede: they are the most repeated tokens in an annotation.
			["@type.builtin"]         = { fg = INK_FILLER },
			["@lsp.type.builtinType"] = { fg = INK_FILLER },

			-- ===== Callables: Declaration vs Call Site =====
			["@function"]             = { fg = DECL },
			["@function.method"]      = { fg = DECL },
			Function                  = { fg = DECL },
			["@function.call"]        = { fg = INK_MACHINE, bold = true },
			["@function.method.call"] = { fg = BUILTIN },
			["@lsp.type.method"]      = { fg = BUILTIN },

			-- DECL is declarations only. These two outrank the treesitter line
			-- above (125 and 127), so without them every call renders DECL -- and
			-- DECL sits only deltaE 13.5 from STRING.
			["@lsp.type.function"]             = { fg = INK_MACHINE, bold = true },
			["@lsp.typemod.function.readonly"] = { fg = INK_MACHINE, bold = true }, -- imports are const bindings

			["@lsp.typemod.function.declaration"] = { fg = DECL, bold = true },
			["@lsp.typemod.method.declaration"]   = { fg = DECL, bold = true },
			-- `definition` is gopls's spelling of `declaration`.
			["@lsp.typemod.function.definition"]  = { fg = DECL, bold = true },
			["@lsp.typemod.method.definition"]    = { fg = DECL, bold = true },

			-- Standard-library callables, from treesitter and the LSP alike.
			["@function.builtin"]                    = { fg = BUILTIN },
			["@module.builtin"]                      = { fg = BUILTIN },
			["@lsp.typemod.method.defaultLibrary"]   = { fg = BUILTIN },
			["@lsp.typemod.function.defaultLibrary"] = { fg = BUILTIN },
			["@lsp.typemod.variable.defaultLibrary"] = { fg = BUILTIN },

			-- ===== Keyword Ramp =====
			-- Separation by step, not hue: keywords are too frequent for an accent.
			-- Declaration boundary: export / import / class / interface / function.
			-- Imports rise to the vermilion: they are the file's boundary with
			-- everything outside it. Italic, no weight -- the same red as control
			-- flow, but never competing with it.
			["@keyword.import"]      = { fg = VERMILION, italic = true },
			["@keyword.export"]      = { fg = VERMILION, italic = true },
			["@statement.import"]    = { fg = VERMILION, italic = true },
			["@keyword.type"]        = { fg = INK_MACHINE, italic = true },
			["@keyword.function"]    = { fg = INK_MACHINE, italic = true },
			["@keyword.constructor"] = { fg = INK_MACHINE, italic = true },
			["@constructor"]         = { fg = INK_BODY, italic = true }, -- `new Map()`; the LSP calls this a class

			-- High-frequency filler: const / let / var / extends / static / get / set.
			["@keyword"]   = { fg = INK_FILLER, italic = true },
			["@statement"] = { fg = INK_FILLER, italic = true },
			Statement      = { fg = INK_FILLER, italic = true },
			Keyword        = { fg = INK_FILLER, italic = true },

			-- Shaping the block: italic, regular weight.
			["@keyword.conditional"] = { fg = VERMILION, italic = true },
			["@keyword.repeat"]      = { fg = VERMILION, italic = true },
			-- Leaving the block: weight instead of slant. `break` and `continue`
			-- arrive here via after/queries/*/highlights.scm.
			["@keyword.return"]      = { fg = VERMILION, bold = true, italic = false },
			["@statement.return"]    = { fg = VERMILION, bold = true, italic = false },
			["@keyword.exception"]   = { fg = ERROR, italic = true },

			-- ===== Literals =====
			["@string"]             = { fg = STRING },
			String                  = { fg = STRING },
			["@string.regexp"]      = { fg = STRING },
			["@string.escape"]      = { fg = WARN },
			["@character.special"]  = { fg = WARN },
			["@string.special.url"] = { fg = STRING, underline = true },

			-- ===== Mechanical Hardening (The Punctuation Layer) =====
			["@punctuation.bracket"]   = { fg = INK_DATA }, -- structural, so they stay at content weight
			["@punctuation.delimiter"] = { fg = INK_FRAME },
			["@punctuation.special"]   = { fg = BUILTIN }, -- `${}`: where a string stops being text
			Delimiter                  = { fg = INK_FRAME },
			["@keyword.operator"]      = { fg = INK_FRAME },   -- word operators: as / keyof / satisfies
			["@operator"]              = { fg = INK_MACHINE }, -- symbols carry meaning; 4.04:1 was separator level
			Operator                   = { fg = INK_MACHINE },
			Exception                  = { fg = ERROR, bold = true },

			-- The only three language-suffixed groups kanagawa defines. Pinned to
			-- their bases, since a suffixed group outranks the base one.
			["@constructor.lua"]         = { fg = INK_BODY, italic = true },
			["@keyword.lua"]             = { fg = INK_FILLER, italic = true },
			["@lsp.type.decorator.rust"] = { fg = INK_DATA },

			-- ===== Inactive Canvas Layers =====
			["@comment"] = { fg = COMMENT, italic = true },
			Comment      = { fg = COMMENT, italic = true },
			["@lsp.type.class"] = { fg = INK_BODY },

			-- ===== File Listings (netrw) and the Vim Groups Behind Them =====
			-- netrw links to stock vim groups, so these are set rather than netrw*.
			-- Dirs and executables match what `ls` does in the terminal theme.
			Directory  = { fg = BUILTIN },
			netrwExe   = { fg = INK_BODY }, -- direct: PreProc is also every #include in C
			PreProc    = { fg = INK_MACHINE },
			Question   = { fg = INK_MACHINE },  -- netrwSymLink
			Title      = { fg = INK_DATA },
			Folded     = { fg = INK_FRAME },
			WarningMsg = { fg = WARN },
			TabLineSel = { fg = INK_DATA, bg = FILL, bold = true },
			netrwGray  = { fg = INK_FRAME },     -- hard-coded to gray70 in netrw's syntax file

			-- ===== Highlighting =====
			-- Both fills are BUILTIN's hue taken dark: in a warm palette, only
			-- leaving the warm band is findable peripherally. Search replaces the
			-- foreground, so the fill can be strong. Warn marks the item under
			-- focus, the same thing it means on MatchParen -- weight alone was not
			-- enough to spot it under `:s///gc`, which uses IncSearch.
			Search     = { fg = INK_DATA, bg = "#2d486c" },
			CurSearch  = { fg = "#16161a", bg = WARN, bold = true },
			IncSearch  = { fg = "#16161a", bg = WARN, bold = true },
			Substitute = { fg = INK_DATA, bg = ERROR, bold = true }, -- bold: INK_DATA on ERROR is 3.06:1

			-- Visual keeps the foreground, so the fill sits under every token.
			-- Comments land within ~2:1 of it at any darkness.
			Visual     = { bg = "#243145" },
			VisualNOS  = { bg = "#243145" },
			MatchParen = { fg = WARN, bold = true },

			-- ===== Statusline / Tabline =====
			-- `transparent` clears Normal but not these; kanagawa left them at
			-- #0d0c0c, darker than the terminal, so the bar read as a black slab.
			-- Lifted one step above the buffer instead.
			StatusLine   = { fg = INK_BODY, bg = RAISED },
			StatusLineNC = { fg = INK_FRAME,     bg = RAISED },
			-- The tab row sits on the buffer surface, not on the bar plane.
			-- Closed files are bare ink on it; the open one is a solid fill
			-- (see TabLineSel). Not an underline: tmux drops SGR 58 unless
			-- the terminal entry advertises Setulc, and neither the alacritty
			-- nor the tmux-256color terminfo does -- so a coloured rule
			-- arrives stripped and renders in the text colour instead.
			TabLine      = { fg = INK_FRAME, bg = "NONE" },
			TabLineFill  = { bg = "NONE" },
			WinBar       = { fg = INK_BODY, bg = RAISED },
			WinBarNC     = { fg = INK_FRAME,     bg = RAISED },

			-- ===== UI Windows / Panes / Floating Layouts =====
			Normal      = { fg = INK_DATA },
			NormalFloat = { bg = "#111215", fg = INK_DATA },
			FloatTitle  = { bg = "#111215", fg = INK_DATA },
			FloatBorder = { bg = "#111215", fg = INK_GUTTER },
			NormalDark  = { fg = INK_FRAME,   bg = "#111215" },
			LazyNormal  = { bg = "#111215", fg = INK_FRAME },
			MasonNormal = { bg = "#111215", fg = INK_FRAME },
			Pmenu       = { fg = INK_FRAME,   bg = "#16161a" },
			PmenuSel    = { fg = INK_DATA, bg = FILL },
			PmenuSbar   = { bg = "#16161a" },
			PmenuThumb  = { bg = "#262930" },

			-- ===== Real-Time Diagnostic Channels =====
			DiagnosticVirtualTextHint  = { fg = INK_GUTTER,    bg = "none" },
			DiagnosticVirtualTextInfo  = { fg = INK_FRAME,      bg = "none" },
			DiagnosticVirtualTextWarn  = { fg = WARN,   bg = "none" },
			DiagnosticVirtualTextError = { fg = ERROR, bg = "none" },

			-- ===== Telescope Command Windows =====
			TelescopeTitle         = { fg = INK_DATA,   bg = "#111215" },
			TelescopePromptNormal  = { fg = INK_DATA,   bg = "#111215" },
			TelescopePromptBorder  = { fg = INK_GUTTER,   bg = "#111215" },
			TelescopeResultsNormal = { fg = INK_FRAME,     bg = "#16161a" },
			TelescopeResultsBorder = { fg = INK_GUTTER,   bg = "#16161a" },
			TelescopePreviewNormal = { fg = INK_DATA,   bg = "#16161a" },
			TelescopePreviewBorder = { fg = INK_GUTTER,   bg = "#16161a" },
			TelescopeBorder        = { fg = INK_GUTTER,   bg = "#16161a" },
			TelescopeSelection     = { fg = INK_DATA,   bg = FILL },
			TelescopeSelectionCaret = { fg = VERMILION, bg = FILL },
			TelescopeMultiSelection = { fg = WARN, bg = FILL },
			TelescopeMultiIcon     = { fg = WARN },
			TelescopeMatching      = { fg = WARN,  bold = true },
			TelescopePromptPrefix  = { fg = DECL, bg = "#111215" },
			TelescopePromptCounter = { fg = INK_FRAME,     bg = "#111215" },
			TelescopePreviewHyphen = { fg = INK_FRAME },
			TelescopePreviewLine   = { bg = RAISED },
			TelescopePreviewMatch  = { fg = INK_DATA,   bg = RAISED },
			TelescopeResultsLineNr = { fg = INK_FRAME,     bg = "#16161a" },

			-- Success is brightness, never green.
			TelescopeResultsDiffAdd       = { fg = INK_DATA },
			TelescopeResultsDiffChange    = { fg = WARN },
			TelescopeResultsDiffDelete    = { fg = ERROR },
			TelescopeResultsDiffUntracked = { fg = INK_FRAME },
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
