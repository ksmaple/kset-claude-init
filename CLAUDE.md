# 项目级 Claude Code 指令

## 核心约束
- 优先编辑现有文件，拒绝过度工程化（YAGNI），不添加未请求的功能
- 遵循项目已有风格，不为一次性操作创建抽象，只在系统边界验证
- 修改前阅读上下文，复杂任务进 Plan Mode，多步骤用 Task 跟踪
- 破坏性操作（删除、强制推送、降级依赖等）需先确认

## 编码与语言
- 所有新建文件默认使用 **UTF-8** 编码
- 交互语言为**中文**，技术术语可保留英文

## 权限规则
- **自动放行**：Read/Grep/Glob/WebSearch/WebFetch/Agent/Task/查询类 Bash/常用编译测试命令（mvn/java/python/pip/pytest/javac/jsp 等）
- **写操作**：单次任务首允后，后续同类 Edit/Write 自动放行；关键配置（CI/CD、凭证、基础设施）除外
- **Git 限制**：禁止自动 `git commit`；push --force/reset --hard 等破坏性操作需确认
- **需确认**：安装/卸载依赖、修改系统配置、对外可见操作（PR/评论/消息等）

## 本地配置引导
**处理任务前先读取 `CLAUDE.local.md`。**

## 公共配置索引（按需模糊匹配）
规则：`.claude/rules/code-style.md`、`.claude/rules/testing.md`、`.claude/rules/security.md`、`.claude/rules/cli-usage.md`、`.claude/rules/file-organization.md`  
代理：`.claude/agents/code-reviewer.md`、`.claude/agents/debugger.md`  
技能：`.claude/skills/fix-issue/SKILL.md`

**加载原则**：公共配置为基线，本地配置（`CLAUDE.local.md` 及 `.claude.local/`）补充并覆盖冲突项。同名配置**合并加载**，冲突时以本地为准。
