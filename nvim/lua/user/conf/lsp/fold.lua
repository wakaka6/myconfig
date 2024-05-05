-- Adding number suffix of folded lines instead of the default ellipsis
local handler = function(virtText, lnum, endLnum, width, truncate)
	local newVirtText = {}
	local suffix = (" 󰁂 %d "):format(endLnum - lnum)
	local sufWidth = vim.fn.strdisplaywidth(suffix)
	local targetWidth = width - sufWidth
	local curWidth = 0
	for _, chunk in ipairs(virtText) do
		local chunkText = chunk[1]
		local chunkWidth = vim.fn.strdisplaywidth(chunkText)
		if targetWidth > curWidth + chunkWidth then
			table.insert(newVirtText, chunk)
		else
			chunkText = truncate(chunkText, targetWidth - curWidth)
			local hlGroup = chunk[2]
			table.insert(newVirtText, { chunkText, hlGroup })
			chunkWidth = vim.fn.strdisplaywidth(chunkText)
			-- str width returned from truncate() may less than 2nd argument, need padding
			if curWidth + chunkWidth < targetWidth then
				suffix = suffix .. (" "):rep(targetWidth - curWidth - chunkWidth)
			end
			break
		end
		curWidth = curWidth + chunkWidth
	end
	table.insert(newVirtText, { suffix, "MoreMsg" })
	return newVirtText
end

return {
	{
		"kevinhwang91/nvim-ufo",
		event = "VeryLazy",
		dependencies = "kevinhwang91/promise-async",
		config = function()
			local status, nvim_ufo = pcall(require, "ufo")
			if not status then
				return
			end

			nvim_ufo.setup({
				provider_selector = function(bufnr, filetype, buftype)
					return { "treesitter", "indent" }
				end,
				fold_virt_text_handler = handler,
			})

			vim.keymap.set("n", "zR", nvim_ufo.openAllFolds)
			vim.keymap.set("n", "zM", nvim_ufo.closeAllFolds)
		end,
	},
	{
		"anuvyklack/fold-preview.nvim",
		event = "VeryLazy",
		dependencies = "anuvyklack/keymap-amend.nvim",
	},
}
