-- ***
-- Global Config
-- ***
require("user.preferences")

-- ***
-- Maping Config
-- ***
require("user.mappings")

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
