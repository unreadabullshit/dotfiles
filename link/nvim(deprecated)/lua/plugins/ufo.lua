return { -- UFO
	"kevinhwang91/nvim-ufo",
	dependencies = "kevinhwang91/promise-async",
	init = function()
		vim.opt.foldlevel = 99
		vim.opt.foldcolumn = "1"
		vim.opt.foldlevelstart = 99
		vim.opt.foldenable = true

		vim.keymap.set("n", "zO", require("ufo").openAllFolds)
		vim.keymap.set("n", "zC", require("ufo").closeAllFolds)
	end,
	opts = {
		provider_selector = function(_, _, _)
			return { "treesitter", "indent" }
		end,
	},
}
