local lsp = require("lsp-zero")

lsp.preset("recommended")

lsp.ensure_installed({
  'tsserver',
  'rust_analyzer',
  'clangd',
})

-- Fix Undefined global 'vim'
lsp.configure('lua-language-server', {
    settings = {
        Lua = {
            diagnostics = {
                globals = { 'vim' }
            }
        }
    }
})



lsp.on_attach(function(client, bufnr)
  lsp.default_keymaps({buffer = bufnr})
end)

lsp.setup()
local cmp = require('cmp')
local cmp_short_name = {
    nvim_lsp = '[LSP]',
    nvim_lua = '[nvim]'
}
cmp.setup({
    preselect = 'none',
    completion = {
        completeopt = 'menu,menuone,noinsert,noselect'
    },
    formatting = {
        fields = {'abbr', 'menu', 'kind'},
        format = function(entry, item)
            item.menu = cmp_short_name[entry.source.name] or entry.source.name
            item.abbr = string.sub(item.abbr, 1, 30)
            return item
        end,
    }
})
-- local cmp_select = {behavior = cmp.SelectBehavior.Select}

vim.diagnostic.config({
    virtual_text = true
})
