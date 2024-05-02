return {
    'glepnir/dashboard-nvim',
    event = 'VimEnter',
    dependencies = {'nvim-tree/nvim-web-devicons'},
    commit = '1c8b82c5b02bb890862538be2061e37ef801a99b',
    config = function()
        local status_ok, db = pcall(require, "dashboard")
        if not status_ok then
            return
        end

        db.setup({
            theme = 'doom',
            config = {
                header = {
                    '',
                    [[                            .:=====-:..         ..................:-::]],
                    [[      鸡你太美        ..... =####*##*+:        ................... ...]],
                    [[                     .     .:+===-==:    .    ......................  ]],
                    [[                  ... .-==:+%%#=-=++:-:.  ...... .....................]],
                    [[                ..   :#%%@%=%@@@%#%@-#@%*:     .......................]],
                    [[              ..  .-+%@@@%##%@%%@@%##%@@@@#+--:.    ..................]],
                    [[            ..  :=#@@@%#**%@@@@@%+==:.:-=+*#%%%#**+:.  ...............]],
                    [[           .  :*@@%#%%**%@@@@%*=.           ..:=*####+. ..............]],
                    [[      ....  :*@%+-=+**########+- ........... :---::-=+: ..............]],
                    [[....  ..  -*@*-.  =*************. ...........=++==++++: ..............]],
                    [[::::.....:+#*. .. -++++**=***+++=: ...........-=+++=-.................]],
                    [[:::::::.--.........++==+= :+#*++=+: ..........  ...   ................]],
                    [[:::::::::::....... :+====.  :+++==+: .................................]],
                    [[::::::::::::::.... :+===+: . .-+++++: ................................]],
                    [[.::::::::::::::::..:++++=..... -**+*- ................................]],
                    '',
                    '',
                    '',
                },
                center = {
                    {
                        icon = '  ',
                        desc = 'Create new files',
                        action = 'bdelete',
                        key = 'n',
                        desc_hl = 'String',
                        icon_hl = 'Title',
                        key_hl = 'Number',
                    },
                    {
                        icon = '  ',
                        desc = 'Recently opened files',
                        action =  'Telescope oldfiles',
                        key = 'h',
                        desc_hl = 'String',
                        icon_hl = 'Title',
                        key_hl = 'Number',
                    },
                    {
                        icon = '  ',
                        desc = 'Find  File',
                        key = 'f',
                        action = 'Telescope find_files find_command=rg,--hidden,--files',
                        desc_hl = 'String',
                        icon_hl = 'Title',
                        key_hl = 'Number',
                    },
                    {
                        icon = '  ',
                        desc = 'Find  word       ',
                        key = 'w',
                        action = 'lua require("telescope").extensions.live_grep_args.live_grep_args(require("telescope.themes").get_ivy())',
                        desc_hl = 'String',
                        icon_hl = 'Title',
                        key_hl = 'Number',
                    },
                    {
                        icon = '  ',
                        desc = 'Quit  ',
                        key = 'q',
                        action = 'qa',
                        desc_hl = 'String',
                        icon_hl = 'Title',
                        key_hl = 'Number',
                    },
                },
                footer = {}  --your footer
            }
        })
    end,
}
