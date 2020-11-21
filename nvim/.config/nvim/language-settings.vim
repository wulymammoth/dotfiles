" c
autocmd FileType c setl tabstop=8 shiftwidth=4 softtabstop=4 noexpandtab

" crontab
autocmd FileType crontab setlocal nobackup nowritebackup

" golang
autocmd BufNewFile,BufRead *.go setlocal noet ts=4 sw=4 sts=4

" make
autocmd FileType make set noexpandtab

" markdown
autocmd filetype markdown,md set spell spelllang=en_us

" python
autocmd Filetype python inoremap # X<C-h>#
let g:python2_host_prog = expand('~/.asdf/shims/python')
let g:python3_host_prog = expand('~/.asdf/shims/python')

" ruby
let g:ruby_host_prog = expand('~/.asdf/shims/ruby')
