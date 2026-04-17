# AI Agent 通用规范

> 适用于 Claude Code、Codex、Cursor 及其他 AI 编程助手的共享行为准则。
> 以下内容通过 @引用 关联，请自动读取相关文件获取完整规则。

## 引用文件
- @CLAUDE.md — Claude Code 项目级指令（含配置变更边界与权限规则）
- @.claude/agents/code-reviewer.md — 代码审查代理规范
- @.claude/agents/debugger.md — 调试代理规范

## 配置变更边界

- **默认优先在本地个人配置中修改**（`CLAUDE.local.md`、`.claude.local/`）
- 仅当用户明确要求"修改通用规则"、"更新公共配置"时，才改动根目录 `CLAUDE.md`、`.claude/`、本文件 `AGENTS.md` 等公共配置
