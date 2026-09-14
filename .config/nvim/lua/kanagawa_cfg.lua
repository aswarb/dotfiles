-- ===== THE CLEANED CYNOSURE CORE =====
local G_PRIMARY   = "#f0ebe5" -- Raw Data Content: Variables, Identifiers, Numbers (Brightest Cream)
local G_SECONDARY = "#cdc6bc" -- Secondary Scaffolding: Types, Parameters, Built-ins (Lighter Cream)
local G_TERTIARY  = "#a8a299" -- Machine Commands: Keywords, Statements, Core Logic (Medium Warm Grey)
local G_QUATERNARY = "#918b82" -- High-Frequency Filler: const, let, extends, get, set, static (Recessed Warm Grey)
local G_MUTED     = "#7a746a" -- Structural Frame: Punctuation, Delimiters, Less Important UI (Stepped Down Warm Grey)
local G_COMMENT   = "#5a524d" -- Inactive Text: Floating Borders, Gutter Elements
local COMMENT_TEAL = "#485656" -- Comment Prose (G_COMMENT with a cool cast)
-- G_COMMENT's luminance exactly (L* 35.5), carrying a slight cool tint instead
-- of its warm one -- C 6 against C 4.7, so it reads as a cast rather than as a
-- colour. Enough to stop comments being flat grey without pulling them toward
-- the reference image's actual teal, which at C 17+ was far too much.
--
-- Note this does not address legibility: contrast is a function of luminance
-- alone, so tinting scores identically to the untinted grey at 2.44:1. If
-- comments still read as too dim, the only lever is L*, not the tint.

-- ===== THE ISOLATED FRUIT TOKENS =====
local FRUIT_PEACH   = "#edc99a" -- Function Declarations Only (The Header Signature)
local FRUIT_CORAL   = "#e07860" -- Control Flow Logic Only (return, if, loop loops)
local FRUIT_CHERRY  = "#d96060" -- Critical Exceptions & Errors (High-Contrast Diagnostic Crimson)
local FRUIT_APRICOT = "#d4a574" -- Text Literals & Strings (The Soft Ochre Ink)
local FRUIT_WARN    = "#d49050" -- Transitory Alerts & Warnings (Pastel Warning Amber)
local FRUIT_EMBER   = "#de7c47" -- Numeric & Boolean Literals (Hot Metal)
-- Sits in the one empty stretch of the warm band: cherry and coral hold the red
-- end at 26 and 39 degrees, warn holds the yellow at 66, and nothing occupied
-- the orange between them. L* 62, C 56, clearing coral by deltaE 14.3 and warn
-- by 14.7.
--
-- This is the soft end of the runway. One more step down in chroma puts it
-- within deltaE 11 of warn and it stops being its own colour; the remaining way
-- to quieten it is to narrow what it applies to, not to mute it further. Darker
-- turns it brown, which is all a dark orange is, from about L* 54 down.

-- ===== THE INHERITED DRAGON ACCENT =====
-- kanagawa's own `dragonTeal`, previously arriving via an unset default. Pinned
-- here so it is visible in the ledger. Reserved for standard-library callables
-- only (Set.add, console.log) -- the one cool note, kept deliberately rare.
local DRAGON_TEAL = "#949fb5"

