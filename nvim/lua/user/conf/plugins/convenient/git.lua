return {
	{
		"lewis6991/gitsigns.nvim",
		event = { "BufReadPre", "BufNewFile" },
		config = function()
			require("gitsigns").setup({
				signs = {
					add = { hl = "GitSignsAdd", text = "▎", numhl = "GitSignsAddNr", linehl = "GitSignsAddLn" },
					change = {
						hl = "GitSignsChange",
						text = "░",
						numhl = "GitSignsChangeNr",
						linehl = "GitSignsChangeLn",
					},
					delete = {
						hl = "GitSignsDelete",
						text = "_",
						numhl = "GitSignsDeleteNr",
						linehl = "GitSignsDeleteLn",
					},
					topdelete = {
						hl = "GitSignsDelete",
						text = "▔",
						numhl = "GitSignsDeleteNr",
						linehl = "GitSignsDeleteLn",
					},
					changedelete = {
						hl = "GitSignsChange",
						text = "▒",
						numhl = "GitSignsChangeNr",
						linehl = "GitSignsChangeLn",
					},
					untracked = { hl = "GitSignsAdd", text = "┆", numhl = "GitSignsAddNr", linehl = "GitSignsAddLn" },
				},
				on_attach = function(bufnr)
					local gitsigns = require("gitsigns")

					local function map(mode, l, r, desc, opts)
						opts = opts or { noremap = true, silent = true }
						opts.buffer = bufnr
						opts.desc = desc or ""
						vim.keymap.set(mode, l, r, opts)
					end

					-- Navigation
					map("n", "<leader>g=", function()
						if vim.wo.diff then
							vim.cmd.normal({ "<leader>g=", bang = true })
						else
							gitsigns.nav_hunk("next")
						end
					end, "Next hunk")

					map("n", "<leader>g-", function()
						if vim.wo.diff then
							vim.cmd.normal({ "<leader>g-", bang = true })
						else
							gitsigns.nav_hunk("prev")
						end
					end, "Previous hunk")

					-- Actions
					map("n", "<leader>gs", gitsigns.stage_hunk, "Stage hunk")
					map("n", "<leader>gr", gitsigns.reset_hunk, "Reset hunk")
					map("v", "<leader>gs", function()
						gitsigns.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
					end, "Stage hunk")
					map("v", "<leader>hr", function()
						gitsigns.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
					end, "Reset hunk")
					map("n", "<leader>gu", gitsigns.undo_stage_hunk, "Undo stage hunk")
					map("n", "<leader>gS", gitsigns.stage_buffer, "Stage buffer")
					map("n", "<leader>gR", gitsigns.reset_buffer, "Reset buffer")
					map("n", "<leader>gp", gitsigns.preview_hunk, "Preview hunk")
					map("n", "<leader>gb", function()
						gitsigns.blame_line({ full = true })
					end, "Blame line")
					map("n", "<leader>gd", gitsigns.diffthis, "Diff this")

					-- Text object
					map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", "Select hunk")
				end,
			})
		end,
	},
	{
		"kdheepak/lazygit.nvim",
		keys = { "<c-g>" },
		config = function()
			vim.g.lazygit_floating_window_scaling_factor = 1.0
			vim.g.lazygit_floating_window_winblend = 0
			vim.g.lazygit_use_neovim_remote = true
			vim.keymap.set("n", "<c-g>", ":LazyGit<CR>", { noremap = true, silent = true })
		end,
	},
	-- {
	-- 	"APZelos/blamer.nvim",
	-- 	config = function()
	-- 		vim.g.blamer_enabled = true
	-- 		vim.g.blamer_relative_time = true
	-- 	end
	-- }
}
