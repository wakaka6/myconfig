-- ***
-- Global Config
-- ***
require("user.preferences")

-- ***
-- Maping Config
-- ***
require("user.mappings")

if not vim.g.vscode then
	-- ***
	-- scripts
	-- ***
	vim.cmd("source ~/.config/nvim/scripts/convenience.vim")

	-- auto command
	vim.cmd("source ~/.config/nvim/scripts/autocommands.vim")
end

-- ***
-- Plugins
-- ***
require("user.plugins")
require("user.conf.vscode")