require("kanagawa").setup({
	-- Off deliberately. Compiled highlights are cached to disk and do not pick up
	-- edits to this file until :KanagawaCompile is run, so every tweak silently
	-- appeared to do nothing. Costs a few ms at startup; worth it.
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
			["@variable.typescript"] = { fg = G_PRIMARY },
			Identifier               = { fg = G_PRIMARY },
			["@lsp.type.variable"]   = { fg = G_PRIMARY },
			["@constant"]            = { fg = G_PRIMARY },
			Constant                 = { fg = G_PRIMARY },
			-- Literals, not identifiers. Previously indistinguishable from the
			-- variables around them, while strings carried their own colour.
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
			["@constant.builtin"]    = { fg = G_SECONDARY },
			["@lsp.type.parameter"]  = { fg = G_SECONDARY },
			["@lsp.type.property"]   = { fg = G_SECONDARY },
			["@boolean"]             = { fg = FRUIT_EMBER },
			Boolean                  = { fg = FRUIT_EMBER },

			-- ===== Type Expression Structure =====
			-- A signature like `Map<string, UserRecord>` previously rendered on a
			-- single value, giving it no internal shape. Four roles, so the eye can
			-- decompose an annotation without reading it word by word:

			-- 1. Domain nouns -- your own types, classes and interfaces. The anchor.
			["@type"]                = { fg = G_SECONDARY },
			Type                     = { fg = G_SECONDARY },
			["@lsp.type.interface"]  = { fg = G_SECONDARY },

			-- 2. Standard-library types deliberately NOT split out. `defaultLibrary`
			-- is knowable only from semantic tokens, so Map / Set / Promise would
			-- paint cream from treesitter and then repaint to teal once the server
			-- answers -- a visible pop on common tokens. They stay on the domain
			-- noun cream, which treesitter already gets right on first paint.

			-- 3. Type parameters -- TInput, TArtifacts, TRegistry. These are bound
			-- names you track through a signature, the exact analogue of variables
			-- in value code, so they take the identifier cream. Concrete types are
			-- the stable background they move against.
			--
			-- Treesitter cannot make this distinction: it captures every
			-- type_identifier as @type, so in a dense generic block the parameters
			-- and the imported types render as one undifferentiated mass. Only the
			-- semantic tokens know which is which, and this is the split that
			-- actually carries the meaning -- 57% of the identifier text in a real
			-- block of yours was type parameters.
			["@lsp.type.typeParameter"] = { fg = G_PRIMARY },
			["@type.parameter"]         = { fg = G_PRIMARY },

			-- The group tsc actually emits for a concrete type. Previously unset and
			-- working only by accident through the treesitter fallback; @lsp.type.class
			-- and @lsp.type.interface are never sent by this server.
			["@lsp.type.type"]          = { fg = G_SECONDARY },

			-- ===== Callables: Declaration vs Call Site =====
			-- Treesitter separates these already (@function for a declaration name,
			-- @function.call for a use), so the peach that marks a signature is
			-- painted on first parse rather than waiting for semantic tokens. The
			-- LSP groups below then add bold only -- a weight change, never a hue
			-- change, so nothing visibly recolours when the server attaches.
			["@function"]             = { fg = FRUIT_PEACH },
			["@function.method"]      = { fg = FRUIT_PEACH },
			Function                  = { fg = FRUIT_PEACH },
			["@function.call"]        = { fg = G_TERTIARY, bold = true },
			["@function.method.call"] = { fg = DRAGON_TEAL },
			["@lsp.type.method"]      = { fg = DRAGON_TEAL },
			-- Keyword ramp, brightest to dimmest. Separation is by step on the warm
			-- ramp, not by hue: these are far too frequent in TS to carry an accent.
			--
			-- Declaration keywords. export / import / from / class / interface /
			-- enum / function all open a declaration and read as one class of token,
			-- so they share a step rather than being spread across the ramp. This
			-- also empties them out of the type cream, which was carrying them
			-- alongside the actual type names.
			["@keyword.import"]      = { fg = G_TERTIARY, italic = true },
			["@keyword.export"]      = { fg = G_TERTIARY, italic = true },
			["@statement.import"]    = { fg = G_TERTIARY, italic = true },
			["@keyword.type"]        = { fg = G_TERTIARY, italic = true },
			["@keyword.function"]    = { fg = G_TERTIARY, italic = true },
			["@keyword.constructor"] = { fg = G_TERTIARY, italic = true },
			-- `new Map()` -- treesitter calls this @constructor, the LSP calls it a
			-- class. Matched to the class cream so the two agree on first paint.
			["@constructor"]         = { fg = G_SECONDARY, italic = true },

			-- Tier 3 -- High-frequency filler: const / let / var / extends / static
			-- / get / set. Recessed a step below the callable keywords above. These
			-- are the most repeated tokens on any screen, so dropping them is what
			-- lets the rarer keywords register without adding any new hue.
			["@keyword"]   = { fg = G_QUATERNARY, italic = true },
			["@statement"] = { fg = G_QUATERNARY, italic = true },
			Statement      = { fg = G_QUATERNARY, italic = true },
			Keyword        = { fg = G_QUATERNARY, italic = true },

			-- Tier 4 -- Connective tissue: `as` / `keyof` / `satisfies` recede into
			-- the punctuation layer (see @keyword.operator below) so that heavy
			-- type annotation never dominates the page.

			-- 4. Primitives -- string / number / boolean / void / any / never. I
			-- levelled these to the cream tier earlier to fix the darkness, but that
			-- was the wrong call: they are the most repeated tokens in any
			-- annotation, and flattening them into the domain nouns is a large part
			-- of why type logic read as one block. Recessed instead of darkened --
			-- G_QUATERNARY is a legible step, not the old G_MUTED.
			["@type.builtin"]         = { fg = G_QUATERNARY },
			["@lsp.type.builtinType"] = { fg = G_QUATERNARY },

			-- ===== Active Fruit Highlights (Isolated Semantics) =====
			["@lsp.typemod.function.declaration"] = { fg = FRUIT_PEACH, bold = true },
			["@lsp.typemod.method.declaration"]   = { fg = FRUIT_PEACH, bold = true },

			-- Standard-library callables. Treesitter paints @function.builtin on
			-- first parse, so the teal is present with no language server at all;
			-- the semantic-token groups then widen the same colour to everything
			-- the server can prove came from lib.d.ts. Identical hue, so the late
			-- repaint adds coverage without ever changing a colour on screen.
			["@function.builtin"]                    = { fg = DRAGON_TEAL },
			["@module.builtin"]                      = { fg = DRAGON_TEAL },
			["@lsp.typemod.method.defaultLibrary"]   = { fg = DRAGON_TEAL },
			["@lsp.typemod.function.defaultLibrary"] = { fg = DRAGON_TEAL },
			["@lsp.typemod.variable.defaultLibrary"] = { fg = DRAGON_TEAL },

			-- Call sites are grey; peach is reserved for declarations, which is what
			-- it is for. Both of these outrank the treesitter @function.call line
			-- below, so without them every call renders peach and that line is dead:
			-- @lsp.type.function is priority 125, and @lsp.typemod.function.readonly
			-- is 127. The latter catches imported functions -- expect, it, describe,
			-- vi -- which tsc tags `readonly` because imports are const bindings, and
			-- which kanagawa otherwise paints #8ba4b0, a blue this palette never
			-- defines and a near-twin of DRAGON_TEAL.
			--
			-- Keeping calls off peach also keeps them clear of the strings: peach and
			-- apricot are only deltaE 13.5 apart, which is fine when peach marks the
			-- occasional signature and not fine when it marks every call.
			-- Bold, so a call reads as a call rather than as one more thing on the
			-- warm grey. G_TERTIARY also carries the declaration keywords, and the
			-- weight is what separates them without spending another colour.
			["@lsp.type.function"]             = { fg = G_TERTIARY, bold = true },
			["@lsp.typemod.function.readonly"] = { fg = G_TERTIARY, bold = true },

			["@keyword.conditional"]              = { fg = FRUIT_CORAL, italic = true },
			["@keyword.repeat"]                   = { fg = FRUIT_CORAL, italic = true },
			["@keyword.return"]                   = { fg = FRUIT_CORAL, italic = true },
			["@statement.return"]                 = { fg = FRUIT_CORAL, italic = true },
			["@string"]                           = { fg = FRUIT_APRICOT },
			String                                = { fg = FRUIT_APRICOT },

			-- These three defaulted to kanagawa's own #c4746e, the one red in the
			-- buffer that belonged to no token in this file. Rehomed onto the
			-- existing warm set: regexes stay in the string family, escapes and
			-- special characters take the amber so they read as breaks in the ink.
			["@string.regexp"]      = { fg = FRUIT_APRICOT },
			["@string.escape"]      = { fg = FRUIT_WARN },
			["@character.special"]  = { fg = FRUIT_WARN },
			["@string.special.url"] = { fg = FRUIT_APRICOT, underline = true },
			["@keyword.exception"]  = { fg = FRUIT_CHERRY, italic = true },

			-- ===== Mechanical Hardening (The Punctuation Layer) =====
			["@punctuation.bracket"]   = { fg = G_PRIMARY }, -- Rejoined to content white to prevent double-cream noise
			["@punctuation.delimiter"] = { fg = G_MUTED },
			-- `${}` in template literals. Back on the blue: it marks the boundary
			-- where a string stops being text and starts being code, which is worth
			-- seeing against the apricot.
			["@punctuation.special"]   = { fg = DRAGON_TEAL },
			Delimiter                  = { fg = G_MUTED },
			["@keyword.operator"]      = { fg = G_MUTED }, -- Softened to grey to keep large code screens resting
			-- Symbols only, lifted off the separator tier. `&&`, `!`, `>`, `=>` and
			-- the `|` in a union change what a line means, unlike the commas and
			-- semicolons they were sharing a value with. 4.04:1 to 7.40:1, which
			-- matters more for symbols than for words -- small glyphs need the
			-- contrast that letterforms can do without. The word operators above
			-- (`as`, `keyof`, `satisfies`) stay recessed.
			["@operator"]              = { fg = G_TERTIARY },
			Operator                   = { fg = G_TERTIARY },
			Exception                  = { fg = FRUIT_CHERRY, bold = true }, -- Exception maps natively to failure crimson

			-- ===== Inactive Canvas Layers =====
			["@comment"] = { fg = COMMENT_TEAL, italic = true },
			Comment      = { fg = COMMENT_TEAL, italic = true },
			-- Was G_COMMENT, which sank every class name -- Set, Map, Promise and
			-- your own -- to comment darkness. Classes are scaffolding, so they
			-- belong on the secondary tier alongside types.
			["@lsp.type.class"] = { fg = G_SECONDARY },

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

-- The custom highlights query that used to live here has been removed. It called
-- `query.set`, which REPLACES the runtime query rather than extending it (the
-- `; extends` modeline only has meaning in an after/queries file), collapsing
-- TypeScript from 46 captures to 2. All three of its patterns are redundant
-- against the real query, which already yields @type, @type.builtin and
-- @variable -- and additionally distinguishes @function.call and @constructor,
-- which the identifier priority rule was flattening back into @variable.
