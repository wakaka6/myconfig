vim.cmd([[
augroup _load_break_points
autocmd!
autocmd FileType c,cpp,go,python,lua :lua require('user.conf.plugins.debugger.utils').load_breakpoints()
augroup end
]])

return {
	"mfussenegger/nvim-dap",
	dependencies = {
		"theHamsta/nvim-dap-virtual-text",
		"rcarriga/nvim-dap-ui",
		"jbyuki/one-small-step-for-vimkind",
	},
	keys = {
		{
			"<F9>",
			[[<cmd>lua require("dap").toggle_breakpoint();require'user.conf.plugins.debugger.utils'.store_breakpoints()<CR>]],
			noremap = true,
			silent = true,
		},
		{ "<F5>", '<cmd>lua require"dap".continue()<CR>', noremap = true, silent = true },
		{ "<F10>", '<cmd>lua require"dap".step_over()<CR>', noremap = true, silent = true },
		{ "<F11>", '<cmd>lua require"dap".step_into()<CR>', noremap = true, silent = true },
		{ "<F12>", '<cmd>lua require"dap".step_out()<CR>', noremap = true, silent = true },
	},
	config = function()
		local status_ok, dap = pcall(require, "dap")
		if not status_ok then
			return
		end

		local vt, dapui
		status_ok, vt = pcall(require, "nvim-dap-virtual-text")
		if not status_ok then
			return
		end

		status_ok, dapui = pcall(require, "dapui")
		if not status_ok then
			return
		end

		-- ============================= dap icon =====================================
		local dap_breakpoint = {
			error = {
				text = "●",
				texthl = "LspDiagnosticsDeafultError",
				linehl = "",
				numhl = "",
			},
			cond = {
				text = "◆",
				texthl = "LspDiagnosticsDefaultWarning",
				linehl = "",
				numhl = "",
			},
			log = {
				text = "◆",
				texthl = "SpellRare",
				linehl = "",
				numhl = "",
			},
			rejected = {
				text = "󰃤",
				texthl = "LspDiagnosticsDefaultHint",
				linehl = "",
				numhl = "",
			},
			stopped = {
				text = "",
				texthl = "LspDiagnosticsDefaultInformation",
				linehl = "DiagnosticUnderlineInfo",
				numhl = "LspDiagnosticsDefaultInformation",
			},
		}

		vim.fn.sign_define("DapBreakpoint", dap_breakpoint.error)
		vim.fn.sign_define("DapStopped", dap_breakpoint.stopped)
		vim.fn.sign_define("DapBreakpointRejected", dap_breakpoint.rejected)
		vim.fn.sign_define("DapBreakpointCondition", dap_breakpoint.cond)
		vim.fn.sign_define("DapLogPoint", dap_breakpoint.log)

		-- ============================= dap-virtual-text =============================
		vt.setup({
			enabled = true, -- enable this plugin (the default)
			enabled_commands = true, -- create commands DapVirtualTextEnable, DapVirtualTextDisable, DapVirtualTextToggle, (DapVirtualTextForceRefresh for refreshing when debug adapter did not notify its termination)
			highlight_changed_variables = true, -- highlight changed values with NvimDapVirtualTextChanged, else always NvimDapVirtualText
			highlight_new_as_changed = false, -- highlight new variables in the same way as changed variables (if highlight_changed_variables)
			show_stop_reason = true, -- show stop reason when stopped for exceptions
			commented = false, -- prefix virtual text with comment string
			only_first_definition = true, -- only show virtual text at first definition (if there are multiple)
			all_references = false, -- show virtual text on all all references of the variable (not only definitions)
			filter_references_pattern = "<module", -- filter references (not definitions) pattern when all_references is activated (Lua gmatch pattern, default filters out Python modules)
			-- experimental features:
			virt_text_pos = "eol", -- position of virtual text, see `:h nvim_buf_set_extmark()`
			all_frames = false, -- show virtual text for all stack frames not only current. Only works for debugpy on my machine.
			virt_lines = false, -- show virtual lines instead of virtual text (will flicker!)
			virt_text_win_col = nil, -- position the virtual text at a fixed window column (starting from the first text column) ,
			-- e.g. 80 to position at column 80, see `:h nvim_buf_set_extmark()`
		})

		-- ============================= dap-ui =============================
		dapui.setup({
			icons = { expanded = "▾", collapsed = "▸" },
			mappings = {
				-- Use a table to apply multiple mappings
				expand = { "<CR>", "<2-LeftMouse>" },
				open = "o",
				remove = "d",
				edit = "e",
				repl = "r",
				toggle = "t",
			},
			-- Expand lines larger than the window
			-- Requires >= 0.7
			expand_lines = vim.fn.has("nvim-0.7"),
			-- Layouts define sections of the screen to place windows.
			-- The position can be "left", "right", "top" or "bottom".
			-- The size specifies the height/width depending on position. It can be an Int
			-- or a Float. Integer specifies height/width directly (i.e. 20 lines/columns) while
			-- Float value specifies percentage (i.e. 0.3 - 30% of available lines/columns)
			-- Elements are the elements shown in the layout (in order).
			-- Layouts are opened in order so that earlier layouts take priority in window sizing.
			layouts = {
				{
					elements = {
						-- Elements can be strings or table with id and size keys.
						{ id = "scopes", size = 0.25 },
						"stacks",
						"watches",
					},
					size = 40, -- 40 columns
					position = "left",
				},
				{
					elements = {
						"repl",
					},
					size = 0.25, -- 25% of total lines
					position = "bottom",
				},
				{
					elements = {
						"console",
					},
					size = 30,
					position = "right",
				},
			},
			floating = {
				max_height = nil, -- These can be integers or a float between 0 and 1.
				max_width = nil, -- Floats will be treated as percentage of your screen.
				border = "single", -- Border style. Can be "single", "double" or "rounded"
				mappings = {
					close = { "q", "<Esc>" },
				},
			},
			windows = { indent = 1 },
			render = {
				max_type_length = nil, -- Can be integer or nil.
			},
		})

		-- auto open or close dapui when the debug event happend
		local debug_open = function()
			dapui.open()
			vim.api.nvim_command("DapVirtualTextEnable")
		end
		local debug_close = function()
			dap.repl.close()
			dapui.close()
			vim.api.nvim_command("DapVirtualTextDisable")
			-- vim.api.nvim_command("bdelete! term:")   -- close debug temrinal
		end

		dap.listeners.after.event_initialized["dapui_config"] = function()
			debug_open()

			if vim.bo.filetype == "python" then
				dapui.close(3)
			end
		end
		dap.listeners.before.event_terminated["dapui_config"] = function()
			debug_close()
		end
		dap.listeners.before.event_exited["dapui_config"] = function()
			debug_close()
		end
		dap.listeners.before.disconnect["dapui_config"] = function()
			debug_close()
		end

		local repl = require("dap.repl")
		repl.commands = vim.tbl_extend("force", repl.commands, {
			-- Add a new alias for the existing .exit command
			exit = { "exit", ".exit", ".bye" },
			-- Add your own commands; run `.echo hello world` to invoke
			-- this function with the text "hello world"
			custom_commands = {
				-- ['.echo'] = function(text)
				--     dap.repl.append(text)
				-- end,
				[".tty"] = function(tty)
					dap.repl.append("-exec gef config context.redirect " .. tty)
				end,
				-- Hook up a new command to an existing dap function
				[".restart"] = dap.restart,
			},
		})

		-- =================== adapter ========================
		require("user.conf.plugins.debugger.dap_cpp")
		require("user.conf.plugins.debugger.dap_go")
		require("user.conf.plugins.debugger.dap_python")
		require("user.conf.plugins.debugger.dap_lua")
		-- =================== mappping ========================
		vim.keymap.set("n", "<F9>", "<leader>db", { noremap = true, silent = true })
		vim.keymap.set("n", "<F5>", ':lua require"dap".continue()<CR>', { noremap = true, silent = true })
		vim.keymap.set("n", "<F10>", ':lua require"dap".step_over()<CR>', { noremap = true, silent = true })
		vim.keymap.set("n", "<F11>", ':lua require"dap".step_into()<CR>', { noremap = true, silent = true })
		vim.keymap.set("n", "<F12>", ':lua require"dap".step_out()<CR>', { noremap = true, silent = true })
		-- =================== autocmd ========================
	end,
}
