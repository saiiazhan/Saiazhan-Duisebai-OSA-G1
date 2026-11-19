# Checkpoint 1 — Task 1 

## 1a. The computer in front of me
Full command output: [evidence/task1.txt](evidence/task1.txt)

| Figure | This computer | Command it came from |
|---|---|---|
| CPU model | Apple M5 (arm64) | `sysctl -n machdep.cpu.brand_string`, `uname -m` |
| Cores / logical processors | 10 / 10 (4 performance + 6 efficiency; no SMT, so cores = logical) | `sysctl hw.physicalcpu hw.logicalcpu`, `sysctl hw.perflevel0.physicalcpu hw.perflevel1.physicalcpu` |
| Hardware virtualization | Supported: yes (`kern.hv_support: 1`). Enabled in firmware: Apple Silicon has no firmware switch — virtualization (Hypervisor.framework) is always available | `sysctl kern.hv_support` |
| Memory: total / available now | 16 GiB (17 179 869 184 bytes) / ~9.4 GiB available (59 % free). Only 137 MB is completely unused — macOS keeps the rest as cache and compressed memory and hands it back on demand | `sysctl -n hw.memsize`, `memory_pressure \| tail -1`, `top -l 1 \| grep PhysMem` |
| System disk: size, free, SSD/HDD | 494.3 GB APFS container (= 460 GiB) on a 500.3 GB internal disk; 46.5 GB free (= 43 GiB); SSD (`Solid State: Yes`) | `diskutil info /`, `df -h /`, `diskutil list disk0` |
| Partition style | GPT (`GUID_partition_scheme`) | `diskutil list disk0` |
| OS and version | macOS 26.3.1 (a), build 25D771280a | `sw_vers` |

Note: `diskutil` reports decimal GB, `df -h` binary GiB — 494.3 GB and 460 GiB are the same size.

What did not work the first time: `tee evidence/task1.txt` failed with `No such file or directory` because I ran it from `~`, not from the folder that has `evidence/`. Fixed with `mkdir -p ~/cp1-practice/evidence && cd ~/cp1-practice` and re-ran.

## 1b. Thin-and-light laptop: 2C/4T 1.1 GHz, 8 GB soldered, 128 GB eMMC soldered (31 GB free), Windows 11 Home in S mode

### Could it run both guests at once?
Guest sizes from my build logs: Ubuntu Server (Lab 1) 2 vCPU / 3 GB / 20 GB; Windows 11 (Lab 2) 2 vCPU / 4 GB / 64 GB.
Assumed for the host itself: Windows 11 + hypervisor needs 2 threads, ~4 GB RAM, ~15 GB free disk for updates, pagefile and temp files.

| | CPU | Memory | Disk |
|---|---|---|---|
| Guests | 2 + 2 = 4 vCPU | 3 + 4 = 7 GB | 20 + 64 = 84 GB |
| Host (assumed) | 2 threads | 4 GB | 15 GB |
| Needed | 6 | 11 GB | 99 GB |
| Laptop has | 4 threads | 8 GB | 31 GB free |
| Result | short by 2 | short by 3 GB | short by 68 GB |

Two blockers before the arithmetic:
1. **S mode** allows only Microsoft Store apps, so VirtualBox/VMware cannot be installed; Home has no Hyper-V.
2. **Architecture:** my guests are ARM64 (built on Apple Silicon); this laptop is x86-64 (AMD). My VM images would not run at all — the guests would have to be rebuilt from x86 ISOs.

**Answer: no.** CPU, memory and disk are all insufficient, and the hypervisor cannot even be installed.

### Upgrade first
Memory and eMMC are soldered — **neither can be upgraded.** Honest answer: the hardware cannot be fixed. Instead:
1. Leave S mode first (free, in Microsoft Store, one-way) — without it nothing else is possible.
2. Keep VM files on an external USB 3.x SSD to get around 31 GB free.
3. Memory cannot be worked around: run the guests **one at a time** (Ubuntu alone, or Windows alone), or use another machine / a cloud VM for the two-guest lab.
