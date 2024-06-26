" By default timeoutlen is 1000 ms
set timeoutlen=1000

lua << EOF
local status_ok, which_key = pcall(require, "which-key")
if not status_ok then
  return
end

local setup = {
  plugins = {
    marks = true, -- shows a list of your marks on ' and `
    registers = true, -- shows your registers on " in NORMAL or <C-r> in INSERT mode
    spelling = {
      enabled = true, -- enabling this will show WhichKey when pressing z= to select spelling suggestions
      suggestions = 20, -- how many suggestions should be shown in the list?
    },
    -- the presets plugin, adds help for a bunch of default keybindings in Neovim
    -- No actual key bindings are created
    presets = {
      operators = false, -- adds help for operators like d, y, ... and registers them for motion / text object completion
      motions = false, -- adds help for motions
      text_objects = false, -- help for text objects triggered after entering an operator
      windows = true, -- default bindings on <c-w>
      nav = true, -- misc bindings to work with windows
      z = true, -- bindings for folds, spelling and others prefixed with z
      g = true, -- bindings for prefixed with g
    },
  },
  -- add operators that will trigger motion and text object completion
  -- to enable all native operators, set the preset / operators plugin above
  -- operators = { gc = "Comments" },
  key_labels = {
    -- override the label used to display some keys. It doesn't effect WK in any other way.
    -- For example:
    -- ["<space>"] = "SPC",
    -- ["<cr>"] = "RET",
    -- ["<tab>"] = "TAB",
  },
  icons = {
    breadcrumb = "", -- symbol used in the command line area that shows your active key combo
    separator = "", -- symbol used between a key and it's label
    group = "󱡠", -- symbol prepended to a group
  },
  popup_mappings = {
    scroll_down = "<c-d>", -- binding to scroll down inside the popup
    scroll_up = "<c-u>", -- binding to scroll up inside the popup
  },
  window = {
    border = "rounded", -- none, single, double, shadow
    position = "bottom", -- bottom, top
    margin = { 1, 0, 1, 0 }, -- extra window margin [top, right, bottom, left]
    padding = { 2, 2, 2, 2 }, -- extra window padding [top, right, bottom, left]
    winblend = 0,
  },
  layout = {
    height = { min = 4, max = 25 }, -- min and max height of the columns
    width = { min = 20, max = 50 }, -- min and max width of the columns
    spacing = 3, -- spacing between columns
    align = "left", -- align columns left, center or right
  },
  ignore_missing = false, -- enable this to hide mappings for which you didn't specify a label
  hidden = { "<silent>", "<cmd>", "<Cmd>", "<CR>", "call", "lua", "^:", "^ " }, -- hide mapping boilerplate
  show_help = true, -- show help message on the command line when the popup is visible
  triggers = "auto", -- automatically setup triggers
  -- triggers = {"<leader>"} -- or specify a list manually
  triggers_blacklis = {
    -- list of mode / prefixes that should never be hooked by WhichKey
    -- this is mostly relevant for key maps that start with a native binding
    -- most people should not need to change this
    i = { "j", "k" },
    v = { "j", "k" },
  },
}

local opts = {
  mode = "n", -- NORMAL mode
  prefix = "<leader>",
  buffer = nil, -- Global mappings. Specify a buffer number for buffer local mappings
  silent = true, -- use `silent` when creating keymaps
  noremap = true, -- use `noremap` when creating keymaps
  nowait = true, -- use `nowait` when creating keymaps
}

