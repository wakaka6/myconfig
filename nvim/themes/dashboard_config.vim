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
          action = 'Telescope find_files find_command=rg,--hidden,--files',
          shortcut = 'SPC f f'
      },
      {
          icon = '  ',
          desc = 'Find  word                              ',
          action = 'Telescope live_grep',
          shortcut = 'SPC f w'
      },
      {
          icon = '  ',
          desc = 'Save session                            ',
          shortcut = 'SPC s s',
          action ='SessionSave'
      },
      {
          icon = '  ',
          desc = 'Recently latest session                 ',
          shortcut = 'SPC s l',
          action ='SessionLoad'
      },
    }
EOF
