# Lab 00 - Inventory

Pair: Duisebai / Driver first half: Duisebai
Machine: Host, macOS
Date: 18.10.2026

## What I did

Gathered hardware specifications using macOS command-line tools.

## Result

| What | Value | Where I got it |
| :--- | :--- | :--- |
| **CPU Model** | [Apple M5 ] | `sysctl -a \| grep machdep.cpu.brand_string` |
| **CPU Cores/Threads** | [ 10 ] | `sysctl -a \| grep hw.physicalcpu` |
| **Memory Total** | [ 16 ] | `system_profiler SPMemoryDataType` |
| **Memory Modules** | LPDDR5 | `system_profiler SPMemoryDataType` |
| **Memory Speed** | N/A (Apple Silicon) | `system_profiler SPMemoryDataType` |
| **Disk Model & Type** | [APPLE SSD AP0512Z] | `system_profiler SPStorageDataType` |
| **Free Space for VMs** | [83,9 MB] | `df -h /` |
| **Firmware & Version** | [System Firmware Version: 13822.81.10] | `system_profiler SPHardwareDataType \| grep "Firmware"` |
| **Virtualization** | Supported (1) | `sysctl kern.hv_support` |

## What did not work the first time

I accidentally copied the template command `cd osarch-familiya/labs/lab00-inventory` instead of using my actual last name. The terminal returned "no such file or directory". I fixed it by running `cd osarch-duisebai/labs/lab00-inventory`.

## Evidence

- [evidence/cpu.txt](evidence/cpu.txt) - CPU model and core counts
- [evidence/memory.txt](evidence/memory.txt) - RAM total and specifications
- [evidence/disk.txt](evidence/disk.txt) - Storage model and free space
