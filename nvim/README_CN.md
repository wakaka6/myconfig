# Neovim 配置

[English](./README.md) | 简体中文

一个现代化、功能丰富的 Neovim 配置，集成了 AI 辅助、调试支持和丰富的自定义功能。

## 特性

- 🚀 **懒加载** - 使用 lazy.nvim 插件管理器实现快速启动
- 🤖 **AI 集成** - 支持 Claude Code、Copilot 和 Avante
- 🐛 **调试支持** - 完整的 DAP 支持，适用于 C++、Go、Python 和 Lua
- 🔍 **模糊搜索** - Telescope 集成实时搜索和文件查找
- 📝 **LSP 支持** - 通过 Mason 完整集成语言服务器
- 🎨 **精美界面** - Dracula 主题、bufferline、lualine 和 dashboard
- ✂️ **代码片段** - LuaSnip 支持多语言自定义片段
- 📦 **Git 集成** - Gitsigns 和 LazyGit

## 目录结构

```
nvim/
├── init.lua                    # 入口文件
├── lua/user/
│   ├── preferences.lua         # 编辑器设置
│   ├── mappings.lua            # 核心快捷键
│   ├── plugins.lua             # 插件定义
│   └── conf/
│       ├── theme/              # 界面配置
│       ├── lsp/                # 语言服务器设置
│       └── plugins/            # 插件配置
├── luasnippets/                # 自定义代码片段
└── ftplugin/                   # 文件类型设置
```

## 快捷键

Leader 键: `<Space>`

### 基础操作

| 按键 | 模式 | 功能 |
|-----|------|------|
| `S` | n | 保存文件 |
| `Q` | n | 退出 |
| `<C-q>` | i/v/s | 退出到普通模式 |
| `<Leader><Leader>` | n | 跳转到下一个占位符 `<,.>` |

### Buffer 导航

| 按键 | 模式 | 功能 |
|-----|------|------|
| `[b` / `]b` | n | 上一个/下一个 buffer |
| `<Leader>[` / `<Leader>]` | n | 上一个/下一个 buffer |
| `[B` / `]B` | n | 第一个/最后一个 buffer |
| `<Leader>1-9` | n | 跳转到 buffer 1-9 |
| `gb` | n | Buffer 选择器 |

### 窗口导航

| 按键 | 模式 | 功能 |
|-----|------|------|
| `<Leader>h/j/k/l` | n | 窗口间导航 |
| `<M-Up/Down>` | n | 调整高度 ±2 |
| `<M-Left/Right>` | n | 调整宽度 ±2 |
| `<C-w>m` | n | 窗口移动模式 |

### 搜索和查找 (`<Leader>f`)

| 按键 | 功能 |
|-----|------|
| `<Leader>ff` | 查找文件 |
| `<Leader>fw` | 实时搜索文本 |
| `<Leader>fb` | 查找 buffer |
| `<Leader>fh` | 最近文件 |
| `<Leader>fa` | Treesitter 符号 |
| `<Leader>fz` | 查找中文字符 |

### LSP 和代码操作

| 按键 | 模式 | 功能 |
|-----|------|------|
| `gd` | n | 跳转到定义 |
| `gD` | n | 跳转到声明 |
| `gi` | n | 跳转到实现 |
| `gy` | n | 跳转到类型定义 |
| `gr` | n | 显示引用 |
| `K` | n | 悬停文档 |
| `<Leader>ca` | n | 代码操作 |
| `<Leader>rn` | n | 重命名符号 |
| `<Leader>cd` | n | 行诊断信息 |
| `<Leader>D` | n | Buffer 诊断信息 |
| `<Leader>-` / `<Leader>=` | n | 上一个/下一个诊断 |
| `<Leader>rs` | n | 重启 LSP |

### Git 操作 (`<Leader>g`)

| 按键 | 功能 |
|-----|------|
| `<Leader>gs` | 暂存 hunk |
| `<Leader>gr` | 重置 hunk |
| `<Leader>gu` | 撤销暂存 hunk |
| `<Leader>gS` | 暂存整个 buffer |
| `<Leader>gR` | 重置整个 buffer |
| `<Leader>gp` | 预览 hunk |
| `<Leader>gb` | 显示行 blame |
| `<Leader>gd` | 查看差异 |
| `<Leader>gB` | 切换行 blame 显示 |
| `<Leader>g=` / `<Leader>g-` | 下一个/上一个 hunk |
| `<C-g>` | 打开 LazyGit |

### 调试 (`<Leader>d`)

