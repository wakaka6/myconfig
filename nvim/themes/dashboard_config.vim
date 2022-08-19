lua << EOF
local status_ok, db = pcall(require, "dashboard")
if not status_ok then
	return
end

db.custom_header = {
    '',
    ' ███╗   ██╗ ███████╗ ██████╗  ██╗   ██╗ ██╗ ███╗   ███╗',
    ' ████╗  ██║ ██╔════╝██╔═══██╗ ██║   ██║ ██║ ████╗ ████║',
    ' ██╔██╗ ██║ █████╗  ██║   ██║ ██║   ██║ ██║ ██╔████╔██║',
    ' ██║╚██╗██║ ██╔══╝  ██║   ██║ ╚██╗ ██╔╝ ██║ ██║╚██╔╝██║',
    ' ██║ ╚████║ ███████╗╚██████╔╝  ╚████╔╝  ██║ ██║ ╚═╝ ██║',
    ' ╚═╝  ╚═══╝ ╚══════╝ ╚═════╝    ╚═══╝   ╚═╝ ╚═╝     ╚═╝',
    '',
    '',
    ''
    }

db.custom_center = {
      {
          icon = '  ',
          desc = 'Recently opened files                   ',
          action =  'Telescope oldfiles',
          shortcut = 'SPC f h'
      },
      {
          icon = '  ',
          desc = 'Find  File                              ',
          shortcut = 'SPC f f'
      },
      {
          icon = '  ',
          desc = 'Find  word                              ',
          shortcut = 'SPC f w'
      },
      {
          icon = '  ',
          desc = 'Save session                            ',
          shortcut = 'SPC s s',
      },
      {
          icon = '  ',
          desc = 'Recently latest session                 ',
          shortcut = 'SPC s l',
      },
    }

-- fix hightlight
local highlight = function(group, fg, bg, attr, sp)
		fg = fg and "guifg=" .. fg or "guifg=NONE"
		bg = bg and "guibg=" .. bg or "guibg=NONE"
		attr = attr and "gui=" ..attr or "gui=NONE"
		sp = sp and "guisp=" .. sp or ""

		vim.api.nvim_command("highlight " .. group .. " ".. fg .. " " .. bg .. " ".. attr .. " " .. sp)
	end

EOF
