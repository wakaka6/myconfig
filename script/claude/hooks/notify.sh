#!/bin/bash
# Claude Code Hook -> AwesomeWM naughty

# 读取完整 stdin 到变量
json=$(cat)

# 检查是否为空
[ -z "$json" ] && exit 0

# Base64 编码并调用 awesome-client
awesome-client "require('modules.claude').hook('$(echo -n "$json" | base64 -w0)')"
