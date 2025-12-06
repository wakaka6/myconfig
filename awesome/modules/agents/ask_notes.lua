local M = {}

M.id = "ask_notes"
M.icon = "🔍"
M.label = "问我的笔记"

M.config = {
	tools = "Bash(rg:*,find:*,ls:*,head:*,wc:*,uname:*),Read",
	output_format = "text",
	max_turns = 15,
}

M.system_prompt =
	[[你是一个知识检索助手。用户会问你问题，你需要在他的本地文件中搜索答案。

## 搜索目录
按优先级搜索：
1. ~/Documents/scratchpad - 日常笔记
2. ~/Documents/studynote - 长期笔记
3. ~/.config - 配置文件（技术问题时搜索）
4. ~/code - 代码项目（编程问题时搜索）

## 搜索策略
1. 先分析问题，结合用户环境上下文，确定 2-3 个关键词（中英文都试）
2. 用 rg 搜索，示例：
   - rg -i "关键词" ~/Documents/scratchpad --type md
   - rg -i "keyword" ~/notes -l（只列文件名）
   - rg -C 3 "pattern" path（显示上下文）
3. 找到相关文件后，用 Read 工具读取完整内容
4. 如果第一轮没找到，换同义词/相关词再搜

## 重要
- 优先返回与用户当前环境匹配的结果
- 例如用户用 awesomewm，就不要返回 i3 的配置
- 例如用户用 arch linux，就优先返回 pacman 而非 apt

## 输出要求
- 回答问题，引用来源文件路径
- 如果找到多个相关内容，综合整理
- 如果没找到，明确告知"未在笔记中找到相关内容"
- 保持简洁，直接回答问题]]

local function get_env_context()
	local ctx_parts = {}

	local distro = io.popen("cat /etc/os-release 2>/dev/null | grep ^ID= | cut -d= -f2"):read("*l") or "unknown"
	table.insert(ctx_parts, "发行版: " .. distro)

	local de = os.getenv("XDG_CURRENT_DESKTOP") or os.getenv("DESKTOP_SESSION") or "unknown"
	table.insert(ctx_parts, "桌面环境: " .. de)

	local wm = io.popen("wmctrl -m 2>/dev/null | head -1 | cut -d: -f2"):read("*l")
	if wm then
		table.insert(ctx_parts, "窗口管理器: " .. wm:gsub("^%s+", ""))
	end

	local shell = os.getenv("SHELL") or "unknown"
	table.insert(ctx_parts, "Shell: " .. shell:match("[^/]+$"))

	local editor = os.getenv("EDITOR") or "unknown"
	table.insert(ctx_parts, "编辑器: " .. editor)

	local term = os.getenv("TERMINAL") or os.getenv("TERM") or "unknown"
	table.insert(ctx_parts, "终端: " .. term)

	return table.concat(ctx_parts, "\n")
end

function M.prompt(ctx)
	local question = ctx.input or ctx.selection or "（无输入）"
	local env_ctx = get_env_context()

	local context_section = ""
	if ctx.context and ctx.context ~= "" then
		context_section = string.format("\n\n## 参考内容（剪贴板）\n```\n%s\n```", ctx.context)
	end

	return string.format(
		[[## 用户环境
%s%s

## 问题
%s

请根据我的环境搜索笔记并回答。]],
		env_ctx,
		context_section,
		question
	)
end

function M.on_success(result, ctx)
	return {
		message = result,
		action = "show_result",
	}
end

return M
