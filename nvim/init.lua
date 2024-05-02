-- ***
-- Global Config
-- ***
vim.cmd("source ~/.config/nvim/globals/globals.vim")

-- ***
-- Maping Config
-- ***
vim.cmd("source ~/.config/nvim/mappings/mapping.vim")

-- ***
-- scripts
-- ***
vim.cmd("source ~/.config/nvim/scripts/convenience.vim")

-- auto command
vim.cmd("source ~/.config/nvim/scripts/autocommands.vim")

-- ***
-- Plugins
-- ***
require("user.plugins")
