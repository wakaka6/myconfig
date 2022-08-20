lua << EOF

-- +-------------------------------------------------+
-- | A | B | C                             X | Y | Z |
-- +-------------------------------------------------+

local status_ok, line = pcall(require, "lualine")
if not status_ok then
	return
end

local colors = require('dracula').colors()

line.setup {
  options = {
    icons_enabled = true,
    theme = 'dracula-nvim',
    component_separators = { left = '', right = '|'},
    section_separators = { left = '', right = ''},
    disabled_filetypes = {
      statusline = {},
      winbar = {},
    },
    ignore_focus = {},
    always_divide_middle = true,
    globalstatus = false,
    refresh = {
      statusline = 1000,
      tabline = 1000,
      winbar = 1000,
    }
  },
  sections = {
    lualine_a = {
      { 'mode', separator = { left = '' }, right_padding = 2 },
    },
    lualine_b = {'branch', 'diff', 'diagnostics'},
    lualine_c = {'filename', 'g:coc_status'},
    lualine_x = {
        'filetype', 
        {'encoding', separator = { right = '' }, right_padding = 0}, 
        {'fileformat', left_padding = 0}
    },
    lualine_y = {'progress'},
    lualine_z = {
          { 'location', separator = { right = '' }, left_padding = 2 },
    },
  },
  inactive_sections = {
    lualine_a = {},
    lualine_b = {},
    lualine_c = {'filename'},
    lualine_x = {'filetype', 'encoding', {'fileformat', separator = { left = '' }} },
    lualine_y = {},
    lualine_z = {'location'},
  },
  tabline = {},
  winbar = {},
  inactive_winbar = {},
  extensions = {}
}

EOF
