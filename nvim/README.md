# Neovim Configuration

English | [简体中文](./README_CN.md)

A modern, feature-rich Neovim configuration with AI integration, debugging support, and extensive customization.

## Features

- 🚀 **Lazy Loading** - Fast startup with lazy.nvim plugin manager
- 🤖 **AI Integration** - Claude Code, Copilot, and Avante support
- 🐛 **Debugging** - Full DAP support for C++, Go, Python, and Lua
- 🔍 **Fuzzy Finding** - Telescope with live grep and file search
- 📝 **LSP Support** - Complete language server integration with Mason
- 🎨 **Beautiful UI** - Dracula theme, bufferline, lualine, and dashboard
- ✂️ **Snippets** - LuaSnip with custom snippets for multiple languages
- 📦 **Git Integration** - Gitsigns and LazyGit

## Structure

```
nvim/
├── init.lua                    # Entry point
├── lua/user/
│   ├── preferences.lua         # Editor settings
│   ├── mappings.lua            # Core keybindings
│   ├── plugins.lua             # Plugin definitions
│   └── conf/
│       ├── theme/              # UI configuration
│       ├── lsp/                # Language server setup
│       └── plugins/            # Plugin configurations
├── luasnippets/                # Custom snippets
└── ftplugin/                   # Filetype settings
```

## Keybindings

Leader key: `<Space>`

### Basic Operations

| Key | Mode | Action |
|-----|------|--------|
| `S` | n | Save file |
| `Q` | n | Quit |
| `<C-q>` | i/v/s | Escape |
| `<Leader><Leader>` | n | Jump to next placeholder `<,.>` |

### Buffer Navigation

| Key | Mode | Action |
|-----|------|--------|
| `[b` / `]b` | n | Previous/Next buffer |
| `<Leader>[` / `<Leader>]` | n | Previous/Next buffer |
| `[B` / `]B` | n | First/Last buffer |
| `<Leader>1-9` | n | Go to buffer 1-9 |
| `gb` | n | Buffer picker |

### Window Navigation

| Key | Mode | Action |
|-----|------|--------|
| `<Leader>h/j/k/l` | n | Navigate windows |
| `<M-Up/Down>` | n | Resize height ±2 |
| `<M-Left/Right>` | n | Resize width ±2 |
| `<C-w>m` | n | Window shift mode |

### Search & Find (`<Leader>f`)

| Key | Action |
|-----|--------|
| `<Leader>ff` | Find files |
| `<Leader>fw` | Live grep with args |
| `<Leader>fb` | Find buffers |
| `<Leader>fh` | Recent files |
| `<Leader>fa` | Treesitter symbols |
| `<Leader>fz` | Find Chinese characters |

### LSP & Code Actions

| Key | Mode | Action |
|-----|------|--------|
| `gd` | n | Go to definition |
| `gD` | n | Go to declaration |
| `gi` | n | Go to implementation |
| `gy` | n | Go to type definition |
| `gr` | n | Show references |
| `K` | n | Hover documentation |
| `<Leader>ca` | n | Code action |
| `<Leader>rn` | n | Rename symbol |
| `<Leader>cd` | n | Line diagnostics |
| `<Leader>D` | n | Buffer diagnostics |
| `<Leader>-` / `<Leader>=` | n | Previous/Next diagnostic |
| `<Leader>rs` | n | Restart LSP |

### Git Operations (`<Leader>g`)

| Key | Action |
|-----|--------|
| `<Leader>gs` | Stage hunk |
| `<Leader>gr` | Reset hunk |
| `<Leader>gu` | Undo stage hunk |
| `<Leader>gS` | Stage buffer |
| `<Leader>gR` | Reset buffer |
| `<Leader>gp` | Preview hunk |
| `<Leader>gb` | Blame line |
| `<Leader>gd` | Diff this |
| `<Leader>gB` | Toggle line blame |
| `<Leader>g=` / `<Leader>g-` | Next/Previous hunk |
| `<C-g>` | Open LazyGit |

### Debugging (`<Leader>d`)

| Key | Action |
|-----|--------|
| `<F5>` | Continue/Start debug |
| `<F9>` | Toggle breakpoint |
| `<F10>` | Step over |
| `<F11>` | Step into |
| `<F12>` | Step out |
| `<Leader>db` | Toggle breakpoint |
| `<Leader>dB` | Conditional breakpoint |
| `<Leader>de` | Evaluate expression |
| `<Leader>do` | Toggle DAP REPL |
| `<Leader>dq` | Stop debugging |
| `<Leader>dl` | Load launch.json |
| `<Leader>du` / `<Leader>dd` | Stack frame up/down |
| `<Leader>dR` | Run to cursor |

### Claude Code (`<Leader>a`)

| Key | Mode | Action |
|-----|------|--------|
| `<Leader>ac` | n | Toggle Claude Code |
| `<Leader>af` | n | Focus Claude |
| `<Leader>ar` | n | Resume Claude |
| `<Leader>aC` | n | Continue Claude |
| `<Leader>am` | n | Select model |
| `<Leader>ab` | n | Add current buffer |
| `<Leader>as` | n/v | Send to Claude |
| `<Leader>aa` | n | Accept diff |
| `<Leader>ad` | n | Deny diff |

### Copilot

| Key | Mode | Action |
|-----|------|--------|
| `<Leader>co` | n | Toggle Copilot |
| `<Leader>ce` | n | Enable Copilot |
| `<Leader>cx` | n | Disable Copilot |
| `<C-l>` | i | Accept suggestion |

### Terminal

| Key | Action |
|-----|--------|
| `<C-\>` | Toggle floating terminal |
| `tg` | Toggle LazyGit |
| `tp` | Toggle IPython |
| `te` | Toggle EN→CN translator |
| `tc` | Toggle CN→EN translator |

### Navigation & Enhancement

| Key | Action |
|-----|--------|
| `<Leader>w` | Hop by word |
| `<Leader>/` | Hop by pattern |
| `<Leader>u` | Toggle undotree |
| `tt` | Toggle file tree |
| `<Leader>;` | Dropbar symbol picker |
| `[;` / `];` | Context navigation |

### Session Management (`<Leader>s`)

| Key | Action |
|-----|--------|
| `<Leader>ss` | Save session |
| `<Leader>sl` | Load session |

### Telescope Mappings (in picker)

| Key | Mode | Action |
|-----|------|--------|
| `<C-j>` / `<C-k>` | i | Move selection |
| `<C-n>` / `<C-p>` | i | Cycle history |
| `<C-x>` | i/n | Open horizontal split |
| `<C-v>` | i/n | Open vertical split |
| `<C-t>` | i/n | Open in new tab |
| `<C-e>` / `<C-d>` | i | Scroll preview up/down |
| `<C-q>` | i/n | Send to quickfix |

### Misc

| Key | Mode | Action |
|-----|------|--------|
| `<Leader><CR>` | n | Clear search highlight |
| `<` / `>` | n | Decrease/Increase indent |
| `Y` | v | Copy to system clipboard |
| `0` | n | Toggle line start/first char |
| `[t` / `]t` | n | Previous/Next todo comment |
| `<Leader>fk` | n | Make it rain animation |

## Requirements

- Neovim >= 0.9.0
- Git
- A Nerd Font for icons
- ripgrep for live grep
- Node.js for some LSP servers

## Installation

This config is part of [myconfig](https://github.com/iboomw/myconfig) dotfiles. Use the auto configuration script for easy setup:

```bash
# Clone the dotfiles repository
git clone https://github.com/iboomw/myconfig.git
cd myconfig

# Install only nvim config
./auto_config.sh -p nvim install

# Or force install (skip confirmation prompts)
./auto_config.sh -f -p nvim install

# Check installation status
./auto_config.sh -p nvim status

# Uninstall
./auto_config.sh -p nvim uninstall
```

The script will:
- Create a symlink from this directory to `~/.config/nvim`
- Backup existing config to `~/.config-backup-<timestamp>` if present
- Log installation details to `/tmp/auto-config-<timestamp>.log`

After installation, start Neovim and plugins will be installed automatically by lazy.nvim.

## License

MIT
