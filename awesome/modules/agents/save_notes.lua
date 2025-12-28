local M = {}

M.id = "save_notes"
M.icon = "📥"
M.label = "保存到笔记"

M.config = {
	tools = "Bash(mkdir:*,ls:*,head:*),Read,Write",
	output_format = "text",
	max_turns = 20,
}

M.system_prompt =
	[[你是一个笔记整理助手。你的任务是将用户提供的内容整理成结构化的 Markdown 笔记。

规则：
- 总结要点，不要照搬原文（除非必要）
- 可使用 mermaid 图表、列表、代码块等
- 如果用户仅仅提供了URL, 你需要获取URL的内容在进行整理
- 笔记需包含 frontmatter（title, tags, created）
- 操作完成后只返回文件名（不含路径）]]

function M.prompt(ctx)
	return string.format(
		[=[工作目录: %s/

步骤：
1. 用 head -20 读取目录中 .md 文件的 frontmatter
2. 根据 tags/title 判断内容是否与现有文件相关
3. 相关 → 追加到该文件
4. 无关 → 创建新文件 %s-HHmm-标题.md

笔记格式：
---
title: 标题
tags: [tag1, tag2]
created: YYYY-MM-DD HH:mm
---
（整理后的内容）]=],
		ctx.save_dir,
		ctx.date
	)
end

function M.on_success(result, ctx)
	return {
		message = "已保存: " .. result,
		file_path = ctx.save_dir .. "/" .. result,
		action = "open_editor",
	}
end

return M
