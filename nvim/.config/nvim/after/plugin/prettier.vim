autocmd BufWritePre *.js,*.jsx,*.mjs,*.ts,*.tsx,*.css,*.scss,*.json,*.graphql,*.vue PrettierAsync
let g:prettier#autoformat             = 0
let g:prettier#config#bracket_spacing = 'true'
let g:prettier#config#print_width     = 120
let g:prettier#exec_cmd_async         = 1
