; extends

; See the C query: `break`/`continue` belong with `return`, not with `for`.

(break_statement "break" @keyword.return)
(continue_statement "continue" @keyword.return)
