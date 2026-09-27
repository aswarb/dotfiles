-- crucible
--
-- Built from the syntax spec in Crucible.dc.html (the `syntax` table at :681
-- and the annotated code sample at :626). One vermilion accent on warm black:
-- the accent owns keywords and attributes, everything else is an ink ramp,
-- and three code hues carry strings, calls and numbers.
--
--   Keyword          fn let match impl      accent
--   Definition       fn next_token          ink 1 · bold
--   Class/struct     Token  Kind::Str       ink 2
--   Type annotation  usize  Option<char>    type
--   Function call    peek()  .find()        purple
--   Identifier       self.pos               ink 1
--   String           "unterminated"         secondary
--   Number · bool    16  true  2            amber light
--   Lifetime         'src                   ink 2 · italic
--   Attribute/macro  #[cfg(test)]           accent
--   Comment          // track line          ink 3 · italic
--   Punctuation      ( ) { } :: ;           ink 3
--
-- Transparency is on by default, matching the previous config and alacritty's
-- window opacity. Set `vim.g.crucible_transparent = false` before loading to
-- paint the surface instead.

local p = require("crucible.palette")

vim.cmd.highlight("clear")
if vim.fn.exists("syntax_on") == 1 then
	vim.cmd.syntax("reset")
end
vim.o.termguicolors = true
vim.g.colors_name = "crucible"

local transparent = vim.g.crucible_transparent
if transparent == nil then
	transparent = true
end

local ink, acc, code, st, ansi, surf, tint = p.ink, p.accent, p.code, p.status, p.ansi, p.surface, p.tint
local cmt = p.comment
local call_builtin, type_user = p.call_builtin, p.type_user

-- Surface under floats and the buffer. When transparent, `nil` lets the
-- terminal through; the tinted groups below still composite against the real
-- surface colour, which is what alacritty is showing.
local bg = transparent and "NONE" or surf.bg
local bg_float = transparent and "NONE" or surf.raised

