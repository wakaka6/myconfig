-- Global Config
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true -- using space replace tab
vim.o.smarttab = true -- -- Enable smart tabbing (adjusts tab spacing based on context)

--  Define characters to represent tabs and trailing spaces in list mode
vim.o.list = true
vim.opt.listchars = { tab = "|\\ ", trail = "▫" }

vim.opt.termguicolors = true
vim.o.ttyfast = true
vim.o.autochdir = true

-- Syntax and Search
vim.cmd("nohlsearch")
vim.opt.hlsearch = true
vim.opt.incsearch = true
vim.opt.cursorline = true -- highlight current cursor line

-- Indentation and Clipboard
vim.opt.autoindent = true
vim.opt.clipboard:append("unnamed")
vim.opt.ruler = true
vim.opt.showcmd = true

-- Folding
vim.opt.foldenable = true
vim.opt.foldmethod = "syntax"
vim.opt.foldlevel = 100

-- Update Time
vim.opt.updatetime = 100

-- Line Numbers
vim.opt.number = true
vim.opt.relativenumber = true

-- keep 5 lines above and below cursor
vim.opt.scrolloff = 5

-- Tabs and Mode Display
vim.opt.showtabline = 2
vim.opt.showmode = false

-- Add 'c' to short message options to suppress certain messages
vim.o.shortmess = vim.o.shortmess .. "c"

-- Modify format options (removing 't' and 'c' for text formatting)
vim.o.formatoptions = vim.o.formatoptions:gsub("tc", "")

-- Command Menu
vim.opt.wildmenu = true

-- Set completion options
vim.o.completeopt = "menuone,noinsert,noselect,preview"

-- Filetype Support
vim.cmd("filetype on")
vim.cmd("filetype indent on")
vim.cmd("filetype plugin on")
vim.cmd("filetype plugin indent on")

-- LaTeX Filetype
vim.g.tex_flavor = "latex"

-- Syntax Embedding
vim.g.vimsyn_embed = "l"

-- set fcitx5 input method on linux
if vim.fn.has("linux") == 1 then
	-- Input Method Configuration
	local function disable_fcitx()
		os.execute("fcitx5-remote -c > /dev/null 2>&1")
	end
	vim.api.nvim_create_autocmd({ "InsertLeave", "BufCreate", "BufEnter", "BufLeave" }, {
		callback = disable_fcitx,
		desc = "Disable input method",
	})
end
