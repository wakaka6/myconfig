local awful = require("awful")
local naughty = require("naughty")
local lgi = require("lgi")
local GLib = lgi.GLib

local M = {}

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

-- 主菜单
local MENU_ITEMS = {
	{ icon = "󰭙", label = "解释一下" },
	{ icon = "󰗊", label = "翻译成中文" },
	{ icon = "󰗊", label = "翻译成英文" },
	{ icon = "󰦨", label = "总结要点" },
	{ icon = "📥", label = "保存到笔记", action = "save" },
}

function M.query()
	get_clipboard(function(selection)
		if selection == "" then
			notify("没有选中文本")
			return
		end

		local menu = {}
		for i, item in ipairs(MENU_ITEMS) do
			table.insert(menu, string.format("%d. %s  %s", i, item.icon, item.label))
		end

		local preview = preview_text(selection, CONFIG.preview_max_chars)
		local cmd = string.format(
			[[echo -e "%s" | rofi -dmenu -i -p "%s " -mesg %s -theme-str '%s']],
			table.concat(menu, "\\n"),
			CONFIG.icon,
			safe_quote("󰄬 " .. preview),
			rofi_theme({
				lines = #MENU_ITEMS,
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

			for i, item in ipairs(MENU_ITEMS) do
				if choice:match(item.label) then
					if item.action == "save" then
						M.save_to_notes(selection)
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

function M.save_to_notes(selection)
	notify("正在保存笔记...")

	local date = os.date("%Y-%m-%d")
	local save_dir = CONFIG.scratchpad_dir .. "/" .. date
	local prompt = string.format(
		[[目录: %s/

任务：
1. 用 head -20 读取目录中 .md 文件的 frontmatter（---包裹的 YAML）
2. 根据 tags/title 判断新内容是否与某文件主题相关
3. 相关：追加到该文件合适位置
4. 无关：创建 %s-HHmm-标题.md

笔记格式：
---
title: 标题
tags: [tag1, tag2]
created: YYYY-MM-DD HH:mm
---
总结要点，可用 mermaid 图表、列表、代码块等，只在有必要的情况下照搬原文。

只返回一行：操作的文件名（不含路径）]],
		save_dir,
		date
	)

	local cmd = string.format(
		[[echo %s | %s -p %s --allowedTools "Bash(mkdir:*,ls:*,head:*),Read,Write"]],
		safe_quote(selection),
		CLAUDE_BIN,
		safe_quote(prompt)
	)

	awful.spawn.easy_async_with_shell(cmd, function(stdout, stderr, _, exit_code)
		local result = trim(strip_ansi(stdout))
		if result ~= "" then
			local file_path = save_dir .. "/" .. result
			notify("已保存: " .. result .. "\n(点击打开)", {
				timeout = 5,
				run = function()
					awful.spawn(string.format("alacritty -e nvim %s", safe_quote(file_path)))
				end,
			})
		else
			local err = trim(strip_ansi(stderr))
			if err == "" then
				err = "exit code: " .. (exit_code or "?")
			end
			notify("保存失败: " .. err, { timeout = 5 })
		end
	end)
end

return M
