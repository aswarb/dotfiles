; extends

; C captures `break` and `continue` as @keyword.repeat -- the same group as
; `for` and `while`. The theme wants them with `return` instead: those three
; leave the block, whereas a loop or a conditional only shapes it. There is no
; way to split them at the highlight-group level, so they are re-captured here.

(break_statement "break" @keyword.return)
(continue_statement "continue" @keyword.return)
