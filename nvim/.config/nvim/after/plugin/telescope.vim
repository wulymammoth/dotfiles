autocmd User TelescopePreviewerLoaded setlocal wrap

" Find files using Telescope command-line sugar.
nnoremap <leader>f/ <cmd>Telescope grep_string<cr>
nnoremap <leader>fb :Telescope buffers {sort_mru=true, ignore_current_buffer=true}<cr>
nnoremap <leader>ff <cmd>Telescope find_files<cr>
nnoremap <leader>fg :lua require('telescope').extensions.live_grep_args.live_grep_args()<cr>
nnoremap <leader>og :lua require('telescope.builtin').live_grep({grep_open_files=true})<cr>
nnoremap <leader>fh <cmd>Telescope help_tags<cr>
nnoremap <leader>fl <cmd>Telescope resume<cr>
nnoremap <leader>fo <cmd>Telescope oldfiles<cr>
nnoremap <leader>pf <cmd>Telescope git_files<cr>
