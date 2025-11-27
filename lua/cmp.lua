local CMP = {}

CMP.options = {
  -- 'default' (recommended) for mappings similar to built-in completions (C-y to accept)
  -- 'super-tab' for mappings similar to vscode (tab to accept)
  -- 'enter' for enter to accept
  -- 'none' for no mappings
  --
  -- All presets have the following mappings:
  -- C-space: Open menu or open docs if already open
  -- C-n/C-p or Up/Down: Select next/previous item
  -- C-e: Hide menu
  -- C-k: Toggle signature help (if signature.enabled = true)
  keymap = {
    preset = 'enter',
    ['<C-e>'] = { "show" },
    ['<C-j>'] = { 'select_next', 'fallback' },
    ['<C-k>'] = { 'select_prev', 'fallback' },
    ['<C-i>'] = { 'accept', 'fallback' }
  },

  appearance = {
    nerd_font_variant = 'mono'
  },

  completion = {
    -- list = {
    --   selection = {
    --     preselect = false
    --   }
    -- },
    documentation = { auto_show = false },
    menu = {
      draw = {
        columns = {
          { "kind_icon", "label", "label_description", gap = 1 },
          { "source_name" },
        },
        components = {
          label = { width = { fill = true } },
        },
      }
    }
  },

  sources = {
    default = { 'lsp', 'path', 'snippets', 'buffer' },
  },
  fuzzy = { implementation = "prefer_rust_with_warning" }
}

return CMP
