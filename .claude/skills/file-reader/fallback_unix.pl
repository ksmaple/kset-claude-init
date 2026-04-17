#!/usr/bin/env perl
use strict;
use warnings;
use JSON::PP qw(encode_json);
use Encode qw(decode);

my @TEXT_EXTS = qw(
    txt md csv json xml yaml yml html htm css js ts jsx tsx
    py java go rs c cpp h hpp cs php rb swift kt scala sh
    ps1 bat cmd vbs lua r pl sql
);
my %TEXT_MAP = map { $_ => 1 } @TEXT_EXTS;

my @BINARY_EXTS = qw(
    jpg jpeg png gif bmp webp ico svgz
    mp3 mp4 avi mov mkv flv wmv
    zip rar 7z tar gz bz2 xz
    exe dll so dylib bin o obj
    doc ppt pptx mdb
);
my %BINARY_MAP = map { $_ => 1 } @BINARY_EXTS;

my $MAX_SIZE = 2 * 1024 * 1024;

sub optimize_content {
    my ($text) = @_;
    $text =~ s/第\s*\d+\s*页\s*[\/共]?\s*\d*\s*页?//g;
    $text =~ s/Page\s*\d+\s*of\s*\d+//g;
    $text =~ s/^\s*[-=_]{3,}\s*$//mg;
    $text =~ s/^\s*\d+\s*\/\s*\d+\s*$//mg;
    $text =~ s/(\n\s*\n)\s*\n+/$1/g;
    $text =~ s/[ \t]+$//mg;
    $text =~ s/^\s+|\s+$//g;
    return $text;
}

sub make_result {
    my ($path, $size, $time, $cached, $content, $locations, $metadata, $error) = @_;
    my @out;
    push @out, "@F\t$path\t$size\t$time\t$cached\t$error";
    push @out, "@C";
    push @out, $content;
    push @out, "@C";
    for my $loc (@$locations) {
        my $meta = encode_json($loc->{meta} // {});
        push @out, "@L\t$loc->{type}\t$loc->{value}\t$loc->{start}\t$loc->{end}\t$meta";
    }
    my @meta_parts;
    for my $k (sort keys %$metadata) {
        my $v = encode_json($metadata->{$k});
        push @meta_parts, "$k=$v";
    }
    if (@meta_parts) {
        push @out, "@M\t" . join("\t", @meta_parts);
    }
    push @out, "@E";
    return join("\n", @out);
}

my @all_output;

for my $p (@ARGV) {
    my $ext = "";
    if ($p =~ /\.([^.]+)$/) {
        $ext = lc($1);
    }
    my $size = -s $p || 0;

    if ($BINARY_MAP{$ext}) {
        push @all_output, make_result($p, $size, 0, 0, "", [], {type => $ext}, "不支持的二进制格式，无法提取文本内容");
        next;
    }

    if ($size > $MAX_SIZE) {
        my $mb = sprintf("%.2f", $size / (1024 * 1024));
        push @all_output, make_result($p, $size, 0, 0, "", [], {type => $ext}, "[文件过大] 大小 ${mb} MB，超过阈值 2 MB。请安装 Python 3.10+ 以获取分块读取支持。");
        next;
    }

    if ($TEXT_MAP{$ext} && -f $p) {
        local $/ = undef;
        open my $fh, '<', $p or do {
            push @all_output, make_result($p, $size, 0, 0, "", [], {type => $ext}, "无法读取文件: $!");
            next;
        };
        binmode $fh;
        my $raw = <$fh>;
        close $fh;

        my $text;
        eval {
            $text = decode('UTF-8', $raw, Encode::FB_CROAK);
        };
        if ($@) {
            eval {
                $text = decode('GBK', $raw, Encode::FB_CROAK);
            };
            if ($@) {
                $text = decode('ISO-8859-1', $raw);
            }
        }

        my @lines = split /(?<=\n)/, $text;
        my @locations;
        my $offset = 0;
        for my $i (0..$#lines) {
            my $len = length($lines[$i]);
            push @locations, {
                type => "line",
                value => $i + 1,
                start => $offset,
                end => $offset + $len,
                meta => {},
            };
            $offset += $len;
        }

        my $clean = optimize_content($text);
        push @all_output, make_result($p, $size, 0, 0, $clean, \@locations, {type => $ext, lines => scalar(@lines) + 0}, "");
    } else {
        push @all_output, make_result($p, $size, 0, 0, "", [], {type => $ext}, "缺少 Python 环境，无法处理此格式。请安装 Python 3.10+ 及对应依赖（openpyxl/python-docx/pymupdf）。");
    }
}

binmode STDOUT, ':utf8';
print join("\n", @all_output);
