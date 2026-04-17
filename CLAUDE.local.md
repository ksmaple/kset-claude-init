# 个人项目偏好

## 代码习惯
- 优先修复根因，不绕过硬编码的安全检查
- 不确定时先提问，不盲目猜测实现
- 关键改动后说明影响范围

## 本地配置索引
- `.claude.local/rules/personal-preferences.md`
- `.claude.local/agents/tech-lead.md`
- `.claude.local/skills/quick-commit/SKILL.md`

## 配置变更边界
- **`CLAUDE.local.md` 和 `.claude.local/` 为本地个人配置目录**
- **后续所有配置变更，默认优先在此更新**
- 只有当用户明确要求"修改通用规则"、"更新公共配置"时，才修改 `CLAUDE.md` 或 `.claude/` 下的文件

**加载原则**：本地配置与公共配置同名时**合并加载**，本地内容补充并覆盖冲突项。
