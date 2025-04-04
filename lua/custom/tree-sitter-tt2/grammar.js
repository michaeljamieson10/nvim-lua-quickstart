module.exports = grammar({
  name: 'tt2',

  rules: {
    source_file: $ => repeat($._statement),

    _statement: $ => choice(
      $.if_statement,
      $.for_statement,
      $.block_statement,
      $.variable_reference,
      $.template_tag,
      $.other_text,
    ),

    if_statement: $ => seq(
      'IF', field('condition', $.expression), ';',
      repeat($._statement),
      'END', ';'
    ),

    for_statement: $ => seq(
      'FOR', field('item', $.variable_reference), 'IN', field('list', $.expression), ';',
      repeat($._statement),
      'END', ';'
    ),

    block_statement: $ => seq(
      'BLOCK', field('block_name', $.identifier), ';',
      repeat($._statement),
      'END', ';'
    ),

    variable_reference: $ => /\$[a-zA-Z_][a-zA-Z0-9_]*/,

    expression: $ => /[^;]+/,

    identifier: $ => /[a-zA-Z_][a-zA-Z0-9_]*/,

    template_tag: $ => seq(
      '[%-',
      optional($.expression),
      '-%]'
    ),

    other_text: $ => /[^\[\]]+/,
  }
});

