# kset-claude-skills

一套可复用的 Claude Code 项目级配置模板，用于规范 AI 协作行为、减少上下文噪音、分离团队公共配置与个人本地偏好。

---

## 它能解决什么问题

使用 Claude Code 时，你是否遇到过这些情况：

- **上下文膨胀**：Claude 每次都把大量无关的命令输出塞进对话，导致 token 消耗飙升
- **行为不一致**：不同会话中 Claude 的代码风格、修改粒度、权限边界忽松忽紧
- **个人偏好难以沉淀**：团队项目的 `CLAUDE.md` 不方便写入太多个性化内容，但个人偏好又需要每次重新说明
- **主文件越来越长**：把所有规则都塞进 `CLAUDE.md`，导致核心约束被淹没在细节里

这套模板通过四个设计来解决上述问题：

1. **主文件极致精简** — `CLAUDE.md` 只保留最核心的约束、权限规则和配置索引，不堆砌场景化细节
2. **规则按需加载** — 代码风格、测试、安全、命令行等场景化规范存放在 `.claude/rules/*.md`，按任务类型模糊匹配读取
3. **公共与本地完全隔离** — 团队共享配置和个人自定义配置分目录存放，互不干扰
4. **统一的权限策略** — 查询类操作自动放行，写入类按任务授权，Git 安全操作有明确边界

---

## 工作原理

Claude Code 会在每次对话开始时自动读取项目根目录的 `CLAUDE.md` 和 `CLAUDE.local.md`，将其内容注入到系统提示中。

本模板的设计理念是：

- **`CLAUDE.md`** = 高速公路指示牌。只写最核心、最通用的约束和权限规则，让 Claude 在每次对话开始时就明确行为边界。
- **`.claude/rules/*.md`** = 服务区手册。只有在 Claude 实际执行某类任务时（如写代码、跑测试、执行命令），才按需读取对应的规则文件。
- **`.claude.local/`** = 你的私人驾照备注。存放个人偏好，完全不影响团队共享的公共配置。

---

## 目录说明

```
├── CLAUDE.md                    # 项目级核心指令（自动注入，保持精简）
├── CLAUDE.local.md              # 个人本地偏好（已 gitignore，需手动创建）
├── .gitignore
├── .claude/                     # 公共配置（提交到 Git）
│   ├── settings.json            # 公共结构化配置
│   ├── rules/                   # 按需加载的规则
│   │   ├── code-style.md        # 代码风格与命名规范
│   │   ├── testing.md           # 测试规范与原则
│   │   ├── security.md          # 安全要求与数据处理
│   │   ├── cli-usage.md         # 命令行使用规范与 RTK
│   │   ├── file-organization.md # 文件与目录规范
│   │   ├── git-commit.md        # Git 提交规范
│   │   └── rule-evolution.md    # 规则自主优化
│   ├── agents/                  # 子代理定义
│   │   ├── code-reviewer.md     # 代码审查代理
│   │   └── debugger.md          # 调试代理
│   └── skills/                  # 自定义技能
│       ├── fix-issue/
│       │   └── SKILL.md         # 修复 Issue 技能
│       └── git-commit/
│           └── SKILL.md         # 生成提交信息技能
└── .claude.local/               # 本地配置（已 gitignore）
    ├── rules/
    │   └── personal-preferences.md
    ├── agents/
    │   └── tech-lead.md
    └── skills/
        └── quick-commit/
            └── SKILL.md
```

### 关键文件详解

| 文件 | 作用 | 是否注入系统提示 |
|------|------|-----------------|
| `CLAUDE.md` | 项目级核心约束、权限规则、公共配置索引、规则读取优化说明 | 是（每次对话自动注入） |
| `CLAUDE.local.md` | 个人本地偏好、本地配置索引 | 是（每次对话自动注入） |
| `.claude/settings.json` | 结构化公共配置（自动加载规则列表、权限声明、偏好开关） | 否（供人或工具读取） |
| `.claude.local/settings.json` | 结构化本地配置（按需创建，已 gitignore） | 否（供人或工具读取） |
| `.claude/rules/*.md` | 场景化规则，按需读取。统一采用三段式结构（规则名称、规则摘要、规则具体内容） | 否（按需加载） |
| `.claude/agents/*.md` | 子代理定义，按需使用 | 否（按需加载） |
| `.claude/skills/*/SKILL.md` | 自定义技能定义，按需使用 | 否（按需加载） |

---

## 本地个人配置的用途

`.claude.local/` 和 `CLAUDE.local.md` 的设计初衷是：让**同一份公共配置**能够适配**不同的使用者、业务场景和个人习惯**，而无需修改团队共享的文件。

### 适合放在本地配置中的内容

