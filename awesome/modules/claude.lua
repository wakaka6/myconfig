local awful = require("awful")
local naughty = require("naughty")
local gears = require("gears")
local lgi = require("lgi")
local GLib = lgi.GLib
local agents = require("modules.agents")

local M = {}

-- 存储活跃通知和对应的 window_id，用于聚焦时自动关闭
local active_notifications = {}

-- 配置
local CONFIG = {
	scratchpad_dir = os.getenv("HOME") .. "/Documents/scratchpad",
	icon = "󱜚",
	font = "JetBrains Mono Nerd Font",
	accent_color = "#bd93f9",
	text_color = "#f8f8f2",
	muted_color = "#6272a4",
	preview_max_chars = 30,
}

-- 查找 Claude 可执行文件
local function find_claude_bin()
	local home = os.getenv("HOME")
	local candidates = {
		home .. "/.local/bin/claude",
		home .. "/.claude/local/claude",
		"/usr/local/bin/claude",
		"/usr/bin/claude",
	}

	local nvm_dir = os.getenv("NVM_DIR") or (home .. "/.config/nvm")
	local handle = io.popen("ls -d " .. nvm_dir .. "/versions/node/*/bin/claude 2>/dev/null | head -1")
	if handle then
		local path = handle:read("*l")
		handle:close()
		if path and path ~= "" then
			table.insert(candidates, 1, path)
		end
	end

	for _, path in ipairs(candidates) do
		local f = io.open(path, "r")
		if f then
			f:close()
			return path
		end
	end
	return "claude"
end

local CLAUDE_BIN = find_claude_bin()

-- 工具函数
local function trim(str)
	if not str then
		return ""
	end
	return str:gsub("^%s+", ""):gsub("%s+$", "")
end

local function strip_ansi(str)
	if not str then
		return ""
	end
	return str:gsub("\027%[[0-9;]*[A-Za-z]", "")
end

local function safe_quote(str)
	if not str or str == "" then
		return "''"
	end
	local clean = str:gsub("[%z\1-\8\11\12\14-\31\127]", "")
	local quoted = GLib.shell_quote(clean)
	return quoted or ("'" .. clean:gsub("'", "'\\''") .. "'")
end

local function utf8_len(str)
	return str and GLib.utf8_strlen(str, -1) or 0
end

local function utf8_sub(str, i, j)
	if not str then
		return ""
	end
	local len = utf8_len(str)
	if i < 0 then
		i = len + i + 1
	end
	if j < 0 then
		j = len + j + 1
	end
	i, j = math.max(1, i), math.min(len, j)
	if i > j then
		return ""
	end
	return GLib.utf8_substring(str, i - 1, j)
end

local function preview_text(text, max_chars)
	if not text or text == "" then
		return ""
	end
	local clean = text:gsub("%s+", " ")
	clean = trim(clean)
	local len = utf8_len(clean)
	if len <= max_chars then
		return clean
	end
	local head = math.floor((max_chars - 3) / 2)
	local tail = max_chars - 3 - head
	return utf8_sub(clean, 1, head) .. "..." .. utf8_sub(clean, -tail, -1)
end

local function notify(text, opts)
	opts = opts or {}
	naughty.notify({
		title = CONFIG.icon .. " Claude",
		text = text,
		timeout = opts.timeout or 2,
		run = opts.run,
	})
end

local function parse_json_field(json, field)
	if not json then
		return nil
	end
	local pattern = '"' .. field .. '"%s*:%s*"(.-)"'
	local match = json:match(pattern)
	if match then
		return match:gsub("\\n", "\n"):gsub("\\t", "\t"):gsub('\\"', '"'):gsub("\\\\", "\\")
	end
	return nil
end

