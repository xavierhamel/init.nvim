---- PLUGINS ----
require("config.lazy")
require("lsp")

-- External dependencies:
--  ripgrep
--  git (for statusline)

local opt = vim.opt
local api = vim.api

opt.compatible = false     -- disable compatibility with vi
opt.hidden = true          -- opening new file hides current instead of closing
opt.wrap = false           -- switch off line wrapping
opt.tabstop = 4            -- Set tabs to 4 characaters wide
opt.shiftwidth = 4         -- Set indentation width to match tab
-- opt.softtabstop = 4        -- Set the soft tab to match the hard tab width
opt.expandtab = true       -- Use spaces instead of actual hard tabs
opt.autoindent = true      -- Enable basic auto indentation
opt.copyindent = true      -- Preserve manual indentation
opt.smartindent = true     -- indent correctly when pressing return
opt.smarttab = true        -- better tab handling
opt.number = true          -- show numbers
opt.relativenumber = true  -- show relatives numbers
opt.shiftround = true      -- Round indentation to a multiple
opt.ignorecase = true      -- ignore case when searching
opt.smartcase = true       -- override ignorecase when capital letter in search
opt.hlsearch = true
opt.incsearch = true       -- show search pattern as the search is being typed
opt.history = 1000
opt.undolevels = 1000
opt.wildmenu = true        -- better completion
opt.list = true            -- show some invisible chars
opt.title = true           -- set the title of the window
opt.cursorline = true      -- highlight the cursor line
opt.colorcolumn = '100'    -- different color used for the specified column
opt.path:append('**')
opt.termguicolors = true   -- use all colors
opt.signcolumn = 'yes'     -- always show the sign column (first column)
opt.scrolloff = 5          -- scroll offset when getting at the bottom or top
opt.pumheight = 15         -- maximum autocomplete window height

---- COLORSCHEME ----
require("gruvbox").setup({
  terminal_colors = true, -- add neovim terminal colors
  inverse = false,
  contrast = "hard", -- can be "hard", "soft" or empty string
  overrides = {
    ["@comment"] = { fg = "#fe8019" },
    ["@variable"] = { fg = "#83a598" },
    ["@module"] = { fg = "#b8bb26" },
    ["@namespace"] = { fg = "#8ec07c" }
  },
})
vim.cmd("colorscheme gruvbox")
api.nvim_set_hl(0, "NormalFloat", { bg = "#181B1C" })
api.nvim_set_hl(0, "Operator", { fg = "#ebdbb2" })

---- REMAPS ----
vim.g.mapleader = " "
vim.keymap.set("n", "<leader>a", "<C-6>", { silent = true })
vim.keymap.set("n", "<leader>h", ":noh<CR>", { silent = true })
vim.keymap.set("n", "<leader>x", ":%!xxd<CR>", { silent = true })
vim.keymap.set("n", "<leader>c", ":bd<CR>", { silent = true })
vim.keymap.set("n", "<leader>r", vim.lsp.buf.rename, { silent = true })
vim.keymap.set("n", "<leader>o", ":Oil<CR>", { silent = true })

local theme = require('telescope.themes').get_ivy({ path_display = "relative", previewer = false })
local builtin = require('telescope.builtin')
vim.keymap.set("n", "<leader>f", function ()
    builtin.find_files(theme)
end, { silent = true })
vim.keymap.set("n", "<leader>e", function ()
    builtin.find_files(theme)
end, { silent = true })
vim.keymap.set("n", "<leader>b", function ()
    builtin.buffers(theme)
end, { silent = true })
vim.keymap.set("n", "<leader>s", function ()
    builtin.live_grep(theme)
end, { silent = true })
vim.keymap.set("n", "<leader>d", function ()
    builtin.diagnostics(theme)
end, { silent = true })
vim.keymap.set("n", "<leader>u", function ()
    builtin.lsp_references(theme)
end, { silent = true })

vim.keymap.set("n", "K", function ()
    vim.lsp.buf.hover({ border = "rounded" })
end, { silent = true })


---- STATUSLINE ----
local function get_hl_color(group_name, attr)
    local hl = vim.api.nvim_get_hl(0, { name = group_name })
    if hl["link"] ~= nil then
        return get_hl_color(hl["link"], attr)
    end
    if hl[attr] then
        return string.format("#%06x", hl[attr])
    else
        return nil
    end
end

local statusline = { right = "", left = "" }
api.nvim_set_hl(0, "StatusLightBg", { bg = "#3c3836" })
api.nvim_set_hl(0, "StatusDarkBg", { bg = "#121414", fg="#7A726E" })
api.nvim_set_hl(0, "StatusLightFg", { fg="#fbf1c7", bg="#3c3836" })
api.nvim_set_hl(0, "StatusDarkFg", { fg="#A19A7F", bg="#3c3836" })
for _, v in ipairs({ "Error", "Warn", "Info" }) do
    api.nvim_set_hl(0, "StatusLine" .. v, {
        fg = get_hl_color("Diagnostic" .. v, "fg"),
        bg = "#3c3836",
        bold = true
    })
end

-- getting the curent git branch, when no branch is found, return an empty
-- string
function statusline.git_branch()
    local branch = vim.fn.system("git branch --show-current")
    if string.sub(branch, 1, 5) == "fatal" then
        return ""
    end
    return "git:" .. string.sub(branch, 1, #branch - 1)
end
-- display diagnosis returned by the lsp
function statusline.diagnosis()
    local errors = vim.diagnostic.get(0, { severity = vim.diagnostic.severity.ERROR })
    local warnings = vim.diagnostic.get(0, { severity = vim.diagnostic.severity.WARN })
    local infos = vim.diagnostic.get(0, { severity = vim.diagnostic.severity.INFO })
    local diagnosis = {#errors, #warnings, #infos}
    local symbols = {" %#StatusLineError# ✕ ", " %#StatusLineWarn#  ", " %#StatusLineInfo# i "}
    local out = ""
    for i = 1, 3, 1 do
        if diagnosis[i] > 0 then
            out = out .. symbols[i] .. diagnosis[i]
        end
    end
    return "" .. out .. ""
end

function statusline.static_build()
    local dark_bg = "%#StatusDarkBg#"
    local light_bg = "%#StatusLightFg#"
    statusline.left = string.format("%s %s %s %s",
        dark_bg, statusline.git_branch(), light_bg, "%f", "%m")
    statusline.right = string.format("%s %s %s %s %s ",
        "%=", "%y", dark_bg, "%l:%c", light_bg)
end
function statusline.dynamic_build()
    return string.format(
        "%%#StatusDarkFg#%s %%#StatusLightFg#", statusline.diagnosis())
end
-- format the statusline
function statusline.build()
    return table.concat({
        statusline.left,
        statusline.dynamic_build(),
        statusline.right,
    }, " ")
end
statusline.static_build()
-- update the statusline every 3s
local timer = vim.loop.new_timer()
timer:start(0, 1500, vim.schedule_wrap(function()
    opt.statusline = statusline.build()
    vim.cmd "redrawstatus"
end))

