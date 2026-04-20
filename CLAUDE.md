# 项目级 Claude Code 指令

## 核心约束
- 优先编辑现有文件，拒绝过度工程化（YAGNI）
- 遵循项目已有风格，只在系统边界验证
- 复杂任务进 Plan Mode，多步骤用 Task 跟踪
- 破坏性操作需先确认

## 编码与语言
- 所有新建文件默认使用 **UTF-8** 编码
- 交互语言为**中文**，技术术语可保留英文

## 权限策略
- 本仓库为配置项目，**权限完全开放**
- 所有 Read/Edit/Write/Bash/Skill 操作均自动放行
- 在其他项目使用本配置时，请收紧权限

## 配置变更边界
- `CLAUDE.md` 和 `.claude/` 为**公共配置**，存放团队共享规则
- **后续配置变更默认优先在本地配置**（`CLAUDE.local.md` 及 `.claude.local/`）中更新
- 仅当用户明确要求"修改通用规则"、"更新公共配置"时，才修改公共配置

## 本地配置引导
处理任务前先读取 `CLAUDE.local.md`。

## 公共配置索引

| 规则 | 摘要 |
|------|------|
| `code-style` | 命名、格式、注释与修改纪律，拒绝过早抽象 |
| `testing` | 新功能/Bug 修复需附测试，聚焦行为 |
| `security` | 代码安全、依赖安全、密钥管理与泄露应急 |
| `cli-usage` | 命令行优先 RTK，专用工具优先于 Bash |
| `file-organization` | 临时文件统一放入 `tmp/` |
| `git-commit` | 中文提交信息，携带类型前缀 |
| `documentation-format` | 优先使用 Markdown |
| `rule-evolution` | 反复出现的模式自动提炼为规则 |

代理：`code-reviewer`、`debugger`  
技能：`fix-issue`、`git-commit`、`file-reader`

**加载原则**：公共配置为基线，本地配置补充并覆盖冲突项。

## 规则读取优化
`.claude/rules/` 下规则采用三段式结构（规则名称、规则摘要、规则具体内容）。
**读取时优先查看"规则摘要"，命中场景后再读取具体内容。**
