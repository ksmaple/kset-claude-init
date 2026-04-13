# fix-issue

## 描述

自动分析并修复 GitHub Issue 或本地发现的 bug。

## 使用方式

```bash
/fix-issue <issue-number>
```

或

```bash
/fix-issue "<问题描述>"
```

## 执行流程

1. 读取 Issue 内容或解析问题描述
2. 定位相关代码文件
3. 分析问题根因
4. 实施修复
5. 运行相关测试验证修复
6. 生成修复摘要

## 约束

- 不引入破坏性变更
- 优先最小化修改
- 复杂修复需先进入 Plan Mode