local hl = {

	-- ── editor surfaces ──────────────────────────────────────────────────
	Normal = { fg = ink[1], bg = bg },
	NormalNC = { fg = ink[1], bg = bg },
	NormalFloat = { fg = ink[1], bg = bg_float },
	FloatBorder = { fg = ink[3], bg = bg_float },
	FloatTitle = { fg = acc.base, bg = bg_float, bold = true },
	ColorColumn = { bg = surf.sel },
	Conceal = { fg = ink[3] },
	EndOfBuffer = { fg = surf.bg },
	SignColumn = { fg = ink[3], bg = bg },
	FoldColumn = { fg = ink[3], bg = bg },
	Folded = { fg = ink[3], bg = surf.sel },
	VertSplit = { fg = surf.rule2 },
	WinSeparator = { fg = surf.rule2 },
	Whitespace = { fg = surf.rule },
	NonText = { fg = surf.rule },
	SpecialKey = { fg = surf.rule },
	Directory = { fg = ansi.blue, bold = true },
	Title = { fg = ink[1], bold = true },

	-- Cursor line is the selection surface; its number is the accent, which
	-- is the one place the accent marks "you are here" inside the buffer.
	CursorLine = { bg = surf.sel },
	CursorColumn = { bg = surf.sel },
	CursorLineNr = { fg = acc.base, bold = true },
	LineNr = { fg = ink[3] },
	LineNrAbove = { fg = ink[3] },
	LineNrBelow = { fg = ink[3] },
	CursorLineSign = { bg = surf.sel },
	CursorLineFold = { bg = surf.sel },

	Cursor = { fg = surf.bg, bg = ink[1] },
	lCursor = { link = "Cursor" },
	TermCursor = { link = "Cursor" },
	MatchParen = { fg = acc.base, bold = true },

	-- Visual gets the 22% accent tint rather than the selection surface.
	-- The doc uses `sel` for the cursorline, and at #241C1B it is far too
	-- quiet to show a selection you are actively dragging.
	Visual = { bg = tint.accent_35 },
	VisualNOS = { bg = tint.accent_35 },

	-- ── search ───────────────────────────────────────────────────────────
	-- Mirrors alacritty's search: every match is a solid yellow block, the
	-- focused one is the accent. A search result has to be findable from
	-- across the file, so these are the one place in the buffer that gets a
	-- saturated background -- a tint of the surface is not enough, and the
	-- previous 22% accent tint was so close to the background that matches
	-- read as ordinary text.
	Search = { fg = surf.bg, bg = st.warn, bold = true },
	IncSearch = { fg = surf.bg, bg = acc.base, bold = true },
	CurSearch = { fg = surf.bg, bg = acc.base, bold = true },
	Substitute = { fg = surf.bg, bg = code.call, bold = true },

	-- ── messages ─────────────────────────────────────────────────────────
	ErrorMsg = { fg = st.error },
	WarningMsg = { fg = st.warn },
	MoreMsg = { fg = st.ok },
	ModeMsg = { fg = ink[2], bold = true },
	MsgArea = { fg = ink[2] },
	MsgSeparator = { fg = surf.rule },
	Question = { fg = ansi.blue },

	-- ── popups ───────────────────────────────────────────────────────────
	Pmenu = { fg = ink[2], bg = surf.raised },
	PmenuSel = { fg = acc.base, bg = surf.sel, bold = true },
	PmenuKind = { fg = code.type, bg = surf.raised },
	PmenuKindSel = { fg = code.type, bg = surf.sel },
	PmenuExtra = { fg = ink[3], bg = surf.raised },
	PmenuExtraSel = { fg = ink[3], bg = surf.sel },
	PmenuSbar = { bg = surf.raised },
	PmenuThumb = { bg = surf.rule },
	WildMenu = { link = "PmenuSel" },

	-- ── status & tabs ────────────────────────────────────────────────────
	-- The bar sits one step above the buffer, as the doc's desktop panel
	-- draws it. lualine paints over this; these are the fallbacks.
	StatusLine = { fg = ink[2], bg = surf.raised },
	StatusLineNC = { fg = ink[3], bg = surf.raised },
	TabLine = { fg = ink[3], bg = surf.raised },
	TabLineFill = { bg = surf.bg },
	TabLineSel = { fg = acc.base, bg = surf.sel, bold = true },
	WinBar = { fg = ink[2], bg = bg },
	WinBarNC = { fg = ink[3], bg = bg },
	QuickFixLine = { bg = surf.sel, bold = true },

	-- ── diff ─────────────────────────────────────────────────────────────
	-- Follows the doc's own `git diff` rendering (:716-718): additions are
	-- green, removals are the accent -- not the error colour. A removed line
	-- is not a failure, and the doc reserves error for things that broke.
	DiffAdd = { fg = st.ok, bg = tint.ok_13 },
	DiffDelete = { fg = acc.base, bg = tint.accent_11 },
	DiffChange = { fg = st.warn, bg = tint.warn_10 },
	DiffText = { fg = st.warn, bg = tint.accent_22, bold = true },
	diffAdded = { fg = st.ok },
	diffRemoved = { fg = acc.base },
	diffChanged = { fg = st.warn },
	diffFile = { fg = ink[1], bold = true },
	diffLine = { fg = ansi.cyan },
	diffIndexLine = { fg = ink[3] },

	-- ── spelling ─────────────────────────────────────────────────────────
	SpellBad = { sp = st.error, undercurl = true },
	SpellCap = { sp = st.warn, undercurl = true },
	SpellLocal = { sp = ansi.cyan, undercurl = true },
	SpellRare = { sp = code.call, undercurl = true },

	-- ── legacy syntax ────────────────────────────────────────────────────
	Comment = { fg = cmt, italic = true },
	Constant = { fg = code.number },
	String = { fg = code.string },
	Character = { fg = code.string },
	Number = { fg = code.number },
	Boolean = { fg = code.number },
	Float = { fg = code.number },
	Identifier = { fg = ink[1] },
	Function = { fg = ink[1], bold = true },
	Statement = { fg = acc.base },
	Conditional = { fg = acc.base },
	Repeat = { fg = acc.base },
	Label = { fg = ink[2], italic = true },
	Operator = { fg = ink[2] },
	Keyword = { fg = acc.base },
	Exception = { fg = acc.base },
	PreProc = { fg = acc.base },
	Include = { fg = acc.base },
	Define = { fg = acc.base },
	Macro = { fg = acc.base },
	PreCondit = { fg = acc.base },
	Type = { fg = ink[2] },
	StorageClass = { fg = acc.base },
	Structure = { fg = ink[2] },
	Typedef = { fg = ink[2] },
	Special = { fg = code.call },
	SpecialChar = { fg = code.number },
	Tag = { fg = acc.base },
	Delimiter = { fg = ink[3] },
	SpecialComment = { fg = cmt, italic = true, bold = true },
	Debug = { fg = st.warn },
	Underlined = { underline = true },
	Ignore = { fg = ink[3] },
	Error = { fg = st.error },
	Todo = { fg = surf.bg, bg = st.warn, bold = true },

	-- ── treesitter ───────────────────────────────────────────────────────
	["@comment"] = { fg = cmt, italic = true },
	["@comment.documentation"] = { fg = cmt, italic = true },
	["@comment.todo"] = { fg = surf.bg, bg = st.warn, bold = true },
	["@comment.note"] = { fg = surf.bg, bg = ansi.blue, bold = true },
	["@comment.warning"] = { fg = surf.bg, bg = st.warn, bold = true },
	["@comment.error"] = { fg = surf.bg, bg = st.error, bold = true },

	["@constant"] = { fg = ink[1] },
	["@constant.builtin"] = { fg = code.number },
	-- A #define'd constant is a constant, not a macro invocation. The doc's
	-- "attribute · macro → accent" means `println!` and `#[cfg(test)]`, the
	-- things that *do* something. `HASHMAP_MAX_CAPACITY_EXPONENT` is a value.
	["@constant.macro"] = { fg = code.number },

	["@string"] = { fg = code.string },
	["@string.documentation"] = { fg = code.string },
	["@string.escape"] = { fg = code.number },
	["@string.regexp"] = { fg = ansi.cyan },
	["@string.special"] = { fg = code.number },
	["@string.special.url"] = { fg = ansi.blue, underline = true },
	["@character"] = { fg = code.string },
	["@character.special"] = { fg = code.number },

	["@number"] = { fg = code.number },
	["@number.float"] = { fg = code.number },
	["@boolean"] = { fg = code.number },

	-- A declaration is ink 1 bold; a call is purple. This is the one
	-- distinction the doc draws most sharply, so it is worth the extra
	-- captures rather than colouring all of @function alike.
	["@function"] = { fg = ink[1], bold = true },
	["@function.method"] = { fg = ink[1], bold = true },
	["@function.call"] = { fg = code.call },
	["@function.method.call"] = { fg = code.call },
	["@function.builtin"] = { fg = call_builtin },
	["@function.macro"] = { fg = acc.base },
	["@constructor"] = { fg = ink[2] },

	["@variable"] = { fg = ink[1] },
	["@variable.builtin"] = { fg = ink[1], italic = true },
	["@variable.parameter"] = { fg = ink[1] },
	["@variable.member"] = { fg = ink[1] },
	["@property"] = { fg = ink[1] },
	["@field"] = { fg = ink[1] },

	["@keyword"] = { fg = acc.base },
	["@keyword.function"] = { fg = acc.base },
	-- `sizeof`, `_Alignof`, Rust's `as`/`in`. These are operators that happen
	-- to be spelled with letters -- they compute something, they do not
	-- direct control flow, so they sit with the other recessed word-keywords
	-- rather than with `if` and `return`. The rule across the theme: words
	-- that steer execution are accent, words that merely qualify are ink 2,
	-- symbols are ink 3.
	["@keyword.operator"] = { fg = ink[2] },
	["@keyword.return"] = { fg = acc.base },
	["@keyword.conditional"] = { fg = acc.base },
	["@keyword.repeat"] = { fg = acc.base },
	["@keyword.exception"] = { fg = acc.base },
	["@keyword.import"] = { fg = acc.base },
	-- Modifiers are high-frequency filler: `static`, `const`, `inline`,
	-- `_Alignas`. They say nothing about what the code does -- nearly every
	-- function in a C translation unit is `static` -- so they recede and let
	-- the accent mean control flow. A departure from the doc, which shows
	-- `pub` and `mut` in accent; see TWEAKS.md.
	["@keyword.modifier"] = { fg = ink[2] },
	["@keyword.coroutine"] = { fg = acc.base },
	["@keyword.directive"] = { fg = acc.base },
	["@keyword.directive.define"] = { fg = acc.base },
	-- `struct`/`enum`/`union` in C are part of a type reference, not control
	-- flow -- `struct entry *e` names a type the way `Token` does in the
	-- doc's Rust sample, and the doc puts those on ink 2. Rust writes
	-- `struct` once per definition; C writes it on every declaration, so
	-- leaving it on the accent floods the file.
	["@keyword.type"] = { fg = ink[2] },

	-- Structs, enums and classes are ink 2; builtin types take the dimmer
	-- annotation colour. Treesitter cannot tell "a type being declared" from
	-- "a type being used as an annotation" -- both are @type -- so the split
	-- is drawn on builtin-vs-user instead, which lands `usize` and `char` on
	-- the annotation colour as the doc shows them.
	["@type"] = { fg = type_user },
	["@type.builtin"] = { fg = code.type },
	["@type.definition"] = { fg = type_user },
	["@type.qualifier"] = { fg = acc.base },
	["@module"] = { fg = ink[2] },
	["@module.builtin"] = { fg = ink[2] },
	["@namespace"] = { fg = ink[2] },

	-- Lifetimes. Rust's parser emits these as @label.
	["@label"] = { fg = ink[2], italic = true },

	-- Operators are not punctuation. The doc's punctuation row is `( ) { } ::
	-- ;` -- structure, which can recede safely because you read past it. An
	-- operator carries meaning (`=` vs `==`, `->`, `&&`) and is drawn with
	-- two or three thin strokes, so it needs *more* contrast than a word of
	-- the same importance, not less. ink 3 at 3.23:1 made them vanish.
	["@operator"] = { fg = ink[2] },
	["@punctuation.delimiter"] = { fg = ink[3] },
	["@punctuation.bracket"] = { fg = ink[3] },
	["@punctuation.special"] = { fg = code.call },

	["@attribute"] = { fg = acc.base },
	["@attribute.builtin"] = { fg = acc.base },

	["@tag"] = { fg = acc.base },
	["@tag.builtin"] = { fg = acc.base },
	["@tag.attribute"] = { fg = code.call },
	["@tag.delimiter"] = { fg = ink[3] },

	-- Markup. Headings take the accent because in prose the heading is the
	-- identity of the section, which is what the accent is for.
	["@markup.heading"] = { fg = acc.base, bold = true },
	["@markup.heading.1"] = { fg = acc.base, bold = true },
	["@markup.heading.2"] = { fg = acc.base, bold = true },
	["@markup.heading.3"] = { fg = ink[1], bold = true },
	["@markup.heading.4"] = { fg = ink[1], bold = true },
	["@markup.heading.5"] = { fg = ink[2], bold = true },
	["@markup.heading.6"] = { fg = ink[2], bold = true },
	["@markup.strong"] = { fg = ink[1], bold = true },
	["@markup.italic"] = { italic = true },
	["@markup.strikethrough"] = { strikethrough = true },
	["@markup.underline"] = { underline = true },
	["@markup.quote"] = { fg = ink[2], italic = true },
	["@markup.math"] = { fg = code.number },
	["@markup.link"] = { fg = ansi.blue },
	["@markup.link.label"] = { fg = code.call },
	["@markup.link.url"] = { fg = ansi.blue, underline = true },
	["@markup.raw"] = { fg = code.string },
	["@markup.raw.block"] = { fg = code.string },
	["@markup.list"] = { fg = acc.base },
	["@markup.list.checked"] = { fg = st.ok },
	["@markup.list.unchecked"] = { fg = ink[3] },

	["@diff.plus"] = { fg = st.ok },
	["@diff.minus"] = { fg = acc.base },
	["@diff.delta"] = { fg = st.warn },

	-- ── LSP semantic tokens ──────────────────────────────────────────────
	-- Semantic tokens arrive after treesitter and win, so anywhere the two
	-- disagree the mapping has to be repeated here or the theme silently
	-- reverts to the default for that token.
	["@lsp.type.class"] = { fg = type_user },
	["@lsp.type.struct"] = { fg = type_user },
	["@lsp.type.enum"] = { fg = type_user },
	["@lsp.type.interface"] = { fg = type_user },
	["@lsp.type.type"] = { fg = type_user },
	["@lsp.type.typeParameter"] = { fg = code.type },
	["@lsp.type.builtinType"] = { fg = code.type },
	["@lsp.type.namespace"] = { fg = ink[2] },
	["@lsp.type.enumMember"] = { fg = code.number },
	["@lsp.type.property"] = { fg = ink[1] },
	["@lsp.type.variable"] = { fg = ink[1] },
	["@lsp.type.parameter"] = { fg = ink[1] },
	-- A bare `function` token is a *reference* -- i.e. a call. The definition
	-- site is the one that carries `declaration`/`definition` modifiers, and
	-- typemod groups outrank type groups, so the specific case is handled
	-- below. Getting this backwards collapses every call into the definition
	-- colour and flattens the whole buffer.
	["@lsp.type.function"] = { fg = code.call },
	["@lsp.type.method"] = { fg = code.call },
	["@lsp.typemod.function.declaration"] = { fg = ink[1], bold = true },
	["@lsp.typemod.function.definition"] = { fg = ink[1], bold = true },
	["@lsp.typemod.method.declaration"] = { fg = ink[1], bold = true },
	["@lsp.typemod.method.definition"] = { fg = ink[1], bold = true },
	-- Deliberately empty, so treesitter's finer captures win.
	--
	-- clangd reports `type=macro mods=[globalScope]` for every one of
	-- `true`, `false`, `NULL`, a #define'd constant and a function-like
	-- macro -- they are indistinguishable at the LSP layer, so any colour
	-- chosen here is wrong for most of them. Treesitter separates them
	-- properly: @boolean, @constant.builtin, @constant and @function.call.
	["@lsp.type.macro"] = {},
	["@lsp.type.keyword"] = { fg = acc.base },
	["@lsp.type.comment"] = { fg = cmt, italic = true },
	["@lsp.type.string"] = { fg = code.string },
	["@lsp.type.number"] = { fg = code.number },
	["@lsp.type.operator"] = { fg = ink[3] },
	["@lsp.type.decorator"] = { fg = acc.base },
	["@lsp.type.lifetime"] = { fg = ink[2], italic = true },
	["@lsp.type.selfKeyword"] = { fg = ink[1], italic = true },
	["@lsp.mod.deprecated"] = { strikethrough = true },
	-- A call site is purple regardless of what it resolves to.
	["@lsp.typemod.function.call"] = { fg = code.call },
	["@lsp.typemod.method.call"] = { fg = code.call },
	["@lsp.typemod.function.defaultLibrary"] = { fg = call_builtin },
	["@lsp.typemod.variable.defaultLibrary"] = { fg = ink[1], italic = true },

	-- ── diagnostics ──────────────────────────────────────────────────────
	-- Error stays the doc's rose-crimson here and is NOT the tweaked
	-- vermilion used in btop and zsh. In a buffer the accent is already
	-- doing full-time work on every keyword, so an accent-coloured error
	-- would be invisible in exactly the place it matters most.
	DiagnosticError = { fg = st.error },
	DiagnosticWarn = { fg = st.warn },
	DiagnosticInfo = { fg = ansi.blue },
	DiagnosticHint = { fg = ink[3] },
	DiagnosticOk = { fg = st.ok },

	DiagnosticVirtualTextError = { fg = st.error, bg = tint.error_13 , italic = true },
	DiagnosticVirtualTextWarn = { fg = st.warn, bg = tint.warn_10 , italic = true },
	DiagnosticVirtualTextInfo = { fg = ansi.blue , italic = true },
	DiagnosticVirtualTextHint = { fg = ink[3] , italic = true },
	DiagnosticVirtualTextOk = { fg = st.ok , italic = true },

	DiagnosticUnderlineError = { sp = st.error, undercurl = true },
	DiagnosticUnderlineWarn = { sp = st.warn, undercurl = true },
	DiagnosticUnderlineInfo = { sp = ansi.blue, undercurl = true },
	DiagnosticUnderlineHint = { sp = ink[3], undercurl = true },
	DiagnosticUnderlineOk = { sp = st.ok, undercurl = true },

	DiagnosticFloatingError = { fg = st.error },
	DiagnosticFloatingWarn = { fg = st.warn },
	DiagnosticFloatingInfo = { fg = ansi.blue },
	DiagnosticFloatingHint = { fg = ink[3] },
	DiagnosticFloatingOk = { fg = st.ok },

	DiagnosticSignError = { fg = st.error },
	DiagnosticSignWarn = { fg = st.warn },
	DiagnosticSignInfo = { fg = ansi.blue },
	DiagnosticSignHint = { fg = ink[3] },
	DiagnosticSignOk = { fg = st.ok },

	DiagnosticDeprecated = { sp = ink[3], strikethrough = true },
	DiagnosticUnnecessary = { fg = ink[3] },

	-- ── LSP ──────────────────────────────────────────────────────────────
	LspReferenceText = { bg = surf.sel },
	LspReferenceRead = { bg = surf.sel },
	LspReferenceWrite = { bg = surf.sel, underline = true },
	LspSignatureActiveParameter = { fg = acc.base, bold = true },
	LspInlayHint = { fg = code.type, bg = bg_float, italic = true },
	LspCodeLens = { fg = ink[3], italic = true },
	LspInfoBorder = { fg = surf.rule },

	-- ── health / misc builtins ───────────────────────────────────────────
	healthError = { fg = st.error },
	healthWarning = { fg = st.warn },
	healthSuccess = { fg = st.ok },
	NvimInternalError = { fg = st.error },
	debugPC = { bg = surf.sel },
	debugBreakpoint = { fg = st.error },
}

for group, spec in pairs(hl) do
	vim.api.nvim_set_hl(0, group, spec)
end

-- Diagnostic signs, matching the doc's gutter marks (:663).
vim.diagnostic.config({
	signs = {
		text = {
			[vim.diagnostic.severity.ERROR] = "✕",
			[vim.diagnostic.severity.WARN] = "▲",
			[vim.diagnostic.severity.INFO] = "ⓘ",
			[vim.diagnostic.severity.HINT] = "·",
		},
	},
})

-- :terminal inherits the alacritty palette, so a shell inside neovim looks
-- like a shell outside it.
vim.g.terminal_color_0 = ansi.br_black
vim.g.terminal_color_1 = acc.base
vim.g.terminal_color_2 = st.ok
vim.g.terminal_color_3 = st.warn
vim.g.terminal_color_4 = ansi.blue
vim.g.terminal_color_5 = ansi.magenta
vim.g.terminal_color_6 = ansi.cyan
vim.g.terminal_color_7 = ink[2]
vim.g.terminal_color_8 = ink[3]
vim.g.terminal_color_9 = ansi.br_red
vim.g.terminal_color_10 = ansi.br_green
vim.g.terminal_color_11 = ansi.br_yellow
vim.g.terminal_color_12 = ansi.br_blue
vim.g.terminal_color_13 = ansi.br_magenta
vim.g.terminal_color_14 = ansi.br_cyan
vim.g.terminal_color_15 = ink[1]
