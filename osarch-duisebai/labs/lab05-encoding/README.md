# Lab 5 — Encoding forensics

Pair: Duisebai / Issaev         Driver first half: Duisebai
Machine: MacBook Pro, macOS 26.3.1 — Excel for Mac 16.115, LibreOffice 26.8.3.1, zsh (locale C.UTF-8)
Date: 12.11.2026

## What I did

Diagnosis first, on the untouched original from Canvas. The checksum was recorded before anything else.
All commands were run in zsh on macOS (BSD tools), from `labs/lab05-encoding/evidence`.

```bash
cp ~/Downloads/staff-broken.csv evidence/
shasum -a 256 staff-broken.csv | tee checksum-before.txt

# 5. What is it?
file staff-broken.csv            | tee file-before.txt
file -e csv staff-broken.csv     | tee -a file-before.txt
xxd -l 16 staff-broken.csv       | tee hexdump-before.txt

# 6-8. Encoding, line ending, BOM  (-> diagnosis-notes.txt)
LC_ALL=C tr -cd '\r' < staff-broken.csv | wc -c      # CR count
wc -l < staff-broken.csv                             # LF count
cat -e staff-broken.csv | head -3                    # macOS: cat -e instead of cat -A
iconv -f UTF-8 -t UTF-8 staff-broken.csv > /dev/null # validity test
for enc in CP1251 CP866 KOI8-R PT154 RK1048; do
  echo "=== $enc"; iconv -f $enc -t UTF-8 staff-broken.csv | head -3
done
iconv -f RK1048 -t UTF-8 staff-broken.csv > /dev/null && echo ok

# 9. Convert
bash scripts/fix.sh
```

## Diagnosis (before the fix)

**file says** ([evidence/file-before.txt](evidence/file-before.txt)):

```
staff-broken.csv: Non-ISO extended-ASCII text, with CRLF line terminators
```

So: not UTF-8 or UTF-16, a single-byte "extended ASCII" code page — `file` cannot say which one.

**First 16 bytes** ([evidence/hexdump-before.txt](evidence/hexdump-before.txt)):

```
00000000: d2e0 e12e b93b d4c8 ce3b c4ee ebe6 edee  .....;...;......
```

| Offset | Bytes | What they are |
|---|---|---|
| 00–02 | `D2 E0 E1` | «Таб» — three Cyrillic letters, **one byte each**. No BOM: the file starts directly with text |
| 03 | `2E` | `.` (ASCII) |
| 04 | `B9` | `№` — one byte, so a single-byte code page |
| 05 | `3B` | `;` — the field separator is a **semicolon**, not a comma |
| 06–08 | `D4 C8 CE` | «ФИО» |
| 09 | `3B` | `;` separator |
| 0A–0F | `C4 EE EB E6 ED EE` | «Должно» — start of «Должность» |

The first non-ASCII character (`D2` = Т) takes **one byte**. In UTF-8 it would be two (`D0 A2`).
The line ending is not inside the first 16 bytes; the first `0D 0A` is at offset `2C–2D`, after «Дата приёма».

### Encoding: **RK1048** (Windows-1048, Kazakh)

Evidence ([evidence/diagnosis-notes.txt](evidence/diagnosis-notes.txt)):

1. **Not UTF-8:** `iconv -f UTF-8 -t UTF-8` stops with `Illegal byte sequence`.
2. **Single-byte Cyrillic:** every letter is one byte in 80–FF (no `D0 xx` / `D1 xx` pairs).
3. **CP866 and KOI8-R** turn every name into nonsense (`╥рс.╣`, `рЮА.╧`) — ruled out.
4. **CP1251, PT154 and RK1048** all decode the Russian words identically. **The Kazakh letters decide it.**
   Record 1001 at offset `0x30`: `30 31 3B 8D E0 F1 FB EC EE E2 E0 20 A3 EB E8 FF 20 D1 E5 F0 B3 EA 9D FB E7 FB`

   | Byte | RK1048 | CP1251 | PT154 |
   |---|---|---|---|
   | `8D` (0x33) | **Қ** | Ќ | Қ |
   | `A3` (0x3C) | **Ә** | Ј | Ј |
   | `9D` (0x46) | **қ** | ќ | қ |

   - CP1251 → «Ќасымова Јлия Серікќызы» — wrong
   - PT154 → «Қасымова Јлия Серікқызы» — closer, but Ә is wrong
   - RK1048 → «**Қасымова Әлия Серікқызы**» — correct