| 按键 | 功能 |
|-----|------|
| `<F5>` | 继续/开始调试 |
| `<F9>` | 切换断点 |
| `<F10>` | 单步跳过 |
| `<F11>` | 单步进入 |
| `<F12>` | 单步跳出 |
| `<Leader>db` | 切换断点 |
| `<Leader>dB` | 条件断点 |
| `<Leader>de` | 表达式求值 |
| `<Leader>do` | 切换 DAP REPL |
| `<Leader>dq` | 停止调试 |
| `<Leader>dl` | 加载 launch.json |
| `<Leader>du` / `<Leader>dd` | 调用栈上/下移动 |
| `<Leader>dR` | 运行到光标处 |

### Claude Code (`<Leader>a`)

| 按键 | 模式 | 功能 |
|-----|------|------|
| `<Leader>ac` | n | 切换 Claude Code |
| `<Leader>af` | n | 聚焦 Claude |
| `<Leader>ar` | n | 恢复 Claude |
| `<Leader>aC` | n | 继续 Claude |
| `<Leader>am` | n | 选择模型 |
| `<Leader>ab` | n | 添加当前 buffer |
| `<Leader>as` | n/v | 发送到 Claude |
| `<Leader>aa` | n | 接受差异 |
| `<Leader>ad` | n | 拒绝差异 |

### Copilot

| 按键 | 模式 | 功能 |
|-----|------|------|
| `<Leader>co` | n | 切换 Copilot |
| `<Leader>ce` | n | 启用 Copilot |
| `<Leader>cx` | n | 禁用 Copilot |
| `<C-l>` | i | 接受建议 |

### 终端

| 按键 | 功能 |
|-----|------|
| `<C-\>` | 切换浮动终端 |
| `tg` | 切换 LazyGit |
| `tp` | 切换 IPython |
| `te` | 切换英译中翻译器 |
| `tc` | 切换中译英翻译器 |

### 导航和增强

| 按键 | 功能 |
|-----|------|
| `<Leader>w` | 按单词跳转 |
| `<Leader>/` | 按模式跳转 |
| `<Leader>u` | 切换撤销树 |
| `tt` | 切换文件树 |
| `<Leader>;` | Dropbar 符号选择 |
| `[;` / `];` | 上下文导航 |

### 会话管理 (`<Leader>s`)

| 按键 | 功能 |
|-----|------|
| `<Leader>ss` | 保存会话 |
| `<Leader>sl` | 加载会话 |

### Telescope 快捷键 (选择器内)

| 按键 | 模式 | 功能 |
|-----|------|------|
| `<C-j>` / `<C-k>` | i | 移动选择 |
| `<C-n>` / `<C-p>` | i | 循环历史 |
| `<C-x>` | i/n | 水平分割打开 |
| `<C-v>` | i/n | 垂直分割打开 |
| `<C-t>` | i/n | 新标签页打开 |
| `<C-e>` / `<C-d>` | i | 预览上/下滚动 |
| `<C-q>` | i/n | 发送到 quickfix |

### 其他

| 按键 | 模式 | 功能 |
|-----|------|------|
| `<Leader><CR>` | n | 清除搜索高亮 |
| `<` / `>` | n | 减少/增加缩进 |
| `Y` | v | 复制到系统剪贴板 |
| `0` | n | 切换行首/首个非空字符 |
| `[t` / `]t` | n | 上一个/下一个 TODO 注释 |
| `<Leader>fk` | n | Make it rain 动画效果 |

## 系统要求

- Neovim >= 0.9.0
- Git
- Nerd Font 字体（用于图标显示）
- ripgrep（用于实时搜索）
- Node.js（部分 LSP 服务器需要）

## 安装

此配置是 [myconfig](https://github.com/iboomw/myconfig) dotfiles 的一部分。使用自动配置脚本可以轻松安装：

```bash
# 克隆 dotfiles 仓库
git clone https://github.com/iboomw/myconfig.git
cd myconfig

# 仅安装 nvim 配置
./auto_config.sh -p nvim install

# 或强制安装（跳过确认提示）
./auto_config.sh -f -p nvim install

# 检查安装状态
./auto_config.sh -p nvim status

# 卸载
./auto_config.sh -p nvim uninstall
```

脚本将会：
- 创建从此目录到 `~/.config/nvim` 的符号链接
- 如果存在现有配置，备份到 `~/.config-backup-<时间戳>`
- 安装日志保存到 `/tmp/auto-config-<时间戳>.log`

安装完成后，启动 Neovim，lazy.nvim 将自动安装所有插件。

## 许可证

MIT
