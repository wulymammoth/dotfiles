autocmd User TelescopePreviewerLoaded setlocal wrap

" Find files using Telescope command-line sugar.
nnoremap <leader>f/ <cmd>Telescope grep_string<cr>
nnoremap <leader>fb <cmd>Telescope buffers<cr>
nnoremap <leader>ff <cmd>Telescope find_files<cr>
nnoremap <leader>fg <cmd>:lua require('telescope').extensions.live_grep_args.live_grep_args()<cr>
nnoremap <leader>fh <cmd>Telescope help_tags<cr>
nnoremap <leader>pf <cmd>Telescope git_files<cr>
nnoremap <leader>fl <cmd>Telescope resume<cr>
