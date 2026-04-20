# 规则名称
命令行使用规范

# 规则摘要
命令行优先 RTK，专用工具优先于 Bash。

# 规则具体内容

## 优先使用 RTK
**所有命令默认优先使用 `rtk` 前缀**。常见场景：
- 构建测试：`rtk cargo build/check/test`、`rtk tsc`、`rtk mvn`、`rtk pytest`
- Git：`rtk git status/log/diff/add/commit/push`
- GitHub：`rtk gh pr view/checks`、`rtk gh run list`
- 包管理：`rtk pnpm install/list`、`rtk npm run`
- 文件搜索：`rtk ls`、`rtk grep`、`rtk find`、`rtk read`

命令链中每个命令都需要加 `rtk`：
```bash
rtk ls && rtk git status
```

## 专用工具优先
- 读文件 → `Read`
- 编辑文件 → `Edit`
- 搜索内容 → `Grep`
- 查找文件 → `Glob`
- 写文件 → `Write`

只在系统命令、Git 操作、构建测试、包管理等场景下使用 Bash 工具。
