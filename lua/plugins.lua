local cmp = require("cmp")

return {
    { "ellisonleao/gruvbox.nvim" },
    {
        'nvim-telescope/telescope.nvim',
        branch = "master",
        dependencies = {
            {'nvim-lua/plenary.nvim'}
        }
    },
    {
        "nvim-treesitter/nvim-treesitter",
        lazy = false,
        build = ":TSUpdate",
        config = function()
            require('nvim-treesitter.configs').setup({
                -- A list of parser names, or "all"
                ensure_installed = { "tsx",  "typescript", "javascript", "c", "rust" },

                -- Install parsers synchronously (only applied to `ensure_installed`)
                sync_install = false,

                -- Automatically install missing parsers when entering buffer
                -- Recommendation: set to false if you don't have `tree-sitter` CLI installed locally
                auto_install = false,

                highlight = {
                    -- `false` will disable the whole extension
                    enable = true,
                    disable = {
                        'tsx'
                    },

                    -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
                    -- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
                    -- Using this option may slow down your editor, and you may see some duplicate highlights.
                    -- Instead of true it can also be a list of languages
                    additional_vim_regex_highlighting = false,
                },
                indent = {
                    enable = false
                },
            })
        end
    },
    {
        "windwp/nvim-autopairs",
        event = "InsertEnter",
        config = true
    },
    {
        "stevearc/oil.nvim",
        config = function()
            require("oil").setup()
        end
    },
    {
        'saghen/blink.cmp',
        -- dependencies = { 'rafamadriz/friendly-snippets' },
        version = '1.*',
        opts = cmp.options,
        opts_extend = { "sources.default" }
    },
    {
      'lewis6991/gitsigns.nvim',
      config = function()
        require('gitsigns').setup {
          current_line_blame = true,
          current_line_blame_formatter = '       ⏹ <author>, <author_time:%R> - <summary>',
          current_line_blame_opts = {
            virt_text = true,
            virt_text_pos = 'eol', -- 'eol' | 'overlay' | 'right_align'
            delay = 0,
            ignore_whitespace = true,
            virt_text_priority = 5000,
            use_focus = true,
          },
        }
      end
    },
    {
      'github/copilot.vim'
    }
}
