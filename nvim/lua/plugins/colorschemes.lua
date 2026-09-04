return {
	{
		"navarasu/onedark.nvim",
		lazy = false,
	},
	{
		"catppuccin/nvim",
		name = "catppuccin",
	},

	{
		"https://github.com/vague-theme/vague.nvim",
		opts = {
			transparent = true,
		},
	},

	{
		"rose-pine/neovim",
		name = "rose-pine",
		config = function()
			require("rose-pine").setup({
				styles = {
					italic = false,
				},
			})
		end,
	},
}
