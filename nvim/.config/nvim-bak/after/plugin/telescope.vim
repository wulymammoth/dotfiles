autocmd User TelescopePreviewerLoaded setlocal wrap

" find files using telescope command-line sugar.
nnoremap <leader>f/ <cmd>Telescope grep_string<cr>

" find buffer
nnoremap <leader>fb :Telescope buffers {sort_mru=true, ignore_current_buffer=true}<cr>
nnoremap <leader>ff <cmd>Telescope find_files<cr>

" live grep
nnoremap <leader>fg :lua require('telescope').extensions.live_grep_args.live_grep_args()<cr>

" open grep
nnoremap <leader>og :lua require('telescope.builtin').live_grep({grep_open_files=true})<cr>

" find (help)
nnoremap <leader>fh <cmd>Telescope help_tags<cr>

" find (last)
nnoremap <leader>fl <cmd>Telescope resume<cr>

" find previously opened files
nnoremap <leader>fo <cmd>Telescope oldfiles<cr>

" find all
nnoremap <leader>pf <cmd>Telescope git_files<cr>
