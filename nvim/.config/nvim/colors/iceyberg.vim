" iceyberg (adaptation by wulymammoth)

" setup
hi clear
syntax clear
set background=dark
let g:colors_name='iceyberg'

" PALETTE
"
" 0:  #22262e : black
" 1:  #e27878 : coral reef (red)
" 2:  #b4be82 : lime twist (green)
" 3:  #e2a478 : myrtle beach (orange)
" 4:  #84a0c6 : persian violet (blue)
" 5:  #a093c7 : mighty aphrodite (violet)
" 6:  #89b8c2 : passion blue
" 7:  #c6c8d1 : violet mist (gray)
" 8:  #6b7089 : silhouette (gray)
" 9:  #e98989 : flamingo's dream (red)
" 10: #c0ca8e : corn stalk (green)
" 11: #e9b189 : persian melon (orange)
" 12: #91acd1 : summer mist (blue)
" 13: #ada0d3 : heather plum (violet)
" 14: #95c4ce : blue rapids (blue)
" 15: #d2d4de : violet dusk (violet)
" 16: #161821 : trademark black
let s:colors = {
	\ -1: 'NONE',
	\ 0:  '#22262e',
	\ 1:  '#e27878',
	\ 2:  '#b4be82',
	\ 3:  '#e2a478',
	\ 4:  '#84a0c6',
	\ 5:  '#a093c7',
	\ 6:  '#89b8c2',
	\ 7:  '#c6c8d1',
	\ 8:  '#6b7089',
	\ 9:  '#e98989',
	\ 10: '#c0ca8e',
	\ 11: '#e9b189',
	\ 12: '#91acd1',
	\ 13: '#ada0d3',
	\ 14: '#95c4ce',
	\ 15: '#d2d4de',
	\ 16: '#161821'
	\ }

function! s:HL(scope, bg, fg, ...)
	exec "hi ".a:scope
	\ "ctermbg=".(a:bg < 0 || a:bg > 15 ? 'NONE' : a:bg)
	\ "ctermfg=".(a:fg < 0 || a:fg > 15 ? 'NONE' : a:fg)
	\ "cterm=".(a:0 > 0 ? a:1 : 'NONE')
	\ "gui=".(a:0 > 0 ? a:1 : 'NONE')
	\ "guibg=".s:colors[a:bg]
	\ "guifg=".s:colors[a:fg]
endfunction

let g:terminal_ansi_colors = []
for i in range(16)
	call add(g:terminal_ansi_colors, s:colors[i])
	exec 'let g:terminal_color_'.i '= s:colors['.i.']'
endfor

" editor settings
call s:HL("Normal",        16,  7)
call s:HL("Cursor",         7, 16)
call s:HL("CursorLine",     0, -1)
call s:HL("LineNr",        -1,  8)
call s:HL("CursorLineNr",  -1, 15, 'bold')

" number column
call s:HL("CursorColumn",   0, -1)
call s:HL("FoldedColumn",  -1, -1)
call s:HL("FoldColumn",    -1,  8)
call s:HL("SignColumn",    -1,  7)
call s:HL("Folded",         0,  4)

" window / tab delimeters
call s:HL("VertSplit",     -1,  0)
call s:HL("ColorColumn",    0, -1)
call s:HL("TabLine",       -1, -1)
call s:HL("TabLineFill",   -1, -1)
call s:HL("TabLineSel",     0,  4, 'bold')

" file navigation / searching
call s:HL("Directory",     -1,  4)
call s:HL("Search",        -1, -1, 'reverse')
call s:HL("IncSearch",     -1, -1, 'reverse')

" prompt / status
call s:HL("StatusLine",    -1,  7)
call s:HL("StatusLineNC",  -1,  8)
call s:HL("WildMenu",       0, 12)
call s:HL("Title",         -1,  3, 'bold')
call s:HL("Question",      -1, 12)
call s:HL("MoreMsg",       -1,  4)
call s:HL("ModeMsg",       -1,  8, 'bold')

" visual aid
call s:HL("MatchParen",    -1, -1)
call s:HL("Visual",         2,  0)
call s:HL("VisualNOS",      0, -1)
call s:HL("NonText",       -1,  8)

call s:HL("Todo",          -1,  3, 'bold')
call s:HL("Underlined",    -1, 12, 'underline')
call s:HL("Error",         -1,  1)
call s:HL("ErrorMsg",      -1,  1)
call s:HL("WarningMsg",    -1, 11)
call s:HL("Ignore",        -1,  1)
call s:HL("SpecialKey",    -1,  5)
call s:HL("Whitespace",    -1,  8)

" variable types
call s:HL("Constant",      -1,  1)
call s:HL("String",        -1,  6)
call s:HL("Character",     -1,  3)
call s:HL("Number",        -1,  5)
call s:HL("Boolean",       -1, 11)
call s:HL("Float",         -1,  5)

call s:HL("Identifier",    -1,  7)
call s:HL("Function",      -1,  1)

" language constructs
call s:HL("Comment",       -1,  8)
call s:HL("Statement",     -1,  4)
call s:HL("Conditional",   -1,  4)
call s:HL("Repeat",        -1,  4)
call s:HL("Label",         -1,  4)
call s:HL("Operator",      -1,  4)
call s:HL("Keyword",       -1,  4)
call s:HL("Exception",     -1,  1)

call s:HL("Special",       -1,  7)
call s:HL("SpecialChar",   -1,  5)
call s:HL("Tag",           -1,  4)
call s:HL("Delimiter",     -1, -1)
call s:HL("SpecialComment",-1,  5)
call s:HL("Debug",         -1,  5)

" c groups
call s:HL("PreProc",       -1,  5)
call s:HL("Include",       -1,  5)
call s:HL("Define",        -1,  3)
call s:HL("Macro",         -1,  3)
call s:HL("PreCondit",     -1,  3)

call s:HL("Type",          -1,  4)
call s:HL("StorageClass",  -1, 15)
call s:HL("Structure",     -1,  5)
call s:HL("Typedef",       -1,  5)

" diff
call s:HL("DiffAdd",       -1,  2)
call s:HL("DiffDelete",    -1,  1)
call s:HL("DiffChange",    -1,  3)
call s:HL("DiffText",      -1,  7)
hi! link diffSubname       DiffChange
hi! link diffAdded         DiffAdd
hi! link diffRemoved       DiffDelete

" completion menu
call s:HL("Pmenu",         -1, 15)
call s:HL("PmenuSel",       0, 12)
call s:HL("PmenuSbar",     -1, -1)
call s:HL("PmenuThumb",     0,  0)

" spelling
call s:HL("SpellBad",      -1,  1, 'underline')
call s:HL("SpellCap",      -1,  2, 'underline')
call s:HL("SpellLocal",    -1,  3, 'underline')
call s:HL("SpellRare",     -1,  3, 'underline')

" netrw
call s:HL("netrwClassify", -1,  7)

" sh
call s:HL("shStatement",   -1, -1)
call s:HL("shCtrlSeq",     -1,  5)
call s:HL("shFunction",    -1, -1)
call s:HL("shOption",      -1,  2)
call s:HL("shQuote",       -1,  4)
call s:HL("shDerefSimple", -1,  5)
call s:HL("shFunctionKey", -1,  3)
call s:HL("shVariable",    -1, -1)

" html
call s:HL("htmlTag",       -1,  8)
call s:HL("htmlEndTag",    -1,  8)
call s:HL("htmlArg",       -1, 13)

" statusline
call s:HL("Dark",          -1,  8)
call s:HL("Accent",        -1,  4)
