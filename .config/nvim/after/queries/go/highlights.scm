; extends

; Go's own query captures bare identifiers as @variable at the same default
; priority (100) as the @function captures covering the same node. Equal
; priority leaves the winner to query ordering rather than intent, and
; @variable takes it -- so function names render as data rather than callables.
;
; 101 is the smallest bump that settles it, and it is deliberately narrow:
; declaration names and call sites only, so nothing else in the language
; changes. The colours themselves stay on the language-agnostic @function /
; @function.method / @function.call groups the rest of the theme uses.

(function_declaration
  name: (identifier) @function (#set! priority 101))

(method_declaration
  name: (field_identifier) @function.method (#set! priority 101))

(call_expression
  function: (identifier) @function.call (#set! priority 101))

(call_expression
  function: (selector_expression
    field: (field_identifier) @function.method.call (#set! priority 101)))

; `break` and `continue` leave the block, like `return`; Go captures them as
; @keyword.repeat alongside `for`, so they are re-captured here to match.

(break_statement "break" @keyword.return)
(continue_statement "continue" @keyword.return)
