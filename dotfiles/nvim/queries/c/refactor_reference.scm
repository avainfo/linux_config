; Local override for refactoring.nvim pinned at 3c87abd5b1786cb0cf4810ac435211fac52a4a35.
; The upstream C refactor_reference query incorrectly nests field_expression
; directly under declaration. C declarators cannot have that shape, so
; Tree-sitter rejects the entire query with "Impossible pattern" (line 41).
; Keep this as a full replacement, NOT an extension.

(parameter_declaration
  type: (_) @_type
  declarator: (identifier) @reference.identifier
  (#set-type! c @_type @reference.identifier)
  (#set! reference_type write)
  (#set! declaration true))

; int foo = 1;
(declaration
  .
  type: (_) @_type
  .
  declarator: (init_declarator
    declarator: (_) @reference.identifier)
  .
  (","
    declarator: (init_declarator
      declarator: (_) @reference.identifier))*
  (#set-type! c @_type @reference.identifier)
  (#set! reference_type write)
  (#set! declaration true))

; int foo;
(declaration
  .
  type: (_) @_type
  .
  (identifier) @reference.identifier
  .
  (","
    (identifier) @reference.identifier)*
  (#set-type! c @_type @reference.identifier)
  (#set! reference_type write)
  (#set! declaration true))

(binary_expression
  (identifier) @reference.identifier
  (#set! reference_type read))

(binary_expression
  (field_expression) @reference.identifier
  (#set! reference_type read)
  (#set! field true))

(update_expression
  (identifier) @reference.identifier
  (#set! reference_type write))

(update_expression
  (field_expression) @reference.identifier
  (#set! reference_type write)
  (#set! field true))

(assignment_expression
  left: (identifier) @reference.identifier
  (#set! reference_type write))

(assignment_expression
  left: (field_expression) @reference.identifier
  (#set! reference_type write)
  (#set! field true))

(assignment_expression
  right: (identifier) @reference.identifier
  (#set! reference_type read))

(assignment_expression
  right: (field_expression) @reference.identifier
  (#set! reference_type read)
  (#set! field true))

(argument_list
  (identifier) @reference.identifier
  (#set! reference_type read))

(argument_list
  (field_expression) @reference.identifier
  (#set! reference_type read)
  (#set! field true))

(return_statement
  (identifier) @reference.identifier
  (#set! reference_type read))

(return_statement
  (field_expression) @reference.identifier
  (#set! reference_type read)
  (#set! field true))

(call_expression
  (identifier) @reference.identifier
  (#set! reference_type read)
  (#set! function_call_identifier true))

(call_expression
  (field_expression) @reference.identifier
  (#set! reference_type read)
  (#set! field true)
  (#set! function_call_identifier true))

(function_definition
  declarator: (function_declarator
    declarator: (identifier) @reference.identifier)
  (#set! declaration true)
  (#set! reference_type write))
