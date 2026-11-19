# Checkpoint 1 — Task 2: plan two guests on my Mac 

Host figures from Task 1: Apple M5, 10 cores, 16 GiB RAM (~9.4 GiB available now), 46.5 GB free disk, macOS 26.3.1, VMware Fusion.

## Allocation
| | Ubuntu Server | Windows 11 |
|---|---|---|
| Image | Ubuntu Server ARM64 | Windows 11 ARM64 |
| vCPU | 2 | 2 |
| Memory | 3 GB | 4 GB |
| Disk | 20 GB, dynamically allocated | 64 GB, dynamically allocated |
| Network | 1 adapter, NAT ("Share with my Mac", vmnet8) | 1 adapter, NAT |
| Other | — | virtual TPM 2.0 (required by Windows 11; Fusion encrypts the VM for it) |

## Arithmetic
| | Host has | Guests take | Left for host | Host needs (assumption) |
|---|---|---|---|---|
| CPU | 10 cores | 4 vCPU | 6 | 2–4 |
| Memory | 16 GiB | 7 GB + ~1 GB Fusion overhead | ~8 GB | macOS + browser + Fusion ≈ 6–8 GB |
| Disk | 46.5 GB free | up to 84 GB (max of dynamic disks) | **negative at maximum** | ≥ 15 GB |

**CPU and memory fit. Disk does not fit at full size:** 84 GB of maximum guest disks > 46.5 GB free.
With dynamic disks the guests start small (Ubuntu ~5 GB, Windows 11 after install ~20–25 GB ≈ 30 GB), leaving ~16 GB for the host — just at my 15 GB host minimum, with no headroom for Windows updates.

**Closest configuration that works:** same CPU, memory and network; dynamically allocated disks; and either (a) free ~40 GB on the host before building, or (b) store both VMs on an external USB-C SSD. What it gives up without (a)/(b): any guarantee — once the guests grow, the host disk fills and macOS and both VMs stop.

## Justification
- **NAT, not bridged or host-only.** In Fusion a NAT guest gets an address on vmnet8 (172.16.151.0/24 in Lab 2) that the Mac can reach directly, so `ssh` from the host works, and the guest reaches the internet through the host. Bridged depends on the office/campus network (MAC filtering, DHCP) and exposes the guest to the LAN; host-only gives no internet.
- **Dynamic, not fixed disks:** a fixed 84 GB is impossible on 46.5 GB free; dynamic disks only use what is written. Cost: slightly slower writes, and the host's free space must be watched.
- **Ubuntu 3 GB, not the wizard's 6 GB:** a console server idles at ~400 MB (Lab 1); 3 GB covers the installer and apt.
- **Windows 11: 2 vCPU, 4 GB, 64 GB** — these are Windows 11's own minimums; nothing is set below them.
- **Total memory 7 of 16 GB:** Lab 2 showed that promising guests 20 GB on 16 GB does not fail, it makes the host compress and swap. 7 GB keeps memory pressure green.
- **ARM64 images:** x86 Ubuntu or Windows will not run under Fusion on Apple Silicon.

## Verification plan
| Where | Command | Expected output |
|---|---|---|
| Ubuntu | `nproc` | `2` |
| Ubuntu | `free -h` | Mem total ≈ `2.8Gi` (kernel reserves part) |
| Ubuntu | `lsblk` | system disk `20G` |
| Ubuntu | `ip -br a` | `ens160 UP 172.16.151.x/24` |
| Host | `ssh user@172.16.151.x` | `user@ubuntu:~$` prompt |
| Ubuntu | `ping -c 3 1.1.1.1`; `curl -I https://ubuntu.com` | `0% packet loss`; `HTTP/2 200` |
| Windows | `Get-CimInstance Win32_ComputerSystem \| select NumberOfLogicalProcessors,TotalPhysicalMemory` | `2`, ≈ `4294967296` |
| Windows | `Get-Volume C` | Size ≈ `63 GB` |
| Windows | `Test-NetConnection ubuntu.com -Port 443` | `TcpTestSucceeded : True` |
| Ubuntu → Windows | `ping -c 4 172.16.151.y` (after the ICMPv4 echo rule from Lab 2) | `0% packet loss` |
| Host | `memory_pressure \| tail -1`; `df -h /` | free ≥ ~40 %; Avail ≥ 15 GB |
