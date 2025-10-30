require("utils")

local function is_typescript_file()
  local bufnr = vim.api.nvim_get_current_buf()
  local ft = vim.bo[bufnr].filetype
  return ft == "typescript" or ft == "typescriptreact"
end

local function goto_typescript_implementation()
  if not is_typescript_file() then
    vim.notify("GoToSource is only for TypeScript buffers", vim.log.levels.WARN)
    return
  end

  local bufnr = vim.api.nvim_get_current_buf()
  local params = {
    command = "_typescript.goToSourceDefinition",
    arguments = {
      vim.uri_from_bufnr(bufnr),
      vim.lsp.util.make_position_params(0, "utf-8").position,
    },
  }

  vim.lsp.buf_request(bufnr, "workspace/executeCommand", params, function(err, result)
    if err then
      vim.notify(("GoToSource LSP error: %s"):format(err.message or err), vim.log.levels.ERROR)
      return
     end
    if not result or vim.tbl_isempty(result) then
      vim.notify("No source definition found", vim.log.levels.INFO)
      return
    end

    if #result > 1 then
      vim.fn.setqflist(vim.lsp.util.locations_to_items(result, "utf-8"))
      vim.cmd("copen")
    end
    vim.lsp.util.show_document(result[1], "utf-8", { focus = true })
  end)
end

vim.g.mapleader = " "
vim.keymap.set("n", "<leader>n", ":bn<CR>", { silent = true })
vim.keymap.set("n", "<leader>a", "<C-6>", { silent = true })
vim.keymap.set("n", "<leader>h", ":noh<CR>", { silent = true })
vim.keymap.set("n", "<leader>r", vim.lsp.buf.rename, { silent = true })
vim.keymap.set("n", "<leader>o", ":Oil<CR>", { silent = true })
vim.keymap.set("n", "<leader>p", ":EslintFixAll<CR>", { silent = true })

vim.keymap.set("n", "<leader>w", function ()
  vim.cmd("source $MYVIMRC")
  vim.api.nvim_echo({
    {'[', '@markup.list.unchecked'},
    {'info', '@field'},
    {'] ', '@markup.list.unchecked'},
    {'config reloaded', 'AreaMsg'},
  }, false, {})
end, { silent = true })

vim.keymap.set("n", "<leader>c", function ()
  local current_buffer = vim.api.nvim_buf_get_name(0)
  if string.starts(current_buffer, "term") then
    vim.cmd("bd!")
  else
    vim.cmd("bd")
  end
end, { silent = true })

vim.keymap.set("n", "<leader>g", function ()
  local buffers = vim.api.nvim_list_bufs()
  for _, bufnr in ipairs(buffers) do
    local name = vim.api.nvim_buf_get_name(bufnr)
    if string.starts(name, "term") and string.ends(name, "lazygit") then
      vim.cmd("buffer " .. name)
      return
    end
  end
  vim.cmd("terminal lazygit")
end, { silent = true })

vim.keymap.set("n", "<leader>t", function ()
  local buffers = vim.api.nvim_list_bufs()
  for _, bufnr in ipairs(buffers) do
    local name = vim.api.nvim_buf_get_name(bufnr)
    if string.starts(name, "term") and not string.ends(name, "lazygit") then
      vim.cmd("buffer " .. name)
      return
    end
  end
  vim.cmd("terminal")
end, { silent = true })

local ivy_theme = require('telescope.themes')
    .get_ivy({ previewer = false })
local builtin = require('telescope.builtin')

vim.keymap.set("n", "<leader>f", function ()
    builtin.find_files(ivy_theme)
end, { silent = true })
vim.keymap.set("n", "<leader>e", function ()
    vim.diagnostic.open_float({ "line" })
end, { silent = true })

vim.keymap.set("n", "<leader>b", function ()
    builtin.buffers(ivy_theme)
end, { silent = true })
vim.keymap.set("n", "<leader>s", function ()
    builtin.live_grep(ivy_theme)
end, { silent = true })
vim.keymap.set("n", "<leader>d", function ()
    builtin.diagnostics(ivy_theme)
end, { silent = true })

vim.keymap.set("n", "<leader>u", function ()
    vim.lsp.buf.references()
end, { silent = true })

local dropdown_theme = require('telescope.themes')
    .get_dropdown()
vim.keymap.set("n", "gd", function ()
    -- dropdown_theme.winnr = vim.api.nvim_get_current_win()
    -- builtin.lsp_definitions(dropdown_theme)
    vim.lsp.buf.definition()
end, { silent = true })
vim.keymap.set("n", "gi", function ()
  if is_typescript_file() and false then
    goto_typescript_implementation()
  else
    dropdown_theme.winnr = vim.api.nvim_get_current_win()
    builtin.lsp_implementations(dropdown_theme)
  end
end, { silent = true })

vim.keymap.set("n", "K", function ()
    vim.lsp.buf.hover({ border = "rounded" })
end, { silent = true })

