# file-reader

## 描述

读取各类常见文件（xlsx、docx、md、pdf、txt 及开发类代码文件）并提取结构化内容。输出带位置索引的优化文本，减少 token 消耗；解析结果缓存于 `tmp/cache/file_reader/`，避免重复读取。支持并发批量读取与内容哈希二次校验，确保源文件更新后缓存自动失效。

## 使用方式

```bash
/file-reader <文件路径>
```

批量读取：

```bash
/file-reader <文件1> <文件2> ...
```

## 执行流程

1. **检查 Python 环境**：运行 `python --version` 或 `python3 --version`，确认 Python 3.10+ 可用
   - 若可用：调用 `python .claude/skills/file-reader/file_reader.py <paths...>`
   - 若不可用：进入[降级流程](#python-缺失时的降级流程)
2. 检查 `tmp/cache/file_reader/` 是否命中缓存（基于文件 mtime + size + content_hash）
3. 未命中时并发调用对应脚本提取内容
4. 解析紧凑格式输出，向用户展示带位置索引的文件内容
5. 若用户需要修改某处，直接通过 `locations` 中的 `type/value` 定位，无需重新读取全文

## Python 缺失时的降级流程

当系统未安装 Python 3.10+ 时，自动生成本地可用的临时 fallback 脚本：

1. **识别操作系统**
   - **Windows**：复制 `.claude/skills/file-reader/fallback_win.ps1` → `tmp/scripts/file-reader-fallback/read-file.ps1`，然后执行 `powershell -ExecutionPolicy Bypass -File tmp/scripts/file-reader-fallback/read-file.ps1 <paths...>`
   - **Unix / macOS**：复制 `.claude/skills/file-reader/fallback_unix.pl` → `tmp/scripts/file-reader-fallback/read-file.pl`，然后执行 `perl tmp/scripts/file-reader-fallback/read-file.pl <paths...>`
2. fallback 脚本可处理所有纯文本及代码文件（按行输出 `locations`），并自动过滤页眉页脚等噪声
3. 对 `xlsx/docx/pdf` 等二进制格式返回错误提示，引导用户安装 Python 3.10+ 及对应依赖
4. fallback 输出与主脚本格式兼容的紧凑格式，后续流程保持一致

## 输出格式（紧凑机器可读）

不再使用 JSON，改用 `	` 分隔的紧凑行格式，减少引号与转义冗余。每个文件输出如下：

```
@F	path	size	time_ms	cached	error
@C
<content 原始文本>
@C
@L	type	value	start	end	meta_json
@L	type	value	start	end	meta_json
@M	key=value	key=value
@E
```

### 行标记说明

| 标记 | 含义 | 示例 |
|------|------|------|
| `@F` | 文件头 | `@F	tmp/robot.xlsx	17898	9	1	` |
| `@C` | 内容块开始/结束 | 两个 `@C` 之间为原始文本，不转义换行 |
| `@L` | 位置索引 | `@L	line	42	0	15	{}` |
| `@M` | 元数据 | `@M	type="excel"	sheets=["Sheet1"]` |
| `@E` | 当前文件结束 | 多个文件时依次重复上述结构 |
| `@ERR` | 全局错误 | 参数缺失或 Python 版本不足时输出 |

## 位置索引类型

| 文件类型 | `type` | `value` 示例 | 说明 |
|----------|--------|--------------|------|
| Excel | `sheet_row` | `Sheet1:5` | 第 5 行 |
| Word | `paragraph` | `12` | 第 12 段 |
| Word | `table_cell` | `Table1:3` | 第 1 个表格的第 3 行 |
| PDF | `page` | `3` | 第 3 页（空页也保留占位） |
| 文本/代码 | `line` | `42` | 第 42 行 |

## 约束

- 默认跳过超过 2 MB 的大文件，仅返回结构摘要
- 自动过滤无意义内容（页眉页脚、重复空行、纯数字页码）
- **拒绝已知的纯二进制格式**：`.jpg`、`.png`、`.mp4`、`.zip`、`.exe`、`.doc`、`.ppt` 等直接返回错误，避免输出无意义乱码；错误信息中 `metadata.type` 会保留真实文件后缀而非 `unknown`
- 依赖按需提示：
  - `xlsx` → `openpyxl`
  - `docx` → `python-docx`
  - `pdf` → `pymupdf`（优先）或 `PyPDF2`
- `tmp/` 目录拥有完整读写权限，缓存操作无需额外确认

## 故障排查

### 缓存不生效或内容未更新

缓存基于 `mtime + size + content_hash`，若文件被外部工具修改但 `mtime` 未变，可手动清理缓存：

```bash
rm -rf tmp/cache/file_reader/*.json
```

缓存文件默认保留 7 天， skill 内部有 5% 概率自动触发过期清理。

### 依赖安装

```bash
pip install openpyxl python-docx pymupdf
```

### fallback 支持的扩展名

txt、md、csv、json、xml、yaml、yml、html、htm、css、js、ts、jsx、tsx、py、java、go、rs、c、cpp、h、hpp、cs、php、rb、swift、kt、scala、sh、ps1、bat、cmd、vbs、lua、r、pl、sql

### 编码问题

主脚本优先按 UTF-8 读取，失败时回退 GBK，再失败则使用 ISO-8859-1 并替换不可识别字符为 `�`，同时 `metadata.encoding` 会标注实际使用的编码。

## 作者

- 咔咔不太卡
