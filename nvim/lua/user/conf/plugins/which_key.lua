return {
	"folke/which-key.nvim",
	event = "VeryLazy",
	init = function()
		vim.o.timeout = true
		-- vscode don't show which key (set long timeout 1 min)
		vim.o.timeoutlen = not vim.g.vscode and 1000 or 60000
	end,
	opts = {
		preset = "classic", -- "classic" | "modern" | "helix" | false
		
		-- Delay before showing the popup
		delay = function(ctx)
			return ctx.plugin and 0 or 200
		end,
		
		-- Filter function for mappings
		filter = function(mapping)
			return true
		end,
		
		-- Notification for issues
		notify = true,
		
		-- Triggers configuration
		triggers = {
			{ "<auto>", mode = "nxso" },
		},
		
		-- Defer function for visual modes
		defer = function(ctx)
			return ctx.mode == "V" or ctx.mode == "<C-V>"
		end,
		
		-- Plugins configuration
		plugins = {
			marks = true, -- shows a list of your marks on ' and `
			registers = true, -- shows your registers on " in NORMAL or <C-r> in INSERT mode
			spelling = {
				enabled = true, -- enabling this will show WhichKey when pressing z= to select spelling suggestions
				suggestions = 20, -- how many suggestions should be shown in the list?
			},
			-- the presets plugin, adds help for a bunch of default keybindings in Neovim
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
		
		-- Window configuration
		win = {
			no_overlap = true,
			padding = { 2, 2, 2, 2 }, -- extra window padding [top, right, bottom, left]
			title = true,
			title_pos = "center",
			zindex = 1000,
			bo = {},
			wo = {
				winblend = 0,
			},
		},
		
		-- Layout configuration
		layout = {
			width = { min = 20, max = 50 }, -- min and max width of the columns
			spacing = 3, -- spacing between columns
		},
		
		-- Key bindings for scrolling
		keys = {
			scroll_down = "<c-d>", -- binding to scroll down inside the popup
			scroll_up = "<c-u>", -- binding to scroll up inside the popup
		},
		
		-- Sorting configuration
		sort = { "local", "order", "group", "alphanum", "mod" },
		
		-- Expand groups when <= n mappings
		expand = 0,
		
		-- Replacement rules for formatting
		replace = {
			key = {
				function(key)
					return require("which-key.view").format(key)
				end,
			},
			desc = {
				{ "<Plug>%(?(.*)%)?", "%1" },
				{ "^%+", "" },
				{ "<[cC]md>", "" },
				{ "<[cC][rR]>", "" },
				{ "<[sS]ilent>", "" },
				{ "^lua%s+", "" },
				{ "^call%s+", "" },
				{ "^:%s*", "" },
			},
		},
		
		-- Icons configuration
		icons = {
			breadcrumb = "", -- symbol used in the command line area that shows your active key combo
			separator = "", -- symbol used between a key and it's label
			group = "󱡠", -- symbol prepended to a group
			ellipsis = "…",
			mappings = true,
			rules = {},
			colors = true,
			keys = {
				Up = " ",
				Down = " ",
				Left = " ",
				Right = " ",
				C = "󰘴 ",
				M = "󰘵 ",
				D = "󰘳 ",
				S = "󰘶 ",
				CR = "󰌑 ",
				Esc = "󱊷 ",
				ScrollWheelDown = "󱕐 ",
				ScrollWheelUp = "󱕑 ",
				NL = "󰌑 ",
				BS = "󰁮",
				Space = "󱁐 ",
				Tab = "󰌒 ",
			},
		},
		
		show_help = true, -- show help message on the command line when the popup is visible
		show_keys = true, -- show the currently pressed key and its label as a message in the command line
		
		-- Disable WhichKey for certain buf types and file types
		disable = {
			ft = {},
			bt = {},
		},
		
		debug = false, -- enable wk.log in the current directory
		
		-- Mappings specification (new v3 format)
		spec = {
			-- Normal mode mappings with <leader> prefix
			{
				mode = "n",
				{ "<leader>u", "<cmd>MundoToggle<CR>", desc = "undotree", icon = "󰕍" },
				{ "<leader>|", "a<,.><ESC>", desc = "Insert mark", icon = "󰃀" },
				{ "<leader><leader>", '<ESC>/<,.><CR>:nohlsearch<CR>"_c4l', desc = "Find mark", icon = "󰍉" },
				
				-- hop easyemotion
				{ "<leader>w", "<cmd>HopWord<CR>", desc = "Easy Emotion by word", icon = "󰉁" },
				{ "<leader>/", "<cmd>HopPattern<CR>", desc = "Easy Emotion by pattern search", icon = "󰈞" },
				
				-- Buffer navigation
				{ "<leader>[", "<cmd>bprevious<CR>", desc = "Previous buffer", icon = "󰒮" },
				{ "<leader>]", "<cmd>bnext<CR>", desc = "Next buffer", icon = "󰒭" },
				
				-- Window navigation
				{ "<leader>h", "<C-w>h", desc = "Move to left window", icon = "󰁍" },
				{ "<leader>j", "<C-w>j", desc = "Move to bottom window", icon = "󰁅" },
				{ "<leader>k", "<C-w>k", desc = "Move to top window", icon = "󰁝" },
				{ "<leader>l", "<C-w>l", desc = "Move to right window", icon = "󰁔" },
				
				-- Clear search highlight
				{ "<leader><CR>", "<cmd>nohlsearch<CR><C-l>", desc = "Clear search highlight", icon = "󰌑" },
				
				-- LSP mappings (will be added dynamically by LSP)
				{ "<leader>ca", desc = "Code action", icon = "󰅱" },
				{ "<leader>rn", desc = "Rename symbol", icon = "󰑕" },
				{ "<leader>cd", desc = "Show line diagnostics", icon = "󰙅" },
				{ "<leader>D", desc = "Show buffer diagnostics", icon = "󰙅" },
				{ "<leader>-", desc = "Go to previous diagnostic", icon = "󰒮" },
				{ "<leader>=", desc = "Go to next diagnostic", icon = "󰒭" },
				{ "<leader>rs", desc = "Restart LSP", icon = "󰑓" },
				
				-- code action group
				{ "<leader>c", group = "code action", icon = "󰅱" },
				
				-- trouble group
				{ "<leader>x", group = "trouble", icon = "󰙅" },
				
				-- git group with detailed mappings
				{ "<leader>g", group = "git", icon = "󰊢" },
				{ "<leader>gs", desc = "Stage hunk", icon = "󰐕" },
				{ "<leader>gr", desc = "Reset hunk", icon = "󰜉" },
				{ "<leader>gu", desc = "Undo stage hunk", icon = "󰕍" },
				{ "<leader>gS", desc = "Stage buffer", icon = "󰐕" },
				{ "<leader>gR", desc = "Reset buffer", icon = "󰜉" },
				{ "<leader>gp", desc = "Preview hunk", icon = "󰍉" },
				{ "<leader>gb", desc = "Blame line", icon = "󰊠" },
				{ "<leader>gd", desc = "Diff this", icon = "󰦓" },
				{ "<leader>gB", desc = "Toggle current line blame", icon = "󰊠" },
				{ "<leader>g=", desc = "Next hunk", icon = "󰒭" },
				{ "<leader>g-", desc = "Previous hunk", icon = "󰒮" },
				
				-- debug group
				{ "<leader>d", group = "debug", icon = "󰃤" },
				{ "<leader>dc", "<Cmd>tabe .dap_launch.json<CR><Cmd>LoadDebugLaunchJsonTemplate<CR>", desc = "Create debug file", icon = "󰈔" },
				{ "<leader>de", '<Cmd>lua require("dapui").eval()<CR>', desc = "show expression value on hover window", icon = "󰍉" },
				{ "<leader>do", [[<Cmd>lua require('dap').repl.toggle()<CR>]], desc = "toggle dap REPL", icon = "󰞷" },
				{ "<leader>dq", '<Cmd>lua require("dap").terminate()<CR>', desc = "stop debug", icon = "󰓛" },
				{ "<leader>dl", '<Cmd>lua require("dap.ext.vscode").load_launchjs(".dap_launch.json", require("user.conf.plugins.debugger.utils").get_adapter_map())<CR>', desc = "load launch.json to dap", icon = "󰒓" },
				{ "<leader>db", [[<Cmd>lua require("dap").toggle_breakpoint();require'user.conf.plugins.debugger.utils'.store_breakpoints()<CR>]], desc = "breakpoint", icon = "󰏃" },
				{ "<leader>dB", "<Cmd>lua require'dap'.set_breakpoint(vim.fn.input('Breakpoint condition: '))<CR>", desc = "condition breakpoint", icon = "󰟃" },
				{ "<leader>du", "<Cmd>lua require'dap'.up()<CR>", desc = "Go up stack frame", icon = "󰁝" },
				{ "<leader>dd", "<Cmd>lua require'dap'.down()<CR>", desc = "Go down stack frame", icon = "󰁅" },
				{ "<leader>dR", "<Cmd>lua require'dap'.run_to_cursor()<CR>", desc = "Go to current cursor", icon = "󰑮" },
				
				-- find group
				{ "<leader>f", group = "find", icon = "󰈞" },
				{ "<leader>ff", "<Cmd>Telescope find_files find_command=rg,--hidden,--files<CR>", desc = "Find fuzz file", icon = "󰈔" },
				{ "<leader>fa", "<Cmd>Telescope treesitter<CR>", desc = "Find AST", icon = "󰙅" },
				{ "<leader>fw", '<Cmd>lua require("telescope").extensions.live_grep_args.live_grep_args(require("telescope.themes").get_ivy())<cr>', desc = "Find fuzz word", icon = "󰊄" },
				{ "<leader>fb", "<Cmd>Telescope buffers<CR>", desc = "Navigation buffers", icon = "󰓩" },
				{ "<leader>fh", "<Cmd>Telescope oldfiles<cr>", desc = "Open Recent File", icon = "󰋚" },
				{ "<leader>fz", [[<ESC>/\v<[\u4e00-\u9fa5]+>/<CR>:nohlsearch<CR>]], desc = "Find zh-CN word", icon = "󰊿" },
				{ "<leader>fk", "<cmd>CellularAutomaton make_it_rain<CR>", desc = "Make it awesome rain", icon = "󰖔" },
				
				-- session group
				{ "<leader>s", group = "session", icon = "󰁯" },
				{ "<leader>ss", "<cmd>SessionSave<CR>", desc = "Session Save", icon = "󰆓" },
				{ "<leader>sl", "<cmd>SessionRestore<CR>", desc = "Session Load", icon = "󰁯" },
				
				-- Buffer line number mappings
				{ "<leader>1", "<Cmd>BufferLineGoToBuffer 1<CR>", desc = "Go to buffer 1", icon = "󰎦" },
				{ "<leader>2", "<Cmd>BufferLineGoToBuffer 2<CR>", desc = "Go to buffer 2", icon = "󰎩" },
				{ "<leader>3", "<Cmd>BufferLineGoToBuffer 3<CR>", desc = "Go to buffer 3", icon = "󰎬" },
				{ "<leader>4", "<Cmd>BufferLineGoToBuffer 4<CR>", desc = "Go to buffer 4", icon = "󰎮" },
				{ "<leader>5", "<Cmd>BufferLineGoToBuffer 5<CR>", desc = "Go to buffer 5", icon = "󰎰" },
				{ "<leader>6", "<Cmd>BufferLineGoToBuffer 6<CR>", desc = "Go to buffer 6", icon = "󰎵" },
				{ "<leader>7", "<Cmd>BufferLineGoToBuffer 7<CR>", desc = "Go to buffer 7", icon = "󰎸" },
				{ "<leader>8", "<Cmd>BufferLineGoToBuffer 8<CR>", desc = "Go to buffer 8", icon = "󰎻" },
				{ "<leader>9", "<Cmd>BufferLineGoToBuffer 9<CR>", desc = "Go to buffer 9", icon = "󰎾" },
			},
			
			-- Visual mode mappings with <leader> prefix
			{
				mode = "v",
				{ "<leader>c", group = "code action", icon = "󰅱" },
				{ "<leader>d", group = "debug", icon = "󰃤" },
				{ "<leader>de", '<Cmd>lua require("dapui").eval()<CR>', desc = "show expression value on hover window", icon = "󰍉" },
				{ "<leader>g", group = "git", icon = "󰊢" },
				{ "<leader>gs", desc = "Stage hunk", icon = "󰐕" },
				{ "<leader>hr", desc = "Reset hunk", icon = "󰜉" },
			},
			
			-- Window mappings with <C-w> prefix
			{
				mode = "n",
				{ "<C-w>m", "<Cmd>WinShift<CR>", desc = "Window Shift Mode", icon = "󰹹" },
			},
			
			-- Buffer navigation without leader (bracket mappings)
			{
				mode = "n",
				{ "[b", "<cmd>bprevious<CR>", desc = "Previous buffer", icon = "󰒮" },
				{ "]b", "<cmd>bnext<CR>", desc = "Next buffer", icon = "󰒭" },
				{ "[B", "<cmd>bfirst<CR>", desc = "First buffer", icon = "󰒮" },
				{ "]B", "<cmd>blast<CR>", desc = "Last buffer", icon = "󰒭" },
				{ "[t", desc = "Previous todo comment", icon = "󰒮" },
				{ "]t", desc = "Next todo comment", icon = "󰒭" },
			},
			
			-- LSP mappings (global)
			{
				mode = "n",
				{ "gr", desc = "Show LSP references", icon = "󰈇" },
				{ "gd", desc = "Go to definition", icon = "󰈮" },
				{ "gD", desc = "Go to declaration", icon = "󰈮" },
				{ "gi", desc = "Go to implementation", icon = "󰈮" },
				{ "gy", desc = "Go to type definition", icon = "󰈮" },
				{ "K", desc = "Show hover documentation", icon = "󰋽" },
			},
			
			-- Function keys for debugging
			{
				mode = "n",
				{ "<F5>", desc = "Debug: Continue", icon = "󰐊" },
				{ "<F9>", desc = "Debug: Toggle breakpoint", icon = "󰏃" },
				{ "<F10>", desc = "Debug: Step over", icon = "󰒭" },
				{ "<F11>", desc = "Debug: Step into", icon = "󰁅" },
			},
			
			-- Other useful mappings
			{
				mode = "n",
				{ "tt", "<cmd>NvimTreeToggle<cr>", desc = "Toggle file tree", icon = "󰙅" },
				{ "gb", "<Cmd>BufferLinePick<CR>", desc = "Pick buffer", icon = "󰓩" },
				{ "S", "<cmd>w<CR>", desc = "Save file", icon = "󰆓" },
				{ "Q", "<cmd>q<CR>", desc = "Quit", icon = "󰗼" },
			},
		},
	},
	
	config = function(_, opts)
		local wk = require("which-key")
		wk.setup(opts)
		
		-- Additional keymaps can be added here if needed
		-- wk.add({
		--   { "<leader>example", "<cmd>Example<cr>", desc = "Example command" },
		-- })
	end,
}
