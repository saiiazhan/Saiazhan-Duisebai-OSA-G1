#!/usr/bin/env bash
# Lab 5 - convert staff-broken.csv to UTF-8 (macOS)
set -euo pipefail
SRC_ENC="RK1048"   # Kazakh code page, found by diagnosis (A3, 8D, 9D)
IN=evidence/staff-broken.csv
OUT=evidence/staff-fixed.csv
# 1. decode from RK1048, encode as UTF-8
# 2. CRLF -> LF (BSD sed on macOS does not understand \r, so perl)
# 3. add UTF-8 BOM, because Excel needs it to read the file as UTF-8
{
  printf '\xEF\xBB\xBF'
  iconv -f "$SRC_ENC" -t UTF-8 "$IN" | perl -pe 's/\r$//'
} > "$OUT"
file -e csv "$OUT"
xxd -l 16 "$OUT"
