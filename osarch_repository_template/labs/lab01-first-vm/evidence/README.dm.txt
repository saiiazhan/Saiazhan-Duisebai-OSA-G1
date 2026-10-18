# Lab 01 - Your first virtual machine

Pair: Duisebai /    Driver first half: Duisebai
Machine: Host macOS (Apple Silicon), Guest Ubuntu Server ARM64
Date: 18.10.2026

## What I did

1. Installed Ubuntu Server on a new VM using VMware Fusion[cite: 4].
2. Allocated resources based on my host's capacity[cite: 4].
3. Took a snapshot named `clean-install` before modifying the system[cite: 4].
4. Intentionally broke the OS by deleting the `/etc/hostname` file[cite: 4].
5. Rolled back to the `clean-install` snapshot and confirmed the damage was gone[cite: 4].

**Resource Justification:**
I gave it 2 vCPUs of my 8 host cores, and 2 GB of RAM of my total RAM, and a 20 GB disk. I chose these values because Ubuntu Server without a graphical interface runs perfectly on minimal resources, and I need to leave enough memory for macOS to remain responsive and to run a second Windows guest later[cite: 4].

## Result

The VM boots normally. The resource allocation is justified against real host numbers, and the break-and-rollback cycle was successfully tested and evidenced[cite: 4].

## What did not work the first time

I initially downloaded the x86 ISO instead of the ARM64 version[cite: 4]. When I tried to create the VM, VMware Fusion rejected it with a message that the architecture is incompatible with my Arm host. I had to delete the VM, move it to the trash, and download the correct `arm64` image to fix it[cite: 4].

## Evidence

- [evidence/vm-settings.png](evidence/vm-settings.png) - CPU, memory, and disk as configured[cite: 4]
- [evidence/guest-release.txt](evidence/guest-release.txt) - output of lsb_release -a inside the guest[cite: 4]
- [evidence/broken.png](evidence/broken.png) - the guest in its broken state[cite: 4]
- [evidence/snapshot-list.png](evidence/snapshot-list.png) - snapshots, after the rollback[cite: 4]