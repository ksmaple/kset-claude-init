# quick-commit

## 描述

快速提交当前改动，自动生成简洁的 commit message。

## 使用方式

```bash
/quick-commit [可选的额外说明]
```

## 执行流程

1. 检查当前 git 状态
2. 若存在未暂存改动，自动暂存
3. 根据 diff 内容生成简洁的 commit message
4. 执行提交
5. 返回提交摘要

## 约束

- 不自动 push
- 有冲突时停止并提示
- message 使用中文（若项目要求英文则切换）
