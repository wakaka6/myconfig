vim.g.mapleader = " "

-- unmap ctrl+j as null
vim.g.BASH_Ctrl_j = "off"

vim.keymap.set("n", "S", "<cmd>w<CR>", { noremap = true })
vim.keymap.set("n", "Q", "<cmd>q<CR>", { noremap = true })

vim.keymap.set("i", "<C-q>", "<Esc>", { noremap = true })
vim.keymap.set("x", "<C-q>", "<Esc>", { noremap = true })
vim.keymap.set("s", "<C-q>", "<Esc>", { noremap = true })

-- Press space twice to jump to the next '<,.>' and edit it.
vim.keymap.set("n", "<Leader><Leader>", [[<Esc>/<,.><CR><cmd>nohlsearch<CR>"_c4l]], { noremap = true, silent = true })
vim.keymap.set("n", "<Leader>|", "a<,.><Esc>", { noremap = true, silent = true })

-- toggle buffer
vim.keymap.set("n", "[b", "<cmd>bprevious<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "]b", "<cmd>bnext<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<Leader>[", "<cmd>bprevious<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<Leader>]", "<cmd>bnext<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "[B", "<cmd>bfirst<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "]B", "<cmd>blast<CR>", { noremap = true, silent = true })

-- change better pane move method
vim.keymap.set("n", "<Leader>h", "<C-w>h", { noremap = true, silent = true })
vim.keymap.set("n", "<Leader>j", "<C-w>j", { noremap = true, silent = true })
vim.keymap.set("n", "<Leader>k", "<C-w>k", { noremap = true, silent = true })
vim.keymap.set("n", "<Leader>l", "<C-w>l", { noremap = true, silent = true })

-- resize pane with ALT+arrow
vim.keymap.set("n", "<M-Up>", "<cmd>resize -2<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<M-Down>", "<cmd>resize +2<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<M-Left>", "<cmd>vertical resize -2<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<M-Right>", "<cmd>vertical resize +2<CR>", { noremap = true, silent = true })

-- Command Mode Cursor Movement
vim.keymap.set("c", "<C-a>", "<Home>", { noremap = true })
vim.keymap.set("c", "<C-e>", "<End>", { noremap = true })
vim.keymap.set("c", "<C-b>", "<Left>", { noremap = true })
vim.keymap.set("c", "<C-f>", "<Right>", { noremap = true })
vim.keymap.set("c", "<C-n>", "<Down>", { noremap = true })
vim.keymap.set("c", "<C-p>", "<Up>", { noremap = true })

-- Insert Mode Cursor Movement
vim.keymap.set("i", "<C-a>", "<Home>", { noremap = true })
vim.keymap.set("i", "<C-e>", "<End>", { noremap = true })
vim.keymap.set("i", "<C-b>", "<Left>", { noremap = true })
vim.keymap.set("i", "<C-f>", "<Right>", { noremap = true })

-- Indentation
vim.keymap.set("n", "<", "<<", { noremap = true })
vim.keymap.set("n", ">", ">>", { noremap = true })

-- search
vim.keymap.set("n", "<Leader><CR>", "<cmd>nohlsearch<CR><C-l>", { noremap = true, silent = true })

-- Copy to system clipboard
vim.keymap.set("v", "Y", '"+y', { noremap = true })

-- 0切换行头和首个非空白符号
vim.keymap.set("n", "0", [[col('.') == 1 ? '^' : '0']], { expr = true })

-- 寻找中文
vim.keymap.set(
	"n",
	"<Leader>fz",
	[[<Esc>/\v<[\u4e00-\u9fa5]+>/<CR><cmd>nohlsearch<CR>]],
	{ noremap = true, silent = true }
)