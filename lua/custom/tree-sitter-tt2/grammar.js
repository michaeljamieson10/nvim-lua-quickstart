module.exports = grammar({
  name: 'tt2',

  extras: $ => [
    /\s/,
    $.comment,
  ],

  conflicts: $ => [
    [$.block, $.end],
    [$.foreach, $.end],
    [$.if_statement, $.end],
    [$.switch_statement, $.end],
    [$.wrapper, $.end],
    [$.case_clause, $.switch_statement],
    [$.perl_block, $.end],
    [$.case_clause],
    [$.field_access, $.variable],
    [$.expression, $.array],
    [$.if_statement, $.elsif_clause],
    [$.if_statement, $.else_clause],
[$.elsif_clause, $.else_clause],
  [$.elsif_clause],                 // Important (NEW)
  [$.else_clause],                 // Important (NEW)

  ],

  rules: {
    source_file: $ => repeat($._node),

    _node: $ => choice(
      $.block,
      $.call,
      $.default,
      $.end,
      $.foreach,
      $.get,
      $.if_statement,
      $.insert,
      $.include,
      $.macro,
      $.process,
      $.set,
      $.switch_statement,
      $.use,
      $.wrapper,
      $.perl_block,
      $.outline_statement,
      $.template_tag,
      $.comment,
      $.text,
    ),

    comment: $ => token(seq('#', /.*/)),

    text: $ => /[^\[%]+/,

    template_tag: $ => seq(
      '[%',
      optional(choice('-', '+', '=', '~')),
      optional($.expression),
      '%]'
    ),

    block: $ => seq(
      '[%', optional(choice('-', '+', '=', '~')), 'BLOCK', field('name', $.identifier), '%]',
      repeat($._node),
      '[%', optional(choice('-', '+', '=', '~')), 'END', '%]'
    ),

    call: $ => seq('[%', optional(choice('-', '+', '=', '~')), 'CALL', $.expression, '%]'),

    default: $ => seq('[%', optional(choice('-', '+', '=', '~')), 'DEFAULT', $.expression, '%]'),

    end: $ => seq('[%', optional(choice('-', '+', '=', '~')), 'END', '%]'),

    foreach: $ => seq(
      '[%', optional(choice('-', '+', '=', '~')), choice('FOREACH', 'FOR'), $.expression, '%]',
      repeat($._node),
      '[%', optional(choice('-', '+', '=', '~')), 'END', '%]'
    ),

    get: $ => seq('[%', optional(choice('-', '+', '=', '~')), 'GET', $.expression, '%]'),

if_statement: $ => seq(
  '[%', optional(choice('-', '+', '=', '~')), 'IF', $.expression, '%]',
  repeat($._node),
  repeat($.elsif_clause),
  optional($.else_clause),
  '[%', optional(choice('-', '+', '=', '~')), 'END', '%]'
),

elsif_clause: $ => seq(
  '[%', optional(choice('-', '+', '=', '~')), 'ELSIF', $.expression, '%]',
  repeat($._node)
),

else_clause: $ => prec(1, seq(
  '[%', optional(choice('-', '+', '=', '~')), 'ELSE', '%]',
  repeat($._node)
)),


    insert: $ => seq('[%', optional(choice('-', '+', '=', '~')), 'INSERT', $.expression, '%]'),

    include: $ => seq('[%', optional(choice('-', '+', '=', '~')), 'INCLUDE', $.expression, optional($.args), '%]'),

    macro: $ => seq('[%', optional(choice('-', '+', '=', '~')), 'MACRO', $.identifier, repeat($.expression), '%]'),

    process: $ => seq('[%', optional(choice('-', '+', '=', '~')), 'PROCESS', $.expression, optional($.args), '%]'),

    set: $ => seq('[%', optional(choice('-', '+', '=', '~')), 'SET', $.expression, '%]'),

    switch_statement: $ => seq(
      '[%', optional(choice('-', '+', '=', '~')), 'SWITCH', $.expression, '%]',
      repeat($.case_clause),
      '[%', optional(choice('-', '+', '=', '~')), 'END', '%]'
    ),

    case_clause: $ => seq('[%', optional(choice('-', '+', '=', '~')), 'CASE', $.expression, '%]', repeat($._node)),

    use: $ => seq('[%', optional(choice('-', '+', '=', '~')), 'USE', $.expression, optional($.args), '%]'),

    wrapper: $ => seq(
      '[%', optional(choice('-', '+', '=', '~')), 'WRAPPER', $.expression, optional($.args), '%]',
      repeat($._node),
      '[%', optional(choice('-', '+', '=', '~')), 'END', '%]'
    ),

    perl_block: $ => seq(
      '[%', optional('RAW'), 'PERL', '%]',
      repeat($._node),
      '[%', 'END', '%]'
    ),

    outline_statement: $ => seq(
      '%%', /\s*/, choice('if', 'elsif', 'else', 'end', 'for', 'foreach', 'block', 'include', 'process', 'wrapper'), optional($.expression)
    ),

    args: $ => repeat1($.expression),

    expression: $ => choice(
      $.conditional_expression,
      $.assignment,
      $.field_access,
      $.map,
      $.array,
      $.binary_operation,
      $.function_call,
      $.pipe_expression,
      $.string,
      $.number,
      $.variable,
      $.identifier
    ),

    assignment: $ => prec.left(seq(
      field('left', $.field_access),
      '=',
      field('right', $.expression)
    )),

    conditional_expression: $ => prec.right(seq(
      $.expression,
      '?',
      $.expression,
      ':',
      $.expression
    )),

    field_access: $ => prec(2, seq(
      $.variable,
      repeat1(seq('.', $.identifier))
    )),

    pipe_expression: $ => prec(1, seq(
      $.expression,
      repeat1(seq('|', $.identifier))
    )),

    binary_operation: $ => prec.left(seq(
      $.expression,
      '_',
      $.expression
    )),

    map: $ => seq(
      '{',
      optional(commaSep1(seq($.string, choice('=', '=>'), $.expression))),
      '}'
    ),

    array: $ => seq(
      '[',
      optional(commaSep1($.expression)),
      ']'
    ),

    function_call: $ => seq(
      $.identifier,
      '(',
      optional(commaSep1($.expression)),
      ')'
    ),

    variable: $ => /\$[a-zA-Z_][a-zA-Z0-9_]*/,

    identifier: $ => /[a-zA-Z_][a-zA-Z0-9_]*/,

    string: $ => choice(
      seq('"', repeat(/[^\"]*/), '"'),
      seq("'", repeat(/[^\']*/), "'")
    ),

    number: $ => /\d+(\.\d+)?/,
  }
});

function commaSep1(rule) {
  return seq(rule, repeat(seq(',', rule)));
}