- **个人沟通偏好**：回复长度、语言风格、是否展示详细推理过程
- **业务领域规则**：前端开发者可以加上 React/Vue 组件规范，后端开发者可以加上 API 设计或数据库规范
- **特定技术栈习惯**：Java 开发者强调 Lombok/Stream 使用方式，Python 开发者强调类型注解/PEP8 细则
- **个人快捷技能**：自己常用的 commit message 生成、代码片段模板、专属调试代理
- **实验性规则**：想试水的新规则，先在本地跑通，成熟后再提进公共配置

### 公共 vs 本地配置的边界

| 类型 | 示例 | 放置位置 |
|------|------|----------|
| 团队统一的代码规范 | 命名规范、lint 规则、提交前必须过测试 | `.claude/rules/` |
| 个人喜欢的响应风格 | "保持简洁"、"避免过度总结" | `CLAUDE.local.md` 或 `.claude.local/rules/` |
| 通用的安全要求 | 不信任用户输入、敏感信息不硬编码 | `.claude/rules/security.md` |
| 个人的技术栈偏好 | "优先使用函数式组件"、"数据库字段用 snake_case" | `.claude.local/rules/` |
| 团队共享的技能 | 修复 Issue 的标准流程 | `.claude/skills/` |
| 个人的快捷技能 | 自动生成 commit message | `.claude.local/skills/` |

### 多角色/多业务切换示例

如果你同时负责 Web 前端和 CLI 工具开发，可以在 `.claude.local/rules/` 下创建：

- `frontend.md` — React/Vue 组件设计规范
- `cli-dev.md` — CLI 参数解析和错误输出规范

然后在 `CLAUDE.local.md` 中按需引用它们。Claude 会根据你的提问自动模糊匹配，无需手动切换。

---

## 快速开始

### 第一步：复制文件到目标项目

将以下文件/目录复制到你的项目根目录：

```bash
cp -r /path/to/kset-claude-skills/.claude/ ./
cp /path/to/kset-claude-skills/CLAUDE.md ./
```

### 第二步：创建本地偏好文件

在项目根目录创建 `CLAUDE.local.md`，内容可参考：

```markdown
# 个人本地偏好

## 代码习惯
- 优先修复根因
- 不确定时先提问

## 本地配置索引
- `.claude.local/rules/personal-preferences.md`
```

### 第三步：配置 .gitignore

确保以下项被忽略，防止个人配置被误提交：

```
.claude.local/
CLAUDE.local.md
.claude/settings.local.json
```

### 第四步：验证生效

打开 Claude Code，发送任意消息。如果 Claude 的行为出现以下变化，说明配置已生效：

- 执行 `git status` 等查询命令时自动放行，不再反复询问
- 编辑文件时首次确认后，后续同类操作自动放行
- 提到"写测试"时，会主动引用 `.claude/rules/testing.md`
- 提到"提交"时，会主动引用 `.claude/rules/git-commit.md`，并使用 `/git-commit` 生成提交信息
- 反复使用某个未文档化的模式时，会自动在 `.claude.local/rules/` 下生成为本地规则
- 提到"命令"时，会优先使用 `rtk` 前缀（如果已安装 RTK）

---

## 配置详解

### CLAUDE.md 中的核心约束

```markdown
## 核心约束
- 优先编辑现有文件，拒绝过度工程化（YAGNI），不添加未请求的功能
- 遵循项目已有风格，不为一次性操作创建抽象，只在系统边界验证
- 修改前阅读上下文，复杂任务进 Plan Mode，多步骤用 Task 跟踪
- 破坏性操作（删除、强制推送、降级依赖等）需先确认
```

**解读**：
- **YAGNI**：不要为未来可能的需求写代码
- **不创建抽象**：三个相似的代码块，不要急着提取成一个"通用函数"
- **系统边界验证**：只在外部输入、外部 API 处做校验，信任内部代码
- **Plan Mode**：复杂改动前先向用户确认方案

### 权限规则

```markdown
## 权限规则
- **自动放行**：Read/Grep/Glob/WebSearch/WebFetch/Agent/Task/查询类 Bash/常用编译测试命令
- **写操作**：单次任务首允后，后续同类 Edit/Write 自动放行；关键配置（CI/CD、凭证、基础设施）除外
- **Git 限制**：禁止自动 `git commit`；push --force/reset --hard 等破坏性操作需确认
- **需确认**：安装/卸载依赖、修改系统配置、对外可见操作（PR/评论/消息等）
```

**解读**：
- 查询类操作（读文件、搜索、看日志）完全信任，不再打扰
- 写操作采用"首允即通"策略：你同意一次编辑后，本次对话中的后续编辑自动放行
- `git commit` 必须你主动要求才会执行，防止 Claude"自作主张"提交

### 按需加载规则

