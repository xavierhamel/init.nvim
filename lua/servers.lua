-- Lua
vim.lsp.config.lua_ls = {
    cmd = { "lua-language-server" },
    filetypes = { "lua" },
    root_markers = { ".luarc.json", ".git", vim.uv.cwd() },
    settings = {
        Lua = {
            telemetry = {
                enable = false,
            },
            diagnostics = {
                globals = { "vim" }
            }
        },
    },
}
vim.lsp.enable("lua_ls")
-- end

-- Python
vim.lsp.config.basedpyright = {
    name = "basedpyright",
    filetypes = { "python" },
    cmd = { "basedpyright-langserver", "--stdio" },
    settings = {
        python = {
            venvPath = vim.fn.expand("~") .. "/.virtualenvs",
        },
        basedpyright = {
            disableOrganizeImports = true,
            analysis = {
                autoSearchPaths = true,
                autoImportCompletions = true,
                useLibraryCodeForTypes = true,
                diagnosticMode = "openFilesOnly",
                typeCheckingMode = "strict",
                inlayHints = {
                    variableTypes = true,
                    callArgumentNames = true,
                    functionReturnTypes = true,
                    genericTypes = false,
                },
            },
        },
    },
}

vim.api.nvim_create_autocmd("FileType", {
    pattern = "python",
    callback = function()
        local ok, venv = pcall(require, "rj.extras.venv")
        if ok then
            venv.setup()
        end
        local root = vim.fs.root(0, {
            "pyproject.toml",
            "setup.py",
            "setup.cfg",
            "requirements.txt",
            "Pipfile",
            "pyrightconfig.json",
            ".git",
            vim.uv.cwd(),
        })
        local client =
        vim.lsp.start(vim.tbl_extend("force", vim.lsp.config.basedpyright, { root_dir = root }), { attach = false })
        if client then
            vim.lsp.buf_attach_client(0, client)
        end
    end,
})
-- end

-- C/C++
vim.lsp.config.clangd = {
    cmd = {
        "clangd",
        "-j=" .. 2,
        "--background-index",
        "--clang-tidy",
        "--inlay-hints",
        "--fallback-style=llvm",
        "--all-scopes-completion",
        "--completion-style=detailed",
        "--header-insertion=iwyu",
        "--header-insertion-decorators",
        "--pch-storage=memory",
    },
    filetypes = { "c", "cpp", "objc", "objcpp", "cuda", "proto" },
    root_markers = {
        "CMakeLists.txt",
        ".clangd",
        ".clang-tidy",
        ".clang-format",
        "compile_commands.json",
        "compile_flags.txt",
        "configure.ac",
        ".git",
        vim.uv.cwd(),
    },
}
vim.lsp.enable("clangd")
-- end

-- Rust
vim.lsp.config.rust_analyzer = {
    filetypes = { "rust" },
    cmd = { "rust-analyzer" },
    workspace_required = true,
    root_dir = function(buf, cb)
        local root = vim.fs.root(buf, { "Cargo.toml", "rust-project.json" })
        local out = vim.system({ "cargo", "metadata", "--no-deps", "--format-version", "1" }, { cwd = root }):wait()
        if out.code ~= 0 then
            return cb(root)
        end

        local ok, result = pcall(vim.json.decode, out.stdout)
        if ok and result.workspace_root then
            return cb(result.workspace_root)
        end

        return cb(root)
    end,
    settings = {
        autoformat = false,
        ["rust-analyzer"] = {
            check = {
                command = "clippy",
            },
        },
    },
}
vim.lsp.enable("rust_analyzer")
-- end

-- Web-dev
-- TSServer
vim.lsp.config('vtsls', {
    cmd = { "vtsls", "--stdio", "--jsx" },
    filetypes = { "javascript", "javascriptreact", "javascript.jsx", "typescript", "typescriptreact", "typescript.tsx" },
    root_markers = { ".git", "turbo.json", "tsconfig.json", "jsconfig.json", "package.json" },

    init_options = {
        hostInfo = "neovim",
    },
})
--  vim.lsp.config('ts_ls', {
--      cmd = { "typescript-language-server", "--stdio" },
--      filetypes = { "javascript", "javascriptreact", "javascript.jsx", "typescript", "typescriptreact", "typescript.tsx" },
--      root_markers = { ".git", "turbo.json", "tsconfig.json", "jsconfig.json", "package.json" },
--  
--      init_options = {
--          hostInfo = "neovim",
--      },
--  })
-- end

-- eslint
require('lua.lsp.eslint')
-- end
vim.lsp.enable({ "vtsls" })

