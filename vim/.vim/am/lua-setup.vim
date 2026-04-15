" nvim-only Lua setup. Sourced from .vimrc inside `if has('nvim')`.
" Keep all non-LSP Lua init here. LSP lives in lua-lsp.vim.

if !has('nvim')
  finish
endif

lua << EOF

-- gitsigns ------------------------------------------------------------------
local ok_gs, gs = pcall(require, 'gitsigns')
if ok_gs then
  gs.setup({
    signs = {
      add          = { text = '+' },
      change       = { text = '~' },
      delete       = { text = '_' },
      topdelete    = { text = '‾' },
      changedelete = { text = '~' },
    },
    signcolumn = true,
  })
end

-- lualine -------------------------------------------------------------------
local ok_ll, lualine = pcall(require, 'lualine')
if ok_ll then
  lualine.setup({
    options = {
      theme = 'onedark',
      section_separators   = { left = '', right = '' },
      component_separators = { left = '', right = '' },
      globalstatus = true,
    },
    sections = {
      lualine_a = { 'mode' },
      lualine_b = { 'branch', 'diff', 'diagnostics' },
      lualine_c = { { 'filename', path = 1 } },
      lualine_x = { 'encoding', 'fileformat', 'filetype' },
      lualine_y = { 'progress' },
      lualine_z = { 'location' },
    },
  })
end

EOF
