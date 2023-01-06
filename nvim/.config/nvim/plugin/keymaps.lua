-- visual selection search
-- https://www.reddit.com/r/neovim/comments/zy3qq0/til_search_within_visual_selection/?utm_source=share&utm_medium=ios_app&utm_name=iossmf
vim.keymap.set('x', '/', '<Esc>/\\%V')
