return {
	{
		"j-hui/fidget.nvim",
		-- tag = "v1.3.0",
		event = { "BufEnter" },
		config = function()
			require("fidget").setup({
				text = {
					spinner = "dots_negative",
				},
			})
		end,
	},
}
