" Syntax highlighting for service logs
" Note: Baleia plugin handles ANSI escape code concealment
" This file only provides additional service-based coloring

if exists("b:current_syntax")
  finish
endif

" Service name highlighting - just the labels, not the whole line
" This way baleia can handle the ANSI colors and we add semantic meaning
syntax match LogConductorLabel /\[Conductor\]/
syntax match LogConductorWorkerLabel /\[Conductor Worker\]/
syntax match LogTranslatorLabel /\[Translator\]/
syntax match LogEntityResolverLabel /\[Entity Resolver\]/
syntax match LogIntegrationLabel /\[Integration Server\]/

" Define colors for service labels - Catppuccin Mocha theme
highlight LogConductorLabel ctermfg=Blue guifg=#89b4fa cterm=bold gui=bold
highlight LogConductorWorkerLabel ctermfg=Cyan guifg=#89dceb cterm=bold gui=bold
highlight LogTranslatorLabel ctermfg=Magenta guifg=#cba6f7 cterm=bold gui=bold
highlight LogEntityResolverLabel ctermfg=LightMagenta guifg=#f5c2e7 cterm=bold gui=bold
highlight LogIntegrationLabel ctermfg=Yellow guifg=#fab387 cterm=bold gui=bold

let b:current_syntax = "log"
