" Syntax highlighting for service logs
if exists("b:current_syntax")
  finish
endif

" Hide ANSI escape codes
syntax match AnsiEscape /\%x1b\[[0-9;]*m/ conceal

" Entire line highlighting based on service (with ANSI code concealment)
syntax match LogConductorLine /^.*\[Conductor\].*$/ contains=AnsiEscape
syntax match LogConductorWorkerLine /^.*\[Conductor Worker\].*$/ contains=AnsiEscape
syntax match LogTranslatorLine /^.*\[Translator\].*$/ contains=AnsiEscape
syntax match LogEntityResolverLine /^.*\[Entity Resolver\].*$/ contains=AnsiEscape
syntax match LogIntegrationLine /^.*\[Integration Server\].*$/ contains=AnsiEscape

" Define colors - Catppuccin Mocha theme (entire lines)
highlight LogConductorLine ctermfg=Blue guifg=#89b4fa
highlight LogConductorWorkerLine ctermfg=Cyan guifg=#89dceb
highlight LogTranslatorLine ctermfg=Magenta guifg=#cba6f7
highlight LogEntityResolverLine ctermfg=LightMagenta guifg=#f5c2e7
highlight LogIntegrationLine ctermfg=Yellow guifg=#fab387

let b:current_syntax = "log"
