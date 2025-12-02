local awful = require("awful")
local naughty = require("naughty")
local lgi = require("lgi")
local GLib = lgi.GLib

local M = {}

local function get_selection()
	local cmd = "xclip -o -selection primary 2>/dev/null || xclip -o -selection clipboard 2>/dev/null"
	local handle = io.popen(cmd)
	local result = handle:read("*a")
	handle:close()
	return result:gsub("^%s*(.-)%s*$", "%1")
end

local function preview_text(text, max_len)
	local preview = text:gsub("\n", " "):gsub("%s+", " ")
	if #preview > max_len then
		return preview:sub(1, 15) .. "..." .. preview:sub(-10)
	end
	return preview
end

local function show_result(result)
	local rofi_cmd = string.format(
		[[echo -e "1. 󰆏  复制到剪贴板\n2. 󰅖  关闭" | rofi -dmenu -i -p "󱜚 " -mesg %s -theme-str '
			window { width: 700px; border-radius: 12px; }
			listview { lines: 2; spacing: 8px; padding: 12px; }
			element { padding: 12px 20px; border-radius: 8px; }
			element-text { font: "JetBrains Mono Nerd Font 18"; }
			element selected { background-color: #bd93f9; }
			inputbar { enabled: false; }
			message { padding: 20px; }
			textbox { font: "JetBrains Mono 14"; text-color: #f8f8f2; }
		']],
		GLib.shell_quote(result)
	)

	awful.spawn.easy_async_with_shell(rofi_cmd, function(choice)
		choice = choice:gsub("\n", "")
		if choice:match("复制") then
			awful.spawn.with_shell("echo " .. GLib.shell_quote(result) .. " | xclip -selection clipboard")
			naughty.notify({
				title = "󱜚 Claude",
				text = "已复制到剪贴板",
				timeout = 2,
			})
		end
	end)
end

function M.query()
	local selection = get_selection()

	if selection == "" then
		naughty.notify({
			title = "󱜚 Claude",
			text = "没有选中文本",
			timeout = 2,
		})
		return
	end

	local preview = preview_text(selection, 30)

	local rofi_cmd = string.format(
		[[echo -e "1. 󰭙  解释一下\n2. 󰗊  翻译成中文\n3. 󰗊  翻译成英文\n4. 󰦨  总结要点" | rofi -dmenu -i -p "󱜚 " -mesg %s -theme-str '
			window { width: 500px; border-radius: 12px; }
			listview { lines: 4; spacing: 10px; padding: 12px; }
			element { padding: 14px 20px; border-radius: 8px; }
			element-text { font: "JetBrains Mono Nerd Font 20"; }
			element selected { background-color: #bd93f9; }
			inputbar { padding: 16px; }
			prompt { font: "JetBrains Mono Nerd Font 22"; text-color: #bd93f9; }
			entry { placeholder: "Ask anything"; }
			message { padding: 12px 16px; }
			textbox { text-color: #6272a4; font: "JetBrains Mono 16"; }
		']],
		GLib.shell_quote("󰄬 " .. preview)
	)

	awful.spawn.easy_async_with_shell(rofi_cmd, function(choice)
		choice = choice:gsub("\n", "")
		if choice == "" then
			return
		end

		local prompt = choice:gsub("^[0-9]*%. [^ ]*  ", "")
		if prompt == choice then
			prompt = choice
		end
		M.run_claude(selection, prompt)
	end)
end

function M.run_claude(selection, prompt)
	naughty.notify({
		title = "󱜚 Claude",
		text = "正在处理...",
		timeout = 2,
	})

	local cmd = string.format(
		[[cd ~/Documents/scratchpad && zsh -ic 'echo %s | claude -p %s']],
		GLib.shell_quote(selection),
		GLib.shell_quote(prompt)
	)

	awful.spawn.easy_async_with_shell(cmd, function(stdout, stderr, reason, exit_code)
		local result = stdout:gsub("^%s*(.-)%s*$", "%1")
		result = result:gsub("\027%[[0-9;]*[ -/]*[@-~]", "")
		result = result:gsub("^%s*(.-)%s*$", "%1")
		if result ~= "" then
			show_result(result)
		else
			local err_msg = stderr and stderr:gsub("^%s*(.-)%s*$", "%1") or ""
			if err_msg == "" then
				err_msg = string.format("exit: %s, code: %s", reason or "unknown", exit_code or "?")
			end
			naughty.notify({
				title = "󱜚 Claude",
				text = "处理失败: " .. err_msg,
				timeout = 5,
			})
		end
	end)
end

return M
