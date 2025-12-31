#!/usr/bin/env python3
"""
Agent Tracker MCP Server
提供工具让 Claude 更新自己的会话描述
使用 stdio 通信方式
"""
import json
import os
import subprocess
import sys


def find_claude_pid():
    """遍历进程树向上查找 Claude 主进程 PID"""
    pid = os.getpid()
    while pid > 1:
        try:
            with open(f"/proc/{pid}/comm", "r") as f:
                comm = f.read().strip()
                if comm == "claude":
                    return pid
            # 解析 stat 文件获取 ppid（第 4 个字段）
            # 格式: pid (comm) state ppid ...
            with open(f"/proc/{pid}/stat", "r") as f:
                stat = f.read()
                # 找到 comm 结束的位置（最后一个 ')'）
                end_comm = stat.rfind(")")
                if end_comm > 0:
                    rest = stat[end_comm + 2 :].split()
                    pid = int(rest[1])  # state 后面是 ppid
                else:
                    break
        except (FileNotFoundError, IndexError, ValueError):
            break
    return None


def call_awesome_client(lua_code):
    """调用 awesome-client 执行 Lua 代码"""
    try:
        result = subprocess.run(
            ["awesome-client", lua_code],
            capture_output=True,
            text=True,
            timeout=5,
        )
        return result.returncode == 0
    except Exception:
        return False


def update_description(description):
    """更新当前会话的描述"""
    pid = find_claude_pid()
    if not pid:
        return {"success": False, "error": "Cannot find Claude process PID"}

    # 转义单引号
    desc_escaped = description.replace("'", "\\'")
    lua_code = f"require('modules.tracker').set_description({pid}, '{desc_escaped}')"

    if call_awesome_client(lua_code):
        return {"success": True, "pid": pid, "description": description}
    else:
        return {"success": False, "error": "Failed to call awesome-client"}


def handle_request(request):
    """处理 MCP 请求"""
    method = request.get("method", "")
    req_id = request.get("id")

    if method == "initialize":
        return {
            "jsonrpc": "2.0",
            "id": req_id,
            "result": {
                "protocolVersion": "2024-11-05",
                "capabilities": {"tools": {}},
                "serverInfo": {
                    "name": "tracker-server",
                    "version": "1.0.0",
                },
            },
        }

    elif method == "notifications/initialized":
        # 通知，无需响应
        return None

    elif method == "tools/list":
        return {
            "jsonrpc": "2.0",
            "id": req_id,
            "result": {
                "tools": [
                    {
                        "name": "update_description",
                        "description": "更新当前 Agent 会话的任务描述，显示在 AwesomeWM 的 wibar 中。用于描述当前正在进行的工作任务。",
                        "inputSchema": {
                            "type": "object",
                            "properties": {
                                "description": {
                                    "type": "string",
                                    "description": "任务描述，简短说明当前工作内容（建议 50 字符以内）",
                                }
                            },
                            "required": ["description"],
                        },
                    }
                ]
            },
        }

    elif method == "tools/call":
        tool_name = request.get("params", {}).get("name", "")
        arguments = request.get("params", {}).get("arguments", {})

        if tool_name == "update_description":
            description = arguments.get("description", "")
            result = update_description(description)
            return {
                "jsonrpc": "2.0",
                "id": req_id,
                "result": {
                    "content": [{"type": "text", "text": json.dumps(result)}]
                },
            }
        else:
            return {
                "jsonrpc": "2.0",
                "id": req_id,
                "error": {"code": -32601, "message": f"Unknown tool: {tool_name}"},
            }

    else:
        # 未知方法
        if req_id is not None:
            return {
                "jsonrpc": "2.0",
                "id": req_id,
                "error": {"code": -32601, "message": f"Unknown method: {method}"},
            }
        return None


def main():
    """主循环：从 stdin 读取请求，写入响应到 stdout"""
    while True:
        try:
            line = sys.stdin.readline()
            if not line:
                break

            request = json.loads(line)
            response = handle_request(request)

            if response is not None:
                sys.stdout.write(json.dumps(response) + "\n")
                sys.stdout.flush()

        except json.JSONDecodeError:
            continue
        except KeyboardInterrupt:
            break
        except Exception as e:
            sys.stderr.write(f"Error: {e}\n")
            sys.stderr.flush()


if __name__ == "__main__":
    main()