-- Rofi 样式生成
local function rofi_theme(opts)
	return string.format(
		[[
		window { width: %dpx; border-radius: 12px; }
		listview { lines: %d; spacing: %dpx; padding: 12px; }
		element { padding: %dpx 20px; border-radius: 8px; }
		element-text { font: "%s %d"; }
		element selected { background-color: %s; }
		inputbar { %s }
		message { padding: %dpx; }
		textbox { font: "%s %d"; text-color: %s; }
	]],
		opts.width or 500,
		opts.lines or 4,
		opts.spacing or 10,
		opts.padding or 14,
		CONFIG.font,
		opts.font_size or 18,
		CONFIG.accent_color,
		opts.inputbar or "enabled: false;",
		opts.msg_padding or 16,
		CONFIG.font,
		opts.msg_font_size or 14,
		opts.msg_color or CONFIG.text_color
	)
end

-- 获取剪贴板内容
local function get_clipboard(callback)
	awful.spawn.easy_async_with_shell(
		"xclip -o -selection primary 2>/dev/null || xclip -o -selection clipboard 2>/dev/null",
		function(stdout)
			callback(trim(stdout))
		end
	)
end

-- 显示结果
local function show_result(result, session_id)
	local result_lines = select(2, result:gsub("\n", "\n")) + 1
	local use_pager = result_lines > 15 or #result > 1000

	if use_pager then
		local tmpfile = os.tmpname()
		local f = io.open(tmpfile, "w")
		if f then
			f:write(result)
			f:close()
		end

		local items = {
			"1. 󰈈  在终端查看",
			"2. 󰆏  复制到剪贴板",
		}
		if session_id then
			table.insert(items, "3. " .. CONFIG.icon .. "  继续对话")
		end
		table.insert(items, #items + 1 .. ". 󰅖  关闭")

		local preview = preview_text(result, 80)
		local cmd = string.format(
			[[echo -e "%s" | rofi -dmenu -i -p "%s " -mesg %s -theme-str '%s']],
			table.concat(items, "\\n"),
			CONFIG.icon,
			safe_quote("📄 " .. preview .. " (" .. result_lines .. "行)"),
			rofi_theme({ width = 700, lines = #items, spacing = 8, padding = 12 })
		)

		awful.spawn.easy_async_with_shell(cmd, function(choice)
			choice = trim(choice)
			if choice:match("终端查看") then
				awful.spawn(string.format([[alacritty -e sh -c 'cat %s | less -R; rm %s']], tmpfile, tmpfile))
			elseif choice:match("复制") then
				awful.spawn.with_shell("cat " .. tmpfile .. " | xclip -selection clipboard && rm " .. tmpfile)
				notify("已复制到剪贴板")
			elseif choice:match("继续对话") and session_id then
				awful.spawn(string.format("alacritty -e %s --resume %s", CLAUDE_BIN, session_id))
				os.remove(tmpfile)
			else
				os.remove(tmpfile)
			end
		end)
	else
		local items = { "1. 󰆏  复制到剪贴板" }
		if session_id then
			table.insert(items, "2. " .. CONFIG.icon .. "  继续对话")
		end
		table.insert(items, #items + 1 .. ". 󰅖  关闭")

		local cmd = string.format(
			[[echo -e "%s" | rofi -dmenu -i -p "%s " -mesg %s -theme-str '%s']],
			table.concat(items, "\\n"),
			CONFIG.icon,
			safe_quote(result),
			rofi_theme({ width = 700, lines = #items, spacing = 8, padding = 12 })
		)

		awful.spawn.easy_async_with_shell(cmd, function(choice)
			choice = trim(choice)
			if choice:match("复制") then
				awful.spawn.with_shell("echo " .. safe_quote(result) .. " | xclip -selection clipboard")
				notify("已复制到剪贴板")
			elseif choice:match("继续对话") and session_id then
				awful.spawn(string.format("alacritty -e %s --resume %s", CLAUDE_BIN, session_id))
			end
		end)
	end
end

-- 主菜单
local MENU_ITEMS = {
	{ icon = "🔍", label = "问我的笔记", agent_id = "ask_notes", input_mode = true },
	{ icon = "📥", label = "保存到笔记", agent_id = "save_notes" },
	{ icon = "󰭙", label = "解释一下" },
	{ icon = "󰗊", label = "翻译成中文" },
	{ icon = "󰗊", label = "翻译成英文" },
	{ icon = "󰦨", label = "总结要点" },
}

function M.query()
	get_clipboard(function(selection)
		local menu = {}
		for i, item in ipairs(MENU_ITEMS) do
			if item.input_mode or selection ~= "" then
				table.insert(menu, string.format("%d. %s  %s", i, item.icon, item.label))
			end
		end

		if #menu == 0 then
			notify("没有选中文本")
			return
		end

		local preview = selection ~= "" and preview_text(selection, CONFIG.preview_max_chars) or "输入问题..."
		local cmd = string.format(
			[[echo -e "%s" | rofi -dmenu -i -p "%s " -mesg %s -theme-str '%s']],
			table.concat(menu, "\\n"),
			CONFIG.icon,
			safe_quote("󰄬 " .. preview),
			rofi_theme({
				lines = #menu,
				font_size = 20,
				inputbar = "padding: 16px;",
				msg_padding = 12,
				msg_color = CONFIG.muted_color,
				msg_font_size = 16,
			})
		)

		awful.spawn.easy_async_with_shell(cmd, function(choice)
			choice = trim(choice)
			if choice == "" then
				return
			end

			for _, item in ipairs(MENU_ITEMS) do
				if choice:match(item.label) then
					if item.agent_id then
						if item.input_mode then
							M.ask_input(item.agent_id, selection)
						else
							M.run_agent(item.agent_id, selection)
						end
					else
						M.run_claude(selection, item.label)
					end
					return
				end
			end
			M.run_claude(selection, choice)
		end)
	end)
end

function M.ask_input(agent_id, context)
	local agent = agents.get(agent_id)
	if not agent then
		notify("未找到 Agent: " .. agent_id)
		return
	end

	local has_context = context and context ~= ""
	local preview = has_context and preview_text(context, 40) or nil
	local mesg_opt = preview and string.format("-mesg %s", safe_quote("📋 " .. preview)) or ""

	local cmd = string.format(
		[[rofi -dmenu -p "%s %s" %s -theme-str '%s']],
		agent.icon or CONFIG.icon,
		agent.label,
		mesg_opt,
		rofi_theme({
			width = 800,
			lines = 0,
			inputbar = 'padding: 16px; font: "' .. CONFIG.font .. ' 16";',
			msg_padding = 10,
			msg_color = CONFIG.muted_color,
			msg_font_size = 12,
		})
	)

	awful.spawn.easy_async_with_shell(cmd, function(input)
		input = trim(input)
		if input == "" then
			return
		end

		local include_clipboard = input:match("^%+") or input:match("^＋")
		if include_clipboard then
			input = input:gsub("^[%+＋]%s*", "")
		end

		local extra = { input = input }
		if include_clipboard and has_context then
			extra.context = context
		end

		M.run_agent(agent_id, input, extra)
	end)
end

function M.run_claude(selection, prompt)
	notify("正在处理...")

	local cmd = string.format(
		[[echo %s | %s -p %s --tools "" --output-format json]],
		safe_quote(selection),
		CLAUDE_BIN,
		safe_quote(prompt)
	)

	awful.spawn.easy_async_with_shell(cmd, function(stdout, stderr, _, exit_code)
		local result = parse_json_field(stdout, "result")
		local session_id = parse_json_field(stdout, "session_id")

		if result and result ~= "" then
			show_result(result, session_id)
		else
			local err = trim(strip_ansi(stderr))
			if err == "" then
				err = "exit code: " .. (exit_code or "?")
			end
			notify("处理失败: " .. err, { timeout = 5 })
		end
	end)
end

function M.run_agent(agent_id, selection, extra_ctx)
	local agent = agents.get(agent_id)
	if not agent then
		notify("未找到 Agent: " .. agent_id, { timeout = 3 })
		return
	end

	notify("正在执行: " .. agent.label .. "...")

	local date = os.date("%Y-%m-%d")
	local save_dir = CONFIG.scratchpad_dir .. "/" .. date

	local ctx = {
		date = date,
		save_dir = save_dir,
		selection = selection,
	}
	if extra_ctx then
		for k, v in pairs(extra_ctx) do
			ctx[k] = v
		end
	end

	local prompt = type(agent.prompt) == "function" and agent.prompt(ctx) or agent.prompt
	local cfg = agent.config or {}

	local opts = {}
	if cfg.tools then
		table.insert(opts, string.format('--allowedTools "%s"', cfg.tools))
	end
	if agent.system_prompt then
		table.insert(opts, string.format("--system-prompt %s", safe_quote(agent.system_prompt)))
	end
	if cfg.max_turns then
		table.insert(opts, string.format("--max-turns %d", cfg.max_turns))
	end

	local cmd = string.format(
		[[echo %s | %s -p %s %s]],
		safe_quote(selection),
		CLAUDE_BIN,
		safe_quote(prompt),
		table.concat(opts, " ")
	)

	awful.spawn.easy_async_with_shell(cmd, function(stdout, stderr, _, exit_code)
		local result = trim(strip_ansi(stdout))
		if result ~= "" then
			if agent.on_success then
				local ret = agent.on_success(result, ctx)
				if ret and ret.action == "open_editor" then
					notify(ret.message .. "\n(点击打开)", {
						timeout = 5,
						run = function()
							awful.spawn(string.format("alacritty -e nvim %s", safe_quote(ret.file_path)))
						end,
					})
				elseif ret and ret.action == "show_result" then
					show_result(ret.message)
				else
					notify(ret and ret.message or result, { timeout = 5 })
				end
			else
				notify(result, { timeout = 5 })
			end
		else
			local err = trim(strip_ansi(stderr))
			if err == "" then
				err = "exit code: " .. (exit_code or "?")
			end
			notify("执行失败: " .. err, { timeout = 5 })
		end
	end)
end

-- ═══════════════════════════════════════════════════════════════
-- Claude Code Hook 通知
-- ═══════════════════════════════════════════════════════════════

local HOOK_EVENTS = {
	Stop = { icon = "󰄬", timeout = 0, sound = true, bg = nil, fg = nil },
	SubagentStop = { icon = "󰜎", timeout = 3, sound = false, bg = nil, fg = nil },
	Notification = { icon = "󰋼", timeout = 5, sound = true, bg = nil, fg = nil },
	PermissionRequest = { icon = "󰌆", timeout = 0, sound = true, bg = "#ff5555", fg = "#f8f8f2" },
}

local SOUND_CMD = "paplay /usr/share/sounds/freedesktop/stereo/message.oga"
local LOG_FILE = os.getenv("HOME") .. "/.claude/hook_debug.log"

-- 通过 window ID 聚焦窗口（用于通知点击跳转）
local function focus_window_by_id(window_id)
	if not window_id or window_id == "" then
		return false
	end
	local id = tonumber(window_id)
	if not id then
		return false
	end

	for _, c in ipairs(client.get()) do
		if c.window == id then
			-- 如果窗口被隐藏（如 scratch 窗口），先显示它
			if c.hidden then
				c.hidden = false
			end
			if c.first_tag then
				c.first_tag:view_only()
			end
			c:emit_signal("request::activate", "notification_click", { raise = true })
			return true
		end
	end
	return false
end

local function log(msg)
	local f = io.open(LOG_FILE, "a")
	if f then
		f:write(os.date("%H:%M:%S ") .. tostring(msg) .. "\n")
		f:close()
	end
end

local function b64decode(data)
	local handle = io.popen("echo '" .. data .. "' | base64 -d")
	if not handle then
		return nil
	end
	local result = handle:read("*a")
	handle:close()
	return result
end

function M.hook(b64_json)
	local json = b64decode(b64_json)
	if not json or json == "" then
		log("ERROR: json is nil or empty")
		return
	end

	log("JSON: " .. json:gsub("\n", " "))

	local event = parse_json_field(json, "hook_event_name")
	log("event: [" .. tostring(event) .. "]")
	if not event or event == "" then
		return
	end

	local cwd = parse_json_field(json, "cwd")
	local window_id = parse_json_field(json, "window_id")
	local last_message = parse_json_field(json, "last_message")
	local cfg = HOOK_EVENTS[event] or { icon = CONFIG.icon, timeout = 3, sound = false }

	log("window_id: [" .. tostring(window_id) .. "]")
	log("last_message: [" .. tostring(last_message or "") .. "]")

	-- 根据事件类型提取消息
	local message
	if event == "Stop" then
		-- 任务完成：优先显示最后的回复内容
		if last_message and last_message ~= "" then
			message = last_message
		else
			message = "任务完成"
		end
	elseif event == "SubagentStop" then
		if last_message and last_message ~= "" then
			message = last_message
		else
			message = "子任务完成"
		end
	elseif event == "Notification" then
		local msg = parse_json_field(json, "message")
		log("Notification msg: [" .. tostring(msg) .. "]")
		message = (msg and msg ~= "") and msg or "等待输入"
	elseif event == "PermissionRequest" then
		local tool = parse_json_field(json, "tool_name")
		log("PermissionRequest tool: [" .. tostring(tool) .. "]")
		tool = (tool and tool ~= "") and tool or "unknown"
		-- 显示工具名和参数摘要
		if last_message and last_message ~= "" then
			message = "🔐 " .. tool .. "\n" .. last_message
		else
			message = "🔐 请求授权: " .. tool
		end
	else
		message = event
	end

	log("message: [" .. tostring(message) .. "]")

	-- 格式：[项目名] 消息
	local text = message
	if cwd and cwd ~= "" then
		local project = cwd:match("([^/]+)$")
		if project and project ~= "" then
			text = "[" .. project .. "] " .. message
		end
	end

	log("text: [" .. tostring(text) .. "]")

	-- 跳过空通知
	if not text or text == "" then
		log("ERROR: text is empty, skipping notification")
		return
	end

	if cfg.sound then
		awful.spawn.with_shell(SOUND_CMD .. " &")
	end

	log(
		"NOTIFY: title=["
			.. cfg.icon
			.. " Claude] text=["
			.. tostring(text)
			.. "] timeout=["
			.. tostring(cfg.timeout)
			.. "] window_id=["
			.. tostring(window_id)
			.. "]"
	)

	local ok, err = pcall(function()
		local wid = tonumber(window_id)
		local notify_args = {
			title = cfg.icon .. " Claude",
			text = text,
			timeout = cfg.timeout,
			run = function(n)
				focus_window_by_id(window_id)
				active_notifications[n] = nil
				naughty.destroy(n) -- 点击后关闭通知
			end,
		}
		-- PermissionRequest 使用特殊颜色
		if cfg.bg then
			notify_args.bg = cfg.bg
		end
		if cfg.fg then
			notify_args.fg = cfg.fg
		end
		local n = naughty.notify(notify_args)
		-- 保存通知引用，用于聚焦时自动关闭
		if n and wid then
			active_notifications[n] = wid
			-- 通知被销毁时清理引用
			n:connect_signal("destroyed", function()
				active_notifications[n] = nil
			end)
		end
	end)

	if ok then
		log("NOTIFY: called successfully")
	else
		log("NOTIFY: failed - " .. tostring(err))
	end
end

-- 初始化：设置窗口聚焦时自动关闭对应通知
function M.init()
	client.connect_signal("focus", function(c)
		for notification, wid in pairs(active_notifications) do
			if c.window == wid then
				-- 聚焦到对应窗口时，3秒后关闭通知
				gears.timer.start_new(3, function()
					if active_notifications[notification] then
						active_notifications[notification] = nil
						naughty.destroy(notification)
					end
					return false -- 不重复执行
				end)
			end
		end
	end)
end

return M
