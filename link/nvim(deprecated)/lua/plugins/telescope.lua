return {
  {
    'nvim-telescope/telescope.nvim',
    tag = '0.1.5',
    dependencies = {
      "nvim-lua/plenary.nvim",
     -- { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
    },
    config = function()
      local actions = require("telescope.actions")

      require("telescope").setup({
        defaults = {
          mappings = {
            i = {
              ["<C-k>"] = actions.move_selection_previous,
              ["<C-j>"] = actions.move_selection_next,
            },
          },
          file_ignore_patterns = {
            "node_modules",
          },
          hidden = true,
        },
        extensions = {
          ['ui-select'] = {
            require("telescope.themes").get_dropdown {
            }
          }
        }
      })

      local builtin = require("telescope.builtin")

      vim.keymap.set('n', '<leader>ff', builtin.find_files, {})
      vim.keymap.set('n', '<leader>fg', builtin.live_grep, {})

      require("telescope").load_extension("ui-select")
      pcall(require("telescope").load_extension, "fzf")
    end
  },
  {
    "nvim-telescope/telescope-ui-select.nvim",
  }
}
