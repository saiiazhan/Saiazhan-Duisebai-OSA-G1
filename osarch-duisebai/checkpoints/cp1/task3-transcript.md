# Checkpoint 1 — Task 3: nightly report not written 

Ticket: `/var/log/nightly-report.log` not written since the script was updated last week; the scheduler says the job runs every two minutes. Evidence pack from office-srv, 2026-11-16 09:42 UTC.

| # | Evidence file (command) | What I expected | What I found | What I concluded |
|---|---|---|---|---|
| 1 | 05 (`systemctl --failed`) | nightly-report failing | Two failed units: `legacy-sync` and `nightly-report` | Two leads; check which one relates to the ticket |
| 2 | 10 (`systemctl status legacy-sync`) | Something touching the report or /var/log | `ExecStart=/bin/false`, "old office, no longer used", failed since boot Nov 09 09:51 | `/bin/false` always exits 1 by design; not related to the report |
| 3 | 11 (`journalctl -u legacy-sync`) | If related: started failing last week | Fails on every boot since Sep 14 (4 boots) | Old constant noise, older than the ticket. **Dead end — ruled out.** Note: disable later, after asking the owner |
| 4 | 06 (`systemctl list-timers`) | Does the timer really fire? | `nightly-report.timer` LAST 09:42:01, NEXT 09:44:01 | Timer works. The fault is in what the service starts, not in scheduling |
| 5 | 07 (`systemctl status nightly-report`) | An error from inside the script | `status=203/EXEC`, `Failed to execute /usr/local/bin/nightly-report.sh: No such file or directory`, CPU 2 ms | 203/EXEC = systemd could not start the program at all; the script never ran |
| 6 | 13 (`ls -l /usr/local/bin`) | File missing or misnamed | `-rwxr-xr-x root root 91 Nov 9 14:20 nightly-report.sh` | **Contradiction:** the file exists and is executable, yet "No such file". Missing file and permissions ruled out. Note mtime 14:20 |
| 7 | 08 (`systemctl cat`) | Typo in `ExecStart` | `ExecStart=/usr/local/bin/nightly-report.sh` — same path as row 6; timer `OnUnitActiveSec=2min` | Unit path correct; unit typo ruled out |
| 8 | 09 (`journalctl -u nightly-report`) | When did it start failing? | `Finished` (success) up to 14:18:01 Nov 09; 203/EXEC from 14:20:01 on | Broke between 14:18 and 14:20 — matches the script mtime 14:20. The file update broke it |
| 9 | 15 (`tail nightly-report.log`) | Last entry before the break | Last entry `Mon Nov 9 14:18:01`; script writes `date` + `df -h /` | Confirms row 8 and the ticket |
| 10 | 14 (`ls -l /var/log`) | Log not writable | `nightly-report.log` root `-rw-r--r--`, mtime 14:18 | Service runs as root; log permissions ruled out |
| 11 | 03, 04 (`df -h`, `free -h`) | Full disk / no memory | `/` 48 % used, 5.8 G free; 1.5 Gi RAM available, swap unused | Resources ruled out |
| 12 | 12 (`journalctl -p err -b`) | Other errors around 14:20 | Only vboxguest/vmwgfx at boot + the same nightly-report lines | VM display noise. **Dead end** |
| 13 | 01, 02 (`hostnamectl`, `uptime`) | Context, a reboot near 14:20? | Ubuntu 24.04 x86-64 on VirtualBox; up 6 d 23 h (boot Nov 09 09:50) | No reboot at 14:20; the only change at that time is the script file |
| 14 | 21 (`apt history.log`) | Upgrade broke bash/systemd? | `full-upgrade` Nov 09 09:38–09:41: bash, systemd, kernel | Runs succeeded until 14:18, 4.5 h after the upgrade. **Ruled out** |
| 15 | 20 (`which bash; ls -l /bin/bash`) | bash missing or broken | `/bin/bash` present, `-rwxr-xr-x`, 1.4 MB | Interpreter fine; bash ruled out |
| 16 | 22 (`~/.bash_history`) | What happened at 14:20 | `sudo cp ~/nightly-report.sh /usr/local/bin/…`, `chmod +x`, start, status, `chmod 755`, start, status | Script replaced with a copy from the home folder; admin suspected permissions (chmod twice) — did not help, permissions were already right. What is inside the new file? |
| 17 | 16 (`cat nightly-report.sh`) | Syntax error / wrong path | `#!/bin/bash`, comment, `{ date; df -h /; free -h; } >> /var/log/nightly-report.log` — looks correct | `cat` hides invisible characters; need a byte view |
| 18 | 17 (`cat -A`) | `$` at line ends (LF) | `^M$` at the end of every line | CR before every LF: the file has CRLF (Windows) line endings |
| 19 | 18 (`head -1 \| od -c`) | Is the CR in the first line? | `# ! / b i n / b a s h \r \n` | Shebang is `/bin/bash\r`; kernel looks for an interpreter named `bash\r`, not found → ENOENT → "No such file or directory" (about the interpreter, not the script). Size check: 88 bytes text + 3 CR = 91 = size in row 6 |
| 20 | 19 (run by hand) | If shebang: fails outside systemd and as root | user: `cannot execute: required file not found`; sudo: `No such file or directory` | Reproduced without systemd and as root — not systemd, not permissions |
| 21 | *not in pack:* `bash /usr/local/bin/nightly-report.sh` | Would succeed: with explicit bash the first line is just a comment | — | Would confirm the shebang is the only fault; not used as the fix (hides the CR instead of removing it) |
| 22 | *not in pack:* `file ~/nightly-report.sh` | `with CRLF line terminators` | — | The source copy is CRLF too; fix it, or the next `cp` brings the fault back |

