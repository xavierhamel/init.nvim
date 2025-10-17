-- External dependencies:
--  ripgrep
--  git (for statusline)

-- TODO
-- [ ] Rename term buffers in telescope (implement own buffers)
-- [ ] Improves colors of telescope viewer (files)
-- [x] Improve file structure in config (lsp)
-- [x] Add % of file down
-- [x] Add goto source typescript
-- [x] Improve :Blame
-- [o] Show package source in autocomplete
-- [ ] Improve readme
-- [x] Show completion in object (TS)
-- [ ] Add a toggle in Telescope to ignore or not .gitignore

---- PLUGINS ----
require("config.lazy")
require("lsp.lsp")
require("keymap")


local opt = vim.opt
local api = vim.api

local tabwidth = 2

opt.compatible = false     -- disable compatibility with vi
opt.hidden = true          -- opening new file hides current instead of closing
opt.wrap = false           -- switch off line wrapping
opt.tabstop = tabwidth     -- Set tabs to 4 characaters wide
opt.shiftwidth = tabwidth  -- Set indentation width to match tab
opt.softtabstop = tabwidth -- Set the soft tab to match the hard tab width
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
opt.colorcolumn = '121'    -- different color used for the specified column
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
    ["@namespace"] = { fg = "#8ec07c" },
    ["ErrorMsg"] = { fg = "#E6DFDF", bg = "#342322" },
  },
})
vim.cmd("colorscheme gruvbox")
api.nvim_set_hl(0, "NormalFloat", { bg = "#181B1C" })
api.nvim_set_hl(0, "Operator", { fg = "#ebdbb2" })

---- OPEN VS CODE AT CURRENT LOCATION ----
vim.api.nvim_create_user_command("Code", function()
    vim.fn.system("code . --goto " .. vim.api.nvim_buf_get_name(0) .. ":" .. vim.api.nvim_win_get_cursor(0)[1])
  end,
  {
    desc = "Open VS Code at current location",
    nargs = 0,
  }
)

---- SCRATCHES ----
local scratch_path = "~/Botpress/scratch/"

local function open_scratch(_date, _extension)
  local extension = "txt"
  if _extension ~= nil then
    extension = _extension
  end
  local date = os.date("%Y-%m-%d", os.time())
  if _date ~= nil then
    date = _date
  end
  vim.cmd("e " .. scratch_path .. date ..  "." .. extension)
end

vim.api.nvim_create_user_command("Scratch", function(opts)
    local args = opts.fargs
    local extension = nil
    local date = nil
    if #args > 0 then
      if #args[1] > 4 then
        date = args[2]
      else
        extension = args[1]
      end
    end
    if #args > 1 then
      date = args[2]
    end
    open_scratch(date, extension)
  end,
  {
    desc = "Scratch pad. Usage: Scracth <extension|date> <date>. Default extension is 'txt'",
    nargs = "*",
  }
)

---- GIT BLAME ----
vim.api.nvim_create_user_command("Blame", function()
    local line_no = vim.api.nvim_win_get_cursor(0)[1]
    local output = vim.fn.system("git blame --line-porcelain -L " .. line_no  .. "," .. line_no .. " " .. vim.api.nvim_buf_get_name(0))
    local timestamp = nil
    local author = nil
    local summary = nil
    for line in output:gmatch("([^\r\n]*)([\r\n]?)") do
      if string.starts(line, "summary") then
        summary = string.sub(line, #"summary ")
      end
      if string.starts(line, "author ") then
        author = string.sub(line, #"author ")
      end
      if string.starts(line, "author-time") then
        timestamp = tonumber(string.sub(line, #"author-time "))
      end
    end
    if author ~= nil and timestamp ~= nil and summary ~= nil then
      vim.api.nvim_echo({
        {os.date("%Y-%m-%d", timestamp), '@field'},
        {',', '@markup.list.unchecked'},
        {author, '@constant'},
        {',', '@markup.list.unchecked'},
        {summary, '@markup.environment'},
      }, false, {})
    end
  end,
  {
    desc = "Git Blame",
    nargs = 0,
  }
)

---- RETURN TO LAST POSITION ----
vim.api.nvim_create_autocmd("BufReadPost", {
    desc = "Auto jump to last position",
    group = vim.api.nvim_create_augroup("auto-last-position", { clear = true }),
    callback = function(args)
        local position = vim.api.nvim_buf_get_mark(args.buf, [["]])
        local winid = vim.fn.bufwinid(args.buf)
        pcall(vim.api.nvim_win_set_cursor, winid, position)
    end,
})

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
for _, v in ipairs({ "Error", "Warn", "Info", "Hint" }) do
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
    local hints = vim.diagnostic.get(0, { severity = vim.diagnostic.severity.HINT })
    local infos = vim.diagnostic.get(0, { severity = vim.diagnostic.severity.INFO })
    local diagnosis = {#errors, #warnings, #hints, #infos}
    local symbols = {
      " %#StatusLineError#  ",
      " %#StatusLineWarn#  ",
      " %#StatusLineHint#  ",
      " %#StatusLineInfo#  "
    }
    local out = ""
    for i = 1, 4, 1 do
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
        "%=", "%y", dark_bg, "%l:%c %p%%", light_bg)
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
-- update the statusline every 1.5s
local timer = vim.loop.new_timer()
timer:start(0, 1500, vim.schedule_wrap(function()
    opt.statusline = statusline.build()
    vim.cmd "redrawstatus"
end))

