---@diagnostic disable: unused-local
return {
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPost" },
    cmd = { "LspInfo", "LspInstall", "LspUninstall", "Mason" },
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",

      "hrsh7th/cmp-nvim-lsp",
      "nvimtools/none-ls.nvim",

      "folke/neodev.nvim",

      { "j-hui/fidget.nvim", tag = "legacy" },
    },
    config = function()
      local null_ls = require("null-ls")

      require("neodev").setup()

      require("mason").setup({
        ui = {
          border = "rounded",
        },
      })

      require("mason-lspconfig").setup({
        automatic_installation = { exclude = {} },
      })


      local servers = {
        cssls = {},
        html = {},
        jsonls = {},
        lua_ls = {
          settings = {
            Lua = {
              workspace = { checkThirdParty = false },
              telemetry = { enabled = false },
            },
          },
        },
        tailwindcss = {},
        tsserver = {},
        zls = {},
      }

      local default_handlers = {
        ["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, { border = "rounded" }),
        ["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, { border = "rounded" }),
      }

      local capabilities = vim.lsp.protocol.make_client_capabilities()
      local default_capabilities = require("cmp_nvim_lsp").default_capabilities(capabilities)

      local on_attach = function(_client, buffer_number)
        vim.keymap.set("n", "K", vim.lsp.buf.hover, { desc = "LSP: Hover Documentation", buffer = buffer_number })
        vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, { desc = "LSP: [R]e[n]ame", buffer = buffer_number })
        vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action,
          { desc = "LSP: [C]ode [A]ction", buffer = buffer_number })
        vim.keymap.set("n", "<leader>gd", vim.lsp.buf.definition,
          { desc = "LSP: [G]oto [D]efinition", buffer = buffer_number })
        vim.keymap.set("n", "<leader>gr", vim.lsp.buf.references,
          { desc = "LSP: [G]oto [R]eferences", buffer = buffer_number })
        vim.keymap.set("n", "<leader>gf", vim.lsp.buf.format, {})
        vim.keymap.set("n", "<leader>bs", require("telescope.builtin").lsp_document_symbols,
          { desc = "LSP: [B]uffer [S]ymbols", buffer = buffer_number })
        vim.api.nvim_buf_create_user_command(buffer_number, "Format", function(_)
          vim.lsp.buf.format({
            filter = function(format_client)
              return format_client.name ~= "tsserver" or not null_ls.is_registered("prettier")
            end,
          })
        end, { desc = "LSP: Format current buffer with LSP" })
      end

      for name, config in pairs(servers) do
        require("lspconfig")[name].setup({
          capabilities = default_capabilities,
          filetypes = config.filetypes,
          handlers = vim.tbl_deep_extend("force", {}, default_handlers, config.handlers or {}),
          on_attach = on_attach,
          settings = config.settings,
        })
      end

      local formatting = null_ls.builtins.formatting
      local diagnostics = null_ls.builtins.diagnostics
      local code_actions = null_ls.builtins.code_actions

      null_ls.setup({
        border = "rounded",
        sources = {
          formatting.prettierd,
          formatting.stylua,

          -- diagnostics.eslint_d.with({
            --condition = function(utils)
              --return utils.root_has_file({ ".eslintrc.js", ".eslintrc.cjs", ".eslintrc.json" })
            --end,
          --}),

          --code_actions.eslint_d.with({
            --condition = function(utils)
              --return utils.root_has_file({ ".eslintrc.js", ".eslintrc.cjs", ".eslintrc.json" })
            --end,
          --}),
        },
      })

      require("lspconfig.ui.windows").default_options.border = "rounded"

      vim.diagnostic.config({
        float = {
          border = "rounded",
        },
      })
    end,
  },
}
