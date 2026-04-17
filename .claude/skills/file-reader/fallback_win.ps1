param(
    [Parameter(Mandatory = $true, Position = 0)]
    [string[]]$Paths
)

$TextExts = @(
    "txt","md","csv","json","xml","yaml","yml",
    "html","htm","css","js","ts","jsx","tsx",
    "py","java","go","rs","c","cpp","h","hpp",
    "cs","php","rb","swift","kt","scala","sh",
    "ps1","bat","cmd","vbs","lua","r","pl","sql"
)

$MaxSize = 2MB

function Optimize-Content([string]$Text) {
    $Text = $Text -replace "第\s*\d+\s*页\s*[\/共]?\s*\d*\s*页?",""
    $Text = $Text -replace "Page\s*\d+\s*of\s*\d+",""
    $Text = $Text -replace "^\s*[-=_]{3,}\s*$","",[System.Text.RegularExpressions.RegexOptions]::Multiline
    $Text = $Text -replace "^\s*\d+\s*\/\s*\d+\s*$","",[System.Text.RegularExpressions.RegexOptions]::Multiline
    $Text = $Text -replace "(\n\s*\n)\s*\n+","$1"
    $Text = $Text -replace "[ \t]+$","",[System.Text.RegularExpressions.RegexOptions]::Multiline
    return $Text.Trim()
}

function Make-Result($Path, $Size, $Time, $Cached, $Content, $Locations, $Metadata, $ErrorMsg) {
    $output = @()
    $output += "@F`t$Path`t$Size`t$Time`t$Cached`t$ErrorMsg"
    $output += "@C"
    $output += $Content
    $output += "@C"
    foreach ($loc in $Locations) {
        $metaJson = ($loc.meta | ConvertTo-Json -Depth 5 -Compress)
        $output += "@L`t$($loc.type)`t$($loc.value)`t$($loc.start)`t$($loc.end)`t$metaJson"
    }
    $metaParts = @()
    foreach ($k in $Metadata.Keys) {
        $v = $Metadata[$k] | ConvertTo-Json -Depth 5 -Compress
        $metaParts += "$k=$v"
    }
    if ($metaParts.Count -gt 0) {
        $output += "@M`t" + ($metaParts -join "`t")
    }
    $output += "@E"
    return $output -join "`n"
}

$allOutput = @()

foreach ($p in $Paths) {
    $ext = [System.IO.Path]::GetExtension($p).TrimStart('.').ToLower()
    $size = if (Test-Path $p) { (Get-Item $p).Length } else { 0 }

    if ($size -gt $MaxSize) {
        $mb = [math]::Round($size/1MB,2)
        $msg = "[文件过大] 大小 ${mb} MB，超过阈值 2 MB。请安装 Python 3.10+ 以获取分块读取支持。"
        $allOutput += (Make-Result $p $size 0 0 "" @() @{type=$ext} $msg)
        continue
    }

    if ($ext -in $TextExts) {
        try {
            $fullPath = (Get-Item $p).FullName
            $raw = [System.IO.File]::ReadAllText($fullPath)
            $lines = $raw -split "(?<=?
)"
            $locations = @()
            $offset = 0
            for ($i = 0; $i -lt $lines.Count; $i++) {
                $lineLen = $lines[$i].Length
                $locations += [ordered]@{
                    type = "line"
                    value = $i + 1
                    start = $offset
                    end = $offset + $lineLen
                    meta = @{}
                }
                $offset += $lineLen
            }
            $cleanContent = Optimize-Content $raw
            $allOutput += (Make-Result $p $size 0 0 $cleanContent $locations @{type=$ext; lines=$lines.Count} "")
        } catch {
            $allOutput += (Make-Result $p $size 0 0 "" @() @{type=$ext} $_.Exception.Message)
        }
    } else {
        $msg = "缺少 Python 环境，无法处理此格式。请安装 Python 3.10+ 及对应依赖（openpyxl/python-docx/pymupdf）。"
        $allOutput += (Make-Result $p $size 0 0 "" @() @{type=$ext} $msg)
    }
}

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
Write-Output ($allOutput -join "`n")
