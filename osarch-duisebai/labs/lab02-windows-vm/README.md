# Lab 2 — A Windows guest, and a network between them

Pair: <Surname1> / <Surname2>  Driver first half: <Surname>
Machine: MacBook (Apple Silicon, 16 GB RAM), VMware Fusion; guests: Ubuntu Server (ARM64), Windows 11 ARM64 evaluation
Date: 26.10.2026

## What I did

### 1. Windows VM

Created a VM in Fusion from the Windows 11 ARM64 ISO (`Windows11_Client_arm64_ru-ru_26300_9457.iso`). No licence key was entered; the evaluation image was used as is.

| Setting | Value |
|---|---|
| Processors | 2 cores |
| Memory | 4096 MB |
| Disk | 64 GB |
| Network | Share with my Mac (NAT) |

Memory total with the Linux guest (3 GB): 7 GB of 16 GB, which leaves the host enough room.

### 2. Network mode: NAT for both guests

Both guests use **NAT** ("Share with my Mac"). Why:

- it gives both guests internet access through the host;
- both guests sit on the same virtual NAT subnet, so they can see each other;
- on the campus network, bridged mode can run into MAC filtering and silently drop the guest.

<!-- If you tried bridged, describe here honestly what happened (it got/did not get an address, whether ping worked). If not, delete this comment. -->

Network diagram:

```
                 Internet
                    |
             campus network
                    |
        +-----------+-----------+
        |   Mac host (Fusion)   |
        |   NAT / vmnet8        |
        +-----+-------------+---+
              |             |
     172.16.151.<L>   172.16.151.<W>
       Ubuntu Server    Windows 11 ARM
```

### 3. Addresses

```powershell
# Windows
ipconfig /all > ipconfig-windows.txt
```

```bash
# Linux
ip addr > ip-addr-linux.txt
```

| Guest | IP address | Gateway |
|---|---|---|
| Ubuntu | 172.16.151.<L> | <gw> |
| Windows | 172.16.151.<W> | <gw> |

### 4. Ping in both directions

First attempt, Linux → Windows, failed: the Windows firewall blocks inbound ICMP echo by default. Saved as the first part of `ping-both-ways.txt`.

Fix: one specific rule, the firewall stays on (PowerShell as administrator):

```powershell
New-NetFirewallRule -DisplayName "Allow ICMPv4 Echo In (lab)" -Protocol ICMPv4 -IcmpType 8 -Direction Inbound -Action Allow
```

Then repeated the ping in both directions and checked internet access from both guests:

```bash
# Linux
ping -c 4 172.16.151.<W>
ping -c 4 8.8.8.8
```

```powershell
# Windows
ping 172.16.151.<L>
ping 8.8.8.8
```

`ping-both-ways.txt` contains the whole sequence: error → rule → success.

### 5. Memory overcommit experiment

1. **Before:** both guests at normal values (Windows 4096 MB, Ubuntu 3072 MB), screenshot of Activity Monitor → Memory: `host-memory-before.png`.
2. Raised allocations so the total exceeds the physical RAM:

   | Guest | Memory |
   |---|---|
   | Windows | 12288 MB |
   | Ubuntu | 8192 MB |
   | **Total** | **20480 MB (20 GB) > 16 GB host** |

3. Started both VMs and waited 2–3 minutes.
4. **After:** screenshot `host-memory-after.png`.
5. Returned the allocations to Windows 4096 MB, Ubuntu 3072 MB.

## Result

### Network

NAT mode: both guests reached each other and the internet after the ICMP rule was added (see `ping-both-ways.txt`).

### Memory, before and after

| Metric (Activity Monitor) | Before | After |
|---|---|---|
| Physical memory | <value> | <value> |
| Memory used | <value> | <value> |
| Swap used | <value> | <value> |
| Compressed | <value> | <value> |
| Memory pressure graph | <green / yellow / red> | <green / yellow / red> |

What happened: <fill in from the screenshots: free memory dropped from X to Y, swap grew from X to Y, compressed memory grew, the Mac became slow / the pressure graph turned yellow or red>.

Conclusion: giving guests 20 GB on a 16 GB host does not fail at startup. The host compensates by compressing memory and swapping to disk, which makes everything, including the guests, slower. The sum of guest allocations should stay well below physical RAM.

## What did not work the first time

- **x64 image.** The first Windows ISO was x64, which does not fit an Apple Silicon host. Replaced it with the ARM64 image.
- **Ping Linux → Windows was blocked.** Request timed out, because the Windows firewall drops inbound ICMP echo by default. The firewall was not turned off; an ICMPv4 echo allow rule was added instead.

## Evidence

- [evidence/ipconfig-windows.txt](evidence/ipconfig-windows.txt) — Windows address, gateway and DNS in the NAT subnet.
- [evidence/ip-addr-linux.txt](evidence/ip-addr-linux.txt) — Linux address in the same subnet.
- [evidence/ping-both-ways.txt](evidence/ping-both-ways.txt) — blocked ping, firewall rule, successful ping both ways and to the internet.
- [evidence/host-memory-before.png](evidence/host-memory-before.png) — host memory with normal guest allocations.
- [evidence/host-memory-after.png](evidence/host-memory-after.png) — host memory with 20 GB promised to the guests: less free memory, more swap and compression.
