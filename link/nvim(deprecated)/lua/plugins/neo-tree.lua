return {
	"nvim-neo-tree/neo-tree.nvim",
	branch = "v3.x",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-tree/nvim-web-devicons",
		"MunifTanjim/nui.nvim",
	},
	config = function()
		vim.fn.sign_define("DiagnosticSignError", { text = " ", texthl = "DiagnosticSignError" })
		vim.fn.sign_define("DiagnosticSignWarn", { text = " ", texthl = "DiagnosticSignWarn" })
		vim.fn.sign_define("DiagnosticSignInfo", { text = " ", texthl = "DiagnosticSignInfo" })
		vim.fn.sign_define("DiagnosticSignHint", { text = "󰌵", texthl = "DiagnosticSignHint" })

		require("neo-tree").setup({
			close_if_last_window = false,
			popup_border_style = "rounded",
			enable_git_status = true,
			enable_diagnostics = true,
			sort_case_insensitive = false,
			sort_function = nil,
			default_component_configs = {
				container = {
					enable_character_fade = true,
				},
				indent = {
					indent_size = 2,
					padding = 1,
					with_markers = true,
					indent_marker = "│",
					last_indent_marker = "└",
					highlight = "NeoTreeIndentMarker",
					with_expanders = nil,
					expander_collapsed = "",
					expander_expanded = "",
					expander_highlight = "NeoTreeExpander",
				},
				icon = {
					folder_closed = "",
					folder_open = "",
					folder_empty = "󰜌",
					default = "*",
					highlight = "NeoTreeFileIcon",
				},
				modified = {
					symbol = "[+]",
					highlight = "NeoTreeModified",
				},
				name = {
					trailing_slash = false,
					use_git_status_colors = true,
					highlight = "NeoTreeFileName",
				},
				git_status = {
					symbols = {
						added = "",
						modified = "",
						deleted = "✖",
						renamed = "󰁕",
						untracked = "",
						ignored = "",
						unstaged = "󰄱",
						staged = "",
						conflict = "",
					},
				},
				file_size = {
					enabled = true,
					required_width = 64,
				},
				type = {
					enabled = true,
					required_width = 122,
				},
				last_modified = {
					enabled = true,
					required_width = 88,
				},
				created = {
					enabled = true,
					required_width = 110,
				},
				symlink_target = {
					enabled = false,
				},
			},
			commands = {},
			window = {
				position = "float",
				width = 40,
				mapping_options = {
					noremap = true,
					nowait = true,
				},
				mappings = {
					["<cr>"] = "open",
					["<esc>"] = "cancel",

					["P"] = { "toggle_preview", config = { use_float = true, use_image_nvim = true } },
					["S"] = "open_split",
					["s"] = "open_vsplit",
					["c"] = "close_node",
					["C"] = "close_all_nodes",
					["a"] = {
						"add",
						config = {
							show_path = "none",
						},
					},
					["A"] = "add_directory",
					["d"] = "delete",
					["r"] = "rename",
					["m"] = "move",
					["q"] = "close_window",
					["R"] = "refresh",
					["?"] = "show_help",
					["i"] = "show_file_details",
				},
			},
			nesting_rules = {},
			filesystem = {
				filtered_items = {
					visible = true,
					hide_dotfiles = true,
					hide_gitignored = true,
					hide_hidden = true,
				},
				follow_current_file = {
					enabled = true,
					leave_dirs_open = false,
				},
				group_empty_dirs = true,
				use_libuv_file_watcher = false,
				window = {
					position = "right",
					mappings = {
						["/"] = "fuzzy_finder",
						["D"] = "fuzzy_finder_directory",
					},
					fuzzy_finder_mappings = {
						["<down>"] = "move_cursor_down",
						["<C-n>"] = "move_cursor_down",
						["<up>"] = "move_cursor_up",
						["<C-p>"] = "move_cursor_up",
					},
				},

				commands = {},
			},
			buffers = {
				follow_current_file = {
					enabled = true,
					leave_dirs_open = false,
				},
				group_empty_dirs = true,
				show_unloaded = false,
				window = {
					mappings = {
						["x"] = "buffer_delete",
					},
				},
			},
			git_status = {
				window = {
					mappings = {
						["A"] = "git_add_all",
						["gu"] = "git_unstage_file",
						["ga"] = "git_add_file",
						["gr"] = "git_revert_file",
						["gc"] = "git_commit",
						["gp"] = "git_push",
						["gg"] = "git_commit_and_push",
						["o"] = { "show_help", nowait = false, config = { title = "Order by", prefix_key = "o" } },
					},
				},
			},
		})

		vim.keymap.set("n", "<C-b>", ":Neotree toggle buffers <CR>", {})
		vim.keymap.set("n", "<C-g>", ":Neotree toggle git_status <CR>", {})
		vim.keymap.set("n", "<C-n>", ":Neotree toggle filesystem <CR>", {})
		vim.keymap.set("n", "<C-l>", "<C-w>l", {})
		vim.keymap.set("n", "<C-h>", "<C-w>h", {})
	end,
}
