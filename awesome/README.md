# AwesomeWM 配置

一个从 i3wm 迁移而来的 AwesomeWM 配置，支持多显示器环境自动适配。

## 特性

- **Vim 风格快捷键** - `Mod+hjkl` 导航，与 i3 习惯一致
- **多环境自动适配** - 自动检测显示器数量，切换工作空间布局
- **智能跨屏焦点** - 按物理方向跨屏幕切换焦点
- **Dracula 主题** - 统一的深色主题配色
- **Scratchpad 支持** - 下拉式浮动窗口
- **动态 Tag 管理** - 创建/删除/重命名工作空间
- **i3-gaps 风格** - 支持窗口间距调整
- **Agent 追踪** - 状态栏实时显示 Claude/Codex 等 AI Agent 会话状态

## 依赖

### 必需

```bash
sudo pacman -S awesome
```

### 推荐

```bash
sudo pacman -S --needed \
    picom \
    rofi \
    dunst \
    flameshot \
    alacritty \
    xss-lock \
    numlockx \
    xdotool \
    ttf-jetbrains-mono \
    noto-fonts-cjk \
    warpd  # 键盘鼠标控制
```

## 配置结构

```
~/.config/awesome/
├── rc.lua                 # 主配置入口
├── env/
│   └── detect.lua         # 环境检测（自动识别显示器数量）
├── modules/
│   ├── keys.lua           # 快捷键配置
│   ├── rules.lua          # 窗口规则
│   ├── scratchpad.lua     # 下拉窗口
│   ├── widgets.lua        # 系统监控组件（含 Agent 追踪器）
│   ├── tracker.lua        # 通用 Agent 会话追踪
│   ├── claude.lua         # Claude 通知处理
│   ├── tag_persist.lua    # 动态 Tag 持久化
│   └── autostart.lua      # 自启动程序
├── themes/
│   └── dracula/
│       └── theme.lua      # Dracula 主题
└── docs/
    └── claude-integration/
        └── README.md      # Claude 集成文档
```

## 快捷键

### 窗口导航

| 按键 | 功能 |
|------|------|
| `Mod+h/j/k/l` | 焦点移动（智能跨屏） |
| `Mod+Shift+h/j/k/l` | 交换窗口 / 移动浮动窗口 |
| `Mod+Tab` | 切换到上一个窗口 |
| `Mod+`` ` | 当前 tag 窗口循环 |
| `Alt+Tab` | Rofi 窗口切换器 |

### 工作空间

| 按键 | 功能 |
|------|------|
| `Mod+1-0` | 切换到工作空间 1-10 |
| `Mod+Shift+1-0` | 移动窗口到工作空间 |
| `Mod+Ctrl+a` | 创建新 tag |
| `Mod+Ctrl+d` | 删除空 tag |
| `Mod+Ctrl+r` | 重命名 tag |
| `Mod+Ctrl+f` | Rofi 搜索 tag |

### 屏幕

| 按键 | 功能 |
|------|------|
| `Mod+n/p` | 切换屏幕焦点 |
| `Mod+Shift+n/p` | 移动窗口到其他屏幕 |

### 窗口操作

| 按键 | 功能 |
|------|------|
| `Mod+Return` | 打开终端 |
| `Mod+Shift+q` | 关闭窗口 |
| `Mod+f` | 全屏切换 |
| `Mod+Shift+Space` | 浮动切换 |
| `Mod+x` | 最小化窗口 |
| `Mod+Shift+x` | 恢复隐藏窗口（智能选择） |
| `Mod+Ctrl+x` | 恢复所有隐藏窗口 |
| `Mod+Ctrl+t` | 窗口置顶 |

### 布局

| 按键 | 功能 |
|------|------|
| `Mod+e` | 循环切换布局 |
| `Mod+s` / `Mod+w` | Max 布局 |
| `Mod+Ctrl+h/l` | 调整主区宽度 |
| `Mod+Ctrl+k/j` | 调整主区窗口数量 |

### Gaps 模式

| 按键 | 功能 |
|------|------|
| `Mod+g` | 进入 gaps 模式 |
| `k` / `+` | 增加间距 |
| `j` / `-` | 减少间距 |
| `0` | 移除间距 |
| `d` | 恢复默认 |
| `Esc` | 退出模式 |

### 启动器

| 按键 | 功能 |
|------|------|
| `Mod+d` | Rofi 启动器 |
| `Mod+c` | 打开 Chrome |
| `Mod+t` | 翻译 Scratchpad |
| `F1` | Flameshot 截图 |
| `Mod+F1` | 显示快捷键帮助 |

### 鼠标控制 (warpd)

| 按键 | 功能 |
|------|------|
| `Mod+.` | Hint 模式（显示标签点击元素） |
| `Mod+Shift+.` | Grid 模式（网格二分法定位） |

### 系统

| 按键 | 功能 |
|------|------|
| `Mod+Shift+r` | 重载配置 |
| `Mod+Shift+e` | 退出 AwesomeWM |
| `Mod+Ctrl+Escape` | 锁屏 |

### 媒体键

| 按键 | 功能 |
|------|------|
| `XF86AudioRaiseVolume` | 音量 +5% |
| `XF86AudioLowerVolume` | 音量 -5% |
| `XF86AudioMute` | 静音切换 |
| `XF86MonBrightnessUp/Down` | 亮度调节 |

## 多显示器配置

配置会自动检测显示器数量并切换布局：

| 屏幕数 | 环境 | 说明 |
|--------|------|------|
| 1 | single | 所有工作空间在一个屏幕 |
| 2 | home | 主/副屏各有独立工作空间 |
| 3+ | office | 三屏独立工作空间分配 |

如需自定义，编辑 `env/detect.lua`。

## 自定义

### 添加窗口规则

编辑 `modules/rules.lua`：

```lua
-- 让程序总是浮动
table.insert(rules, {
    rule = { class = "Pavucontrol" },
    properties = {
        floating = true,
        placement = awful.placement.centered,
    }
})

-- 让程序固定在某个工作空间
table.insert(rules, {
    rule = { class = "Slack" },
    properties = {
        screen = 2,
        tag = "chat",
    }
})
```

### 获取窗口 class

```bash
xprop | grep WM_CLASS
```

### 添加 Scratchpad

编辑 `modules/scratchpad.lua` 添加新的 scratchpad，然后在 `modules/keys.lua` 绑定快捷键。

## 常用命令

```bash
# 检查配置语法
awesome -k

# 重载配置
echo 'awesome.restart()' | awesome-client

# 查看显示器
xrandr --query | grep " connected"

# 列出窗口
wmctrl -l
```

## 参考

- [AwesomeWM 文档](https://awesomewm.org/doc/api/)
- [AwesomeWM Wiki](https://github.com/awesomeWM/awesome/wiki)
- [Dracula Theme](https://draculatheme.com/)

## License

MIT
