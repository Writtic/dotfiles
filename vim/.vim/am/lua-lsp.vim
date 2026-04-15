" nvim-only LSP + completion setup. Sourced from .vimrc after lua-setup.vim.
" Deoplete / ALE / tern were removed; this wires up the replacement stack.

if !has('nvim')
  finish
endif

lua << EOF

-- Mason: manage LSP servers / formatters / linters from inside nvim --------
local ok_mason, mason = pcall(require, 'mason')
if ok_mason then
  mason.setup()
end

local ok_mlsp, mason_lsp = pcall(require, 'mason-lspconfig')
if ok_mlsp then
  mason_lsp.setup({
    ensure_installed = { 'lua_ls', 'gopls', 'ts_ls', 'pyright', 'rust_analyzer' },
    automatic_installation = false,
  })
end

-- nvim-cmp -----------------------------------------------------------------
local ok_cmp, cmp = pcall(require, 'cmp')
if ok_cmp then
  cmp.setup({
    snippet = {
      expand = function(args)
        vim.fn['UltiSnips#Anon'](args.body)
      end,
    },
    mapping = cmp.mapping.preset.insert({
      ['<C-n>']     = cmp.mapping.select_next_item(),
      ['<C-p>']     = cmp.mapping.select_prev_item(),
      ['<C-b>']     = cmp.mapping.scroll_docs(-4),
      ['<C-f>']     = cmp.mapping.scroll_docs(4),
      ['<C-Space>'] = cmp.mapping.complete(),
      ['<C-e>']     = cmp.mapping.abort(),
      ['<CR>']      = cmp.mapping.confirm({ select = false }),
    }),
    sources = cmp.config.sources({
      { name = 'nvim_lsp' },
      { name = 'ultisnips' },
      { name = 'buffer'  },
      { name = 'path'    },
    }),
  })
end

-- nvim-lspconfig -----------------------------------------------------------
local ok_lsp, lspconfig = pcall(require, 'lspconfig')
if ok_lsp then
  local capabilities = vim.lsp.protocol.make_client_capabilities()
  local ok_cmp_lsp, cmp_lsp = pcall(require, 'cmp_nvim_lsp')
  if ok_cmp_lsp then
    capabilities = cmp_lsp.default_capabilities(capabilities)
  end

  local on_attach = function(_, bufnr)
    local opts = { buffer = bufnr, silent = true }
    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
    vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
    vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
    vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
    vim.keymap.set('n', 'K',  vim.lsp.buf.hover,      opts)
    vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts)
    vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, opts)
    vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, opts)
    vim.keymap.set('n', ']d', vim.diagnostic.goto_next, opts)
    vim.keymap.set('n', '<leader>f', function() vim.lsp.buf.format({ async = true }) end, opts)
  end

  for _, server in ipairs({ 'lua_ls', 'gopls', 'ts_ls', 'pyright', 'rust_analyzer' }) do
    if lspconfig[server] then
      lspconfig[server].setup({
        capabilities = capabilities,
        on_attach    = on_attach,
      })
    end
  end

  -- Diagnostic presentation
  vim.diagnostic.config({
    virtual_text = { spacing = 2, prefix = '●' },
    signs = true,
    underline = true,
    update_in_insert = false,
    severity_sort = true,
  })
end

-- none-ls (formatters / linters that are not LSP servers) ------------------
local ok_null, null_ls = pcall(require, 'null-ls')
if ok_null then
  null_ls.setup({
    sources = {
      -- Examples; enable as tools become available in PATH.
      -- null_ls.builtins.formatting.prettier,
      -- null_ls.builtins.formatting.stylua,
      -- null_ls.builtins.diagnostics.eslint_d,
      -- null_ls.builtins.diagnostics.shellcheck,
    },
  })
end

EOF
