# 规则名称
命令行使用规范

# 规则摘要
规范命令行操作习惯：优先使用 RTK 减少输出 token，适配 Windows/Unix 环境，并优先使用专用工具而非 Bash。

# 规则具体内容

## 优先使用 RTK
**所有命令默认优先使用 `rtk` 前缀版本**。RTK 可显著减少输出 token，提升效率。

### 常见 RTK 场景
- **构建测试**: `rtk cargo build/check/test`, `rtk tsc`, `rtk vitest run`, `rtk playwright test`, `rtk mvn`, `rtk pytest`
- **Git**: `rtk git status/log/diff/add/commit/push`
- **GitHub**: `rtk gh pr view/checks`, `rtk gh run list`
- **包管理**: `rtk pnpm install/list`, `rtk npm run`
- **容器/K8s**: `rtk docker ps/logs`, `rtk kubectl get/logs`
- **文件搜索**: `rtk ls`, `rtk grep`, `rtk find`, `rtk read`

**命令链中每个命令都需要加 `rtk`**：
```bash
# 错误
ls && git status

# 正确
rtk ls && rtk git status
```

## 系统环境适配
- **Windows**: 优先使用 CMD/PowerShell 格式命令，路径用反斜杠 `\`；`rtk` 命令不受此限
- **Unix**: 使用标准 Unix shell 命令和正斜杠路径

## 专用工具优先
- 读文件 → `Read`
- 编辑文件 → `Edit`
- 搜索内容 → `Grep`
- 查找文件 → `Glob`
- 写文件 → `Write`

只在系统命令、Git 操作、构建测试、包管理等场景下使用 Bash 工具。
