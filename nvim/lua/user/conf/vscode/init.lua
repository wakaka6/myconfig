if not vim.g.vscode then
	return
end

local status_ok, vscode = pcall(require, "vscode")
if not status_ok then
	return
end

vim.notify = vscode.notify

vim.keymap.set(
	"n",
	"tt",
	"<cmd>lua require('vscode').action('workbench.action.toggleSidebarVisibility')<CR>",
	{ noremap = true }
)

vim.keymap.set(
	"n",
	"tt",
	"<cmd>lua require('vscode').action('workbench.action.toggleSidebarVisibility')<CR>",
	{ noremap = true }
)

-- fold
vim.keymap.set("n", "za", "<cmd>lua require('vscode').action('editor.toggleFold')<CR>", { noremap = true })
vim.keymap.set("n", "zA", "<cmd>lua require('vscode').action('editor.toggleFold')<CR>", { noremap = true })
vim.keymap.set("n", "zM", "<cmd>lua require('vscode').action('editor.unfoldAll')<CR>", { noremap = true })
vim.keymap.set("n", "zo", "<cmd>lua require('vscode').action('editor.fold')<CR>", { noremap = true })
vim.keymap.set("n", "zO", "<cmd>lua require('vscode').action('editor.foldAll')<CR>", { noremap = true })
