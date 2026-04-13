# kset-claude-skills

一套可复用的 Claude Code 项目级配置模板，用于规范 AI 协作行为、减少上下文噪音、分离团队公共配置与个人本地偏好。

---

## 为什么需要这套配置

Claude Code 的 `CLAUDE.md` 会被自动注入到每次对话的系统提示中，但它很容易膨胀成一个巨大的文件。这套模板通过以下方式解决这一问题：

1. **主文件极致精简** — `CLAUDE.md` 只保留最核心的约束和权限规则（约 20 行）
2. **规则按需加载** — 代码风格、测试、安全、命令行等场景化规范存放在 `.claude/rules/*.md`，按任务类型模糊匹配读取
3. **公共与本地完全隔离** — 团队共享配置和个人自定义配置分目录存放，互不干扰
4. **统一的权限策略** — 查询类操作自动放行，写入类按任务授权，Git 安全操作有明确边界

---

## 目录结构

```
├── CLAUDE.md                    # 项目级核心指令（自动注入，保持精简）
├── CLAUDE.local.md              # 个人本地偏好（已 gitignore）
├── .gitignore
├── .claude/                     # 公共配置（提交到 Git）
│   ├── CLAUDE.md
│   ├── settings.json
│   ├── rules/                   # 按需加载的规则
│   │   ├── code-style.md
│   │   ├── testing.md
│   │   ├── security.md
│   │   ├── cli-usage.md
│   │   └── file-organization.md
│   ├── agents/                  # 子代理定义
│   │   ├── code-reviewer.md
│   │   └── debugger.md
│   └── skills/                  # 自定义技能
│       └── fix-issue/
│           └── SKILL.md
└── .claude.local/               # 本地配置（已 gitignore）
    ├── settings.json
    ├── rules/
    │   └── personal-preferences.md
    ├── agents/
    │   └── tech-lead.md
    └── skills/
        └── quick-commit/
            └── SKILL.md
```

---

## 核心设计

### 1. 按需加载规则

场景化规范不塞进 `CLAUDE.md`，而是存放在 `.claude/rules/`。Claude 根据任务关键词自动读取：

| 任务类型 | 匹配规则 |
|----------|----------|
| 写代码、重构 | `code-style.md` |
| 跑测试、补测试 | `testing.md` |
| 处理输入、引入依赖 | `security.md` |
| 执行命令、构建 | `cli-usage.md` |
| 生成文档、脚本 | `file-organization.md` |

这样新增规则时，只需在 `.claude/rules/` 下创建文件，并在 `CLAUDE.md` 的索引行中追加文件名即可。

### 2. 公共与本地配置隔离

```
.claude/          ← 团队共享，提交到 Git
.claude.local/    ← 个人本地，已被 .gitignore 忽略
```

**加载顺序**：
1. `CLAUDE.md` 建立基线
2. `CLAUDE.local.md` 加载个人偏好
3. `.claude/rules/*.md` 按需补充公共规则
4. `.claude.local/rules/*.md` 按需补充本地规则

**同名配置合并原则**：若 `.claude/` 与 `.claude.local/` 下存在同名的规则/代理/技能，**两者合并加载**。若内容冲突，以 `.claude.local/` 中的定义为准。

### 3. 权限策略

- **自动放行**：Read/Grep/Glob/WebSearch/Agent/Task/查询类 Bash/编译测试命令
- **写入优化**：单次任务中首次允许 `Edit/Write` 后，后续同类操作自动放行
- **Git 安全边界**：禁止自动 `git commit`；破坏性操作（`push --force`、`reset --hard` 等）需确认
- **需确认**：安装/卸载依赖、修改系统配置、对外可见操作（PR/评论/消息等）

---

## 快速应用到其他项目

### 方式一：直接复制

1. 将整个 `.claude/` 目录、`CLAUDE.md`、`CLAUDE.local.md` 复制到目标项目
2. 在目标项目的 `.gitignore` 中加入：
   ```
   .claude.local/
   ```
3. 根据个人需要，在 `.claude.local/` 下添加自己的规则/代理/技能

### 方式二：作为子模块/模板仓库

1. Fork 本仓库
2. 在新项目中通过 `git submodule` 或手动同步引入
3. 维护通用的 `.claude/` 内容，个人配置始终放在 `.claude.local/`

---

## 扩展配置

### 新增公共规则

1. 在 `.claude/rules/` 下新建 `xxx.md`
2. 在 `CLAUDE.md` 的"公共配置索引"规则行中追加文件名

### 新增个人本地规则

1. 在 `.claude.local/rules/` 下新建 `xxx.md`
2. 在 `CLAUDE.local.md` 的"本地配置索引"中追加路径
3. **无需修改 `CLAUDE.md`**

### 新增代理/技能

- 公共：`.claude/agents/*.md` 或 `.claude/skills/<name>/SKILL.md`
- 本地：`.claude.local/agents/*.md` 或 `.claude.local/skills/<name>/SKILL.md`

---

## 额外技术引用

### RTK（Rust Token Killer）

如果你希望进一步减少命令行输出带来的 token 消耗，可以引入 RTK。RTK 通过对常见开发命令的输出进行过滤和压缩，可减少 **60-90%** 的上下文噪音。

| 场景 | 示例命令 | 典型节省 |
|------|----------|----------|
| 构建 | `rtk cargo build`, `rtk tsc`, `rtk mvn` | 70-87% |
| 测试 | `rtk cargo test`, `rtk pytest`, `rtk vitest run` | 90-99% |
| Git | `rtk git status/log/diff/add/commit` | 59-80% |
| GitHub | `rtk gh pr view/checks`, `rtk gh run list` | 26-87% |
| 文件搜索 | `rtk ls`, `rtk grep`, `rtk find` | 60-75% |

**使用原则**：命令链中的每个命令都需要加 `rtk`：
```bash
rtk ls && rtk git status
```

- GitHub 仓库：[rtk-ai/rtk](https://github.com/rtk-ai/rtk)