5. `iconv -f RK1048 -t UTF-8 staff-broken.csv > /dev/null` → `ok`: the **whole** file decodes, all 25 records,
   including Ғ, Ң, Ө, Ұ, Ү, Һ, І (Ғалымжан, Мөлдір, Нұрсұлтан, Үсенова, Һашимов, Іңкәр).

### Line ending: **CRLF (Windows)**

- `file` says `with CRLF line terminators`.
- CR count = **26**, LF count = **26** → every line ends in `0D 0A`.
- `cat -e` shows `^M$` at the end of every line.

### BOM: **absent**

The file starts `D2 E0 E1` (= «Таб»), not `EF BB BF` / `FF FE` / `FE FF`.

## What each application was doing wrong

The bytes were intact; each program guessed a different decoder. Three programs, three wrong guesses.

| Application | What I saw on staff-broken.csv | Why |
|---|---|---|
| Excel for Mac ([excel-broken.png](evidence/excel-broken.png)) | Header `“аб.є`; capital letters became symbols: `—ейітЭызы` (Сейітқызы), `¬олкова` (Волкова), `Sухгалтер` (Бухгалтер); lower-case letters mostly right. Columns split correctly | No BOM, so Excel did not detect the encoding and used the Mac's legacy default, **Mac Cyrillic** (x-mac-cyrillic). Its lower case а–я is at E0–FF, the same as RK1048, so lower case survives; but its capitals are at 80–9F, and C0–DF holds typographic symbols (`—`, `“`, `¬`, `≈`) — so every capital letter became a symbol. The `;` separator matched my Russian region, so columns split |
| LibreOffice Calc ([calc-broken.png](evidence/calc-broken.png)) | All Russian text correct; **only Kazakh letters wrong**: «Ќасымова Јлия Серікќызы», «Ґтебаев», «Нўрланов Єалымжан», «Їсенова», «Ћашимов» | Calc guessed the character set from the system locale (Russian) → **Windows-1251**. CP1251 and RK1048 agree on every Russian letter but put Serbian/Macedonian/Ukrainian letters where RK1048 has the Kazakh ones (8D Қ→Ќ, A3 Ә→Ј, A5 Ө→Ґ…) |
| cat (Terminal, UTF-8) | `???.?;???;?????????;…` — every Cyrillic letter is `?`; digits, e-mails and dates perfect | cat decodes nothing, it passes bytes to the terminal. The terminal expects UTF-8; a lone byte 80–FF is not a valid UTF-8 sequence, so it is shown as `?`. ASCII is identical in every encoding, so it survives — proof the file was not corrupted |

## Fix

Command / script: [scripts/fix.sh](scripts/fix.sh) — run from `labs/lab05-encoding`: `bash scripts/fix.sh`

```bash
{
  printf '\xEF\xBB\xBF'                                        # UTF-8 BOM
  iconv -f RK1048 -t UTF-8 evidence/staff-broken.csv | perl -pe 's/\r$//'   # decode, CRLF -> LF
} > evidence/staff-fixed.csv
```

**Changed:** encoding **RK1048 → UTF-8**; line ending **CRLF changed to LF**; BOM **added**.

- **BOM added because Excel decided it.** Without `EF BB BF`, Excel opened the file on double-click in its legacy
  code page (see above). With the BOM it opened as UTF-8 with no import wizard. LibreOffice and cat read it either way.
- **LF because scripts read the file.** With CRLF the last field of every row carries a hidden `\r`
  (`12.03.2019\r`), which breaks comparisons and `awk`. Excel and Calc read LF without problems.

| Reader | Without BOM | With BOM |
|---|---|---|
| Excel for Mac, double-click | Guesses a legacy code page → garbage (seen above) | Reads UTF-8 correctly ✔ |
| LibreOffice Calc | Detects UTF-8, correct | Correct ✔, proposes UTF-8 |
| cat in a UTF-8 terminal | Correct | Correct ✔ (BOM is invisible) |
| A script reading the first header | `Таб.№` | `﻿Таб.№` — invisible character before the first header; a script must strip it (e.g. Python `encoding='utf-8-sig'`) |

Bytes at the start, before → after:

```
before: D2 E0 E1 2E B9 3B D4 C8 ...                 Т а б . № ; Ф И   (1 byte per letter)
after:  EF BB BF D0 A2 D0 B0 D0 B1 2E E2 84 96 3B D0 A4   BOM Т а б . № ; Ф   (2 bytes per letter, № = 3 bytes)
```

## Verification

`file` after ([evidence/file-after.txt](evidence/file-after.txt)):

```
staff-fixed.csv: Unicode text, UTF-8 (with BOM) text      # no "CRLF" any more
00000000: efbb bfd0 a2d0 b0d0 b12e e284 963b d0a4  ...  # exactly one BOM, then «Таб.№;Ф»
CR: 0   LF: 26
```

Script check — `awk -F';' '{ print $NF "|" }' staff-fixed.csv | head -3`:

```
Дата приёма|
12.03.2019|
01.09.2017|
```

The `|` sits right after the value → no hidden CR.

Original untouched — SHA-256 before and after the fix:
`919027f1f8c71d85cba3f12aad0f6c927d4e0450cfb2a2d63378a69f14cab270` (same in checksum-before.txt and file-after.txt).

**Opened in:** Excel for Mac 16.115, LibreOffice Calc 26.8.3.1 and `cat` in Terminal on macOS 26.3.1 —
[evidence/opens-correctly.png](evidence/opens-correctly.png). Excel by double-click (no import wizard),
Calc with the import settings it proposed, unchanged. All 25 names correct in all three, e.g. «Қасымова Әлия Серікқызы»,
«Әбенова Гүлнар Төлеуқызы», «Һашимов Рустем Фаридұлы», «Шәріпова Жұлдыз Өміртайқызы».

Note: the brief asks for `cat` in a Linux terminal. I did the lab on my Mac, so `cat` was run in the macOS Terminal
(zsh, UTF-8 locale). It is the same `cat` behaviour: bytes go straight to a UTF-8 terminal.

## What did not work the first time

1. **CR count came out as 0.** On the Mac, `tr -cd '\r' < staff-broken.csv | wc -c` printed
   `tr: Illegal byte sequence` and `0`. macOS `tr` works in the UTF-8 locale and refused the single-byte Cyrillic input,
   so it counted nothing — while `file` said CRLF. Fix: run it in the C locale, which treats the file as raw bytes:
   `LC_ALL=C tr -cd '\r' < staff-broken.csv | wc -c` → **26**, equal to the LF count. Lesson: a tool that fails on the
   encoding can give a wrong number instead of an error.
2. **fix.sh became an .rtf.** I first pasted the script into TextEdit, which wanted to save it as `fix.sh.rtf`
   (rich text, curly quotes) — that cannot run. I deleted it and created the file from Terminal with a here-document
   (`cat > scripts/fix.sh <<'EOF' … EOF`).
3. **Excel was not installed** — `open -a "Microsoft Excel"` → `Unable to find application`. Installed it from the
   App Store. Also: BSD `sed` on macOS does not understand `\r`, so the brief's `sed 's/\r$//'` was replaced with `perl`.

## Evidence

- [evidence/staff-broken.csv](evidence/staff-broken.csv) — original from Canvas, SHA-256 unchanged
- [evidence/checksum-before.txt](evidence/checksum-before.txt) — SHA-256 of the original, taken before anything else
- [evidence/file-before.txt](evidence/file-before.txt) — `file` and `file -e csv` on the original: extended-ASCII, CRLF
- [evidence/hexdump-before.txt](evidence/hexdump-before.txt) — first 16 bytes of the original: one byte per letter, no BOM
- [evidence/diagnosis-notes.txt](evidence/diagnosis-notes.txt) — CR/LF counts, UTF-8 test, every candidate decoded, RK1048 whole-file ok
- [evidence/staff-fixed.csv](evidence/staff-fixed.csv) — converted file: UTF-8 with BOM, LF
- [evidence/file-after.txt](evidence/file-after.txt) — `file`, first bytes, CR/LF, awk check, checksum of the original after the fix
- [evidence/opens-correctly.png](evidence/opens-correctly.png) — Excel, LibreOffice Calc and Terminal side by side, same names
- [evidence/versions.txt](evidence/versions.txt) — macOS, Excel and LibreOffice versions
- [evidence/excel-broken.png](evidence/excel-broken.png) — Excel on the original: read as Mac Cyrillic, capitals became symbols
- [evidence/calc-broken.png](evidence/calc-broken.png) — LibreOffice Calc on the original: read as CP1251, only Kazakh letters wrong