`CLAUDE.md` 中只列出配置索引，不展开规则内容。当 Claude 执行具体任务时，会根据关键词模糊匹配读取：

| 任务关键词 | 自动读取的规则 |
|-----------|---------------|
| "写代码"、"重构"、"命名" | `.claude/rules/code-style.md` |
| "测试"、"补测试"、"pytest" | `.claude/rules/testing.md` |
| "安全"、"输入验证"、"依赖" | `.claude/rules/security.md` |
| "命令"、"构建"、"mvn"、"rtk" | `.claude/rules/cli-usage.md` |
| "文档"、"脚本"、"临时文件" | `.claude/rules/file-organization.md` |
| "提交"、"commit"、"提交信息" | `.claude/rules/git-commit.md` |
| "提炼规则"、"新规则"、"规则优化" | `.claude/rules/rule-evolution.md` |

**加载优先级**：
1. `CLAUDE.md` 建立基线
2. `CLAUDE.local.md` 加载个人偏好
3. `.claude/rules/*.md` 按需补充公共规则
4. `.claude.local/rules/*.md` 按需补充本地规则

**同名配置合并原则**：若公共与本地存在同名规则，**两者合并加载**。内容冲突时以本地为准。

### 规则读取优化

`.claude/rules/` 下的规则文件统一采用三段式结构：

1. **规则名称** — 标识规则主题
2. **规则摘要** — 一句话概括核心内容
3. **规则具体内容** — 详细的约束、示例和说明

**读取时优先查看"规则摘要"，只有摘要内容命中当前任务场景时，才继续读取"规则具体内容"**。此机制用于减少无关规则对上下文的占用，避免 token 膨胀。

---

## 自定义扩展

### 新增公共规则

1. 在 `.claude/rules/` 下新建 `xxx.md`，建议采用三段式结构，例如 `api-design.md`：
   ```markdown
   # 规则名称
   API 设计规范

   # 规则摘要
   统一 RESTful API 设计风格，规范版本号放置位置和请求响应格式。

   # 规则具体内容
   - 使用 RESTful 风格
   - 接口版本号放在 URL 中
   ```
2. 在 `CLAUDE.md` 的"公共配置索引"规则行中追加文件名：
   ```markdown
   规则：...、`.claude/rules/api-design.md`
   ```

### 新增个人本地规则

1. 在 `.claude.local/rules/` 下新建 `xxx.md`
2. 在 `CLAUDE.local.md` 的"本地配置索引"中追加路径
3. **无需修改 `CLAUDE.md`**

### 新增代理/技能

- **代理**：在 `.claude/agents/`（公共）或 `.claude.local/agents/`（本地）下新建 `*.md`
- **技能**：在 `.claude/skills/<name>/`（公共）或 `.claude.local/skills/<name>/`（本地）下新建 `SKILL.md`

---

## 最佳实践

### 1. 保持 `CLAUDE.md` 精简

如果 `CLAUDE.md` 超过 40 行，说明你把太多细节塞进去了。考虑将场景化内容提取到 `.claude/rules/`。

### 2. 公共配置写通用的，本地配置写个性的

- **公共**：代码风格、测试规范、安全要求、Git 提交规范（团队统一）
- **本地**：喜欢的响应长度、习惯的技术栈偏好、个人常用的快捷技能

### 3. 及时清理临时文件

根据 `file-organization.md`，临时文档和脚本应放在 `tmp/docs/` 和 `tmp/scripts/`。任务结束后主动清理，保持项目整洁。

### 4. 结合 RTK 进一步降本

如果项目中经常执行构建、测试、Git 命令，推荐安装 RTK。RTK 通过过滤命令输出噪音，可减少 **60-90%** 的上下文 token 消耗。

| 场景 | 示例命令 | 典型节省 |
|------|----------|----------|
| 构建 | `rtk cargo build`, `rtk tsc`, `rtk mvn` | 70-87% |
| 测试 | `rtk cargo test`, `rtk pytest`, `rtk vitest run` | 90-99% |
| Git | `rtk git status/log/diff/add/commit` | 59-80% |
| 文件搜索 | `rtk ls`, `rtk grep`, `rtk find` | 60-75% |

**使用原则**：命令链中的每个命令都需要加 `rtk`：
```bash
rtk ls && rtk git status
```

- GitHub 仓库：[rtk-ai/rtk](https://github.com/rtk-ai/rtk)

---

## 参考文献

- [Claude Code 官方文档 - How Claude Code Works](https://code.claude.com/docs/zh-CN/how-claude-code-works)
- [知乎 - Claude Code 项目级配置最佳实践](https://zhuanlan.zhihu.com/p/2009744974980331332)
- [RTK - Rust Token Killer](https://github.com/rtk-ai/rtk)

---

## 许可证

MIT
