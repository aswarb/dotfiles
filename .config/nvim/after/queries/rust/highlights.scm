; extends

; `break` and `continue` leave the block, like `return`; `for`/`while`/`loop`
; only shape it. Rust captures all of them as @keyword.repeat, so split here.

(break_expression "break" @keyword.return)
(continue_expression "continue" @keyword.return)
