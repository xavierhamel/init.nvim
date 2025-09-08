-- Initially taken from [NTBBloodbath](https://github.com/NTBBloodbath/nvim/blob/main/lua/core/lsp.lua)
-- modified almost 80% by me

-- Diagnostics
local config = {
    signs = {
        text = {
            [vim.diagnostic.severity.ERROR] = "",
            [vim.diagnostic.severity.WARN] = "",
            [vim.diagnostic.severity.HINT] = "",
            [vim.diagnostic.severity.INFO] = "",
        },
    },
    update_in_insert = true,
    underline = true,
    severity_sort = true,
    float = {
        focusable = false,
        style = "minimal",
        border = "single",
        source = "always",
        header = "",
        prefix = "",
        suffix = "",
    },
    virtual_text = true,
    virtual_line = true,
}
vim.diagnostic.config(config)
-- end

-- Improve LSPs UI
local icons = {
    Class = " ",
    Color = " ",
    Constant = " ",
    Constructor = " ",
    Enum = " ",
    EnumMember = " ",
    Event = " ",
    Field = " ",
    File = " ",
    Folder = " ",
    Function = "󰊕 ",
    Interface = " ",
    Keyword = " ",
    Method = "ƒ ",
    Module = "󰏗 ",
    Property = " ",
    Snippet = " ",
    Struct = " ",
    Text = " ",
    Unit = " ",
    Value = " ",
    Variable = " ",
}

local completion_kinds = vim.lsp.protocol.CompletionItemKind
for i, kind in ipairs(completion_kinds) do
    completion_kinds[i] = icons[kind] and icons[kind] .. kind or kind
end
-- end

-- Lsp capabilities and on_attach
-- Here we grab default Neovim capabilities and extend them with ones we want on top
local capabilities = vim.lsp.protocol.make_client_capabilities()

capabilities.textDocument.foldingRange = {
    dynamicRegistration = true,
    lineFoldingOnly = true,
}

capabilities.textDocument.semanticTokens.multilineTokenSupport = true
capabilities.textDocument.completion.completionItem.snippetSupport = true

vim.lsp.config("*", {
    capabilities = capabilities,
    on_attach = function(client, bufnr)
        local ok, diag = pcall(require, "rj.extras.workspace-diagnostic")
        if ok then
            diag.populate_workspace_diagnostics(client, bufnr)
        end
    end,
})
-- end

-- Disable the default keybinds
for _, bind in ipairs({ "grn", "gra", "gri", "grr" }) do
    pcall(vim.keymap.del, "n", bind)
end
-- end

-- Create keybindings, commands, inlay hints and autocommands on LSP attach
vim.api.nvim_create_autocmd("LspAttach", {
    callback = function(ev)
        local bufnr = ev.buf
        local client = vim.lsp.get_client_by_id(ev.data.client_id)
        if not client then
            return
        end
        if client.server_capabilities.completionProvider then
            vim.bo[bufnr].omnifunc = "v:lua.vim.lsp.omnifunc"
        end
        if client.server_capabilities.definitionProvider then
            vim.bo[bufnr].tagfunc = "v:lua.vim.lsp.tagfunc"
        end

        -- vim.lsp.completion.enable(true, client.id, bufnr, { autotrigger = true })

        client.server_capabilities.semanticTokensProvider = nil
    end,
})

-- Servers
require("servers")

-- Start, Stop, Restart, Log commands
vim.api.nvim_create_user_command("LspStart", function()
    vim.cmd.e()
end, { desc = "Starts LSP clients in the current buffer" })

vim.api.nvim_create_user_command("LspStop", function(opts)
    for _, client in ipairs(vim.lsp.get_clients({ bufnr = 0 })) do
        if opts.args == "" or opts.args == client.name then
            client:stop(true)
            vim.notify(client.name .. ": stopped")
        end
    end
end, {
desc = "Stop all LSP clients or a specific client attached to the current buffer.",
nargs = "?",
complete = function(_, _, _)
    local clients = vim.lsp.get_clients({ bufnr = 0 })
    local client_names = {}
    for _, client in ipairs(clients) do
        table.insert(client_names, client.name)
    end
    return client_names
end,
})

vim.api.nvim_create_user_command("LspRestart", function()
    local detach_clients = {}
    for _, client in ipairs(vim.lsp.get_clients({ bufnr = 0 })) do
        client:stop(true)
        if vim.tbl_count(client.attached_buffers) > 0 then
            detach_clients[client.name] = { client, vim.lsp.get_buffers_by_client_id(client.id) }
        end
    end
    local timer = vim.uv.new_timer()
    if not timer then
        return vim.notify("Servers are stopped but havent been restarted")
    end
    timer:start(
        100,
        50,
        vim.schedule_wrap(function()
            for name, client in pairs(detach_clients) do
                local client_id = vim.lsp.start(client[1].config, { attach = false })
                if client_id then
                    for _, buf in ipairs(client[2]) do
                        vim.lsp.buf_attach_client(buf, client_id)
                    end
                    vim.notify(name .. ": restarted")
                end
                detach_clients[name] = nil
            end
            if next(detach_clients) == nil and not timer:is_closing() then
                timer:close()
            end
        end)
    )
end, {
desc = "Restart all the language client(s) attached to the current buffer",
})

vim.api.nvim_create_user_command("LspLog", function()
    vim.cmd.vsplit(vim.lsp.log.get_filename())
end, {
desc = "Get all the lsp logs",
})

vim.api.nvim_create_user_command("LspInfo", function()
    vim.cmd("silent checkhealth vim.lsp")
end, {
desc = "Get all the information about all LSP attached",
})
-- end
