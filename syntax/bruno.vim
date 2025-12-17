if exists('b:current_syntax')
  finish
endif

syntax case ignore

syntax match brunoSection /^\s*\%(meta\|headers\|query\|script\|tests\|docs\)\>\s*{/
syntax match brunoBodySection /^\s*\%(body\|vars\)\%(:\k\+\)\?\>\s*{/
syntax match brunoHttpVerb /^\s*\%(get\|post\|put\|delete\|patch\|options\|head\|connect\|trace\)\>\s*{/

syntax match brunoKey /^\s*\zs[[:alnum:]_:-]\+\ze\s*:/
syntax region brunoString start=/"/ skip=/\\"/ end=/"/
syntax region brunoString start=/'/ skip=/\\'/ end=/'/
syntax match brunoNumber /\v<[-+]?\d+(\.\d+)?([eE][+-]?\d+)?>/
syntax keyword brunoBoolean true false null

syntax region brunoTemplate start=/{{/ end=/}}/
syntax region brunoTemplateTag start=/{%/ end=/%}/

highlight default link brunoSection Keyword
highlight default link brunoBodySection Keyword
highlight default link brunoHttpVerb Keyword
highlight default link brunoKey Identifier
highlight default link brunoString String
highlight default link brunoNumber Number
highlight default link brunoBoolean Boolean
highlight default link brunoTemplate PreProc
highlight default link brunoTemplateTag PreProc

let b:current_syntax = 'bruno'