## Root cause
On Nov 09 at 14:20 `nightly-report.sh` was replaced by a copy with Windows CRLF line endings. Its shebang became `#!/bin/bash\r`; the kernel cannot find an interpreter called `bash\r`, so systemd fails with 203/EXEC "No such file or directory". Evidence: 18 (`\r\n` in line 1), 17 (`^M$` on every line), 09 (last success 14:18, first failure 14:20), 13 (mtime 14:20, 91 bytes), 22 (the `cp`).

## Fix
```bash
sudo cp -p /usr/local/bin/nightly-report.sh /root/nightly-report.sh.crlf.bak   # keep the broken file
sudo sed -i 's/\r$//' /usr/local/bin/nightly-report.sh                        # CRLF -> LF
sed -i 's/\r$//' ~/nightly-report.sh                                          # fix the source copy too
sudo systemctl reset-failed nightly-report.service
sudo systemctl start nightly-report.service
```
The change is to the file on disk, so it survives a reboot; the timer is `WantedBy=timers.target`.
Separately (not part of this ticket): `legacy-sync.service` should be disabled with `sudo systemctl disable --now legacy-sync.service` after confirming with its owner.

## Verification
| Command | Expected output |
|---|---|
| `head -1 /usr/local/bin/nightly-report.sh \| od -c` | `# ! / b i n / b a s h \n` — no `\r` |
| `cat -A /usr/local/bin/nightly-report.sh` | lines end in `$`, no `^M` |
| `ls -l /usr/local/bin/nightly-report.sh` | `-rwxr-xr-x … 88` bytes (91 − 3 CR) |
| `systemctl status nightly-report.service` | `status=0/SUCCESS`, `Deactivated successfully` |
| `tail -n 8 /var/log/nightly-report.log` | today's date, the `df -h /` block and a `free -h` block (new script version) |
| after 2 min: `journalctl -u nightly-report.service --since "-5 min"` | `Finished nightly-report.service`, no 203/EXEC |
| `sudo reboot`, then `systemctl is-enabled nightly-report.timer` | `enabled` |
| `systemctl list-timers nightly-report.timer` | LAST after boot, NEXT within 2 min |
| `journalctl -u nightly-report.service -b`; `tail /var/log/nightly-report.log` | successful runs after boot; log grows every 2 min |