local mappings = {
  ["u"] = { "<cmd>MundoToggle<CR>", "undotree" },
  ["|"] = { "a<,.><ESC>", "Insert mark" },
  ["<leader>"] = { '<ESC>/<,.><CR>:nohlsearch<CR>"_c4l', "Find mark" },

  -- hop easyemotion
  w = {"<cmd>HopWord<CR>", "Easy Emotion by word"},
  ["/"] = {"<cmd>HopPattern<CR>", "Easy Emotion by pattern search"},

  c = {
    name = 'coc' 

  },

  d = {
    name = 'debug',
    -- c = { '<Cmd>tabe .vimspector.json<CR><Cmd>LoadDebugLaunchJsonTemplate<CR>', 'Creat debug file' },
    c = { '<Cmd>tabe .dap_launch.json<CR><Cmd>LoadDebugLaunchJsonTemplate<CR>', 'Creat debug file' },
    e = { '<Cmd>lua require("dapui").eval()<CR>', 'show expression value on hover window' },
    o = { [[<Cmd>lua require('dap').repl.toggle()<CR>]], 'toggle dap REPL' },
    q = { '<Cmd>lua require("dap").terminate()<CR>', 'stop debug' },
    l = {'<Cmd>lua require("dap.ext.vscode").load_launchjs(".dap_launch.json", require("user.dap.utils").get_adapter_map())<CR>', 
        'load launch.json to dap'},
    b = { [[<Cmd>lua require("dap").toggle_breakpoint();require'user.dap.utils'.store_breakpoints()<CR>]], 'breakpoint' },
    B = { "<Cmd>lua require'dap'.set_breakpoint(vim.fn.input('Breakpoint condition: '))<CR>", 
        'condition breakpoint' },
    u = { "<Cmd>lua require'dap'.up()<CR>", "Go up stack frame" },
    d = { "<Cmd>lua require'dap'.down()<CR>", "Go down stack frame"},
    R = { "<Cmd>lua require'dap'.run_to_cursor()<CR>", "Go to current cursor"},
  },

  f = {
    name = 'find' ,
    f =  { '<Cmd>Telescope find_files find_command=rg,--hidden,--files<CR>', 'Find fuzz file' },
    a =  { '<Cmd>Telescope treesitter<CR>', 'Find AST' },
    -- w =  { ':Telescope live_grep theme=ivy<CR>', 'Find fuzz word' },
    w =  { '<Cmd>lua require("telescope").extensions.live_grep_args.live_grep_args(require("telescope.themes").get_ivy())<cr>', 'Find fuzz word' },
    b =  { '<Cmd>Telescope buffers<CR>', 'Navigation buffers' },
    h = { "<Cmd>Telescope oldfiles<cr>", "Open Recent File" },

    z =  { [[<ESC>/\v<[\u4e00-\u9fa5]+>/<CR>:nohlsearch<CR>]], 'Find zh-CN word' },
    k = { "<cmd>CellularAutomaton make_it_rain<CR>", 'Make it awesome rain' },
  },

  s = {
    name = 'session', 
    s = {"<C-u>:SessionSave<CR>", 'Session Save'},
    l = {"<C-u>:SessionLoad<CR>", 'Session Load'},
  },

}

local vopts = {
  mode = "v", -- VISUAL mode
  prefix = "<leader>",
  buffer = nil, -- Global mappings. Specify a buffer number for buffer local mappings
  silent = true, -- use `silent` when creating keymaps
  noremap = true, -- use `noremap` when creating keymaps
  nowait = true, -- use `nowait` when creating keymaps
}
local vmappings = {
  c = {
    name = 'coc' 

  },
  d = {
    name = 'debug',
    e = { '<Cmd>lua require("dapui").eval()<CR>', 'show expression value on hover window' },

  },
}

-- window <C-w>
local wopts = {
  mode = "n",
  prefix = "<C-w>",
  buffer = nil, -- Global mappings. Specify a buffer number for buffer local mappings
  silent = true, -- use `silent` when creating keymaps
  noremap = true, -- use `noremap` when creating keymaps
  nowait = true, -- use `nowait` when creating keymaps
}
local wmappings = {
    m = { "<Cmd>WinShift<CR>", "Window Shift Mode" },
  --  X = { "<Cmd>WinShift swap<CR>", "Pick window to swap" },
}

which_key.setup(setup)
which_key.register(mappings, opts)
which_key.register(vmappings, vopts)
which_key.register(wmappings, wopts)
EOF


