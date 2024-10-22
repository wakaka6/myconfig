-- ***
-- Global Config
-- ***
vim.cmd("source ~/.config/nvim/globals/globals.vim")

-- vim.g.clipboard = {
--     name = "osc52",
--     copy = {
--         ["+"] = require('vim.ui.clipboard.osc52').copy("+"),
--         ["*"] = require('vim.ui.clipboard.osc52').copy("*"),
--     },
--     paste = {
--     },
-- }

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
