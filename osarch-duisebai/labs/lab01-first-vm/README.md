# Lab 1 — First VM

## Setup
Hypervisor: VMware Fusion <13.6.2> on macOS (Apple Silicon).
Guest: Ubuntu Server 26.10 (aarch64), console only, OpenSSH installed.
`lsb_release -a` output: evidence/guest-release.txt

## Resource allocation
My host is a Mac with 10 logical cores, 16 GB of RAM and 185 GiB of free
disk (460 GiB total), measured with `sysctl` and `df -h /` before creating
the VM. At that moment `vm_stat` showed only ~0.06 GB of completely free
pages (3614 pages of 16 KB), with ~2.6 GB active and ~2.3 GB inactive, so
the host was already running on reclaimed and compressed memory. The VMware
wizard proposed 6 GB for the guest (marked "recommended" in the settings
slider); that would take over a third of my RAM and push macOS into heavy
swapping, so I reduced it to 3 GB. 3 GB is about 19% of my 16 GB, and
Fusion reports 13312 MB remaining for macOS (evidence/vm-settings.png). A
console-only Ubuntu Server idles at roughly 400 MB (the guest showed 12-13%
memory usage at idle), so 3 GB is a comfortable margin for the installer
and apt. I gave the guest 2 vCPU of 10 (20%), leaving 8 cores for the host
and for a second guest in a later lab. The disk is 20 GB of my 185 GiB
free (about 11%); the installer's LVM root volume is 9.75 GB, which is
enough because the system itself needs about 5 GB.

## What I did
1. Created the VM and installed Ubuntu Server (no desktop).
2. Took snapshot `clean-install` before changing anything.
3. Broke the guest: `sudo rm /etc/hostname`. `cat` and `ls` returned
   "No such file or directory" and `hostnamectl` showed
   `Static hostname: (unset)` (evidence/broken.png).
4. Powered off and restored `clean-install`, choosing "Don't Save" so the
   broken state would not become an extra snapshot.
5. After the rollback `/etc/hostname` was back with its install-time
   timestamp (10:27) and contained `ubuntu-lab1`
   (evidence/rollback-proof.png). The snapshot tree shows only
   `clean-install` and Current State (evidence/snapshot-list.png).

## What did not work
- I pasted `tee ~/guest-release.txt` without the `lsb_release -a |` part,
  so `tee` waited for keyboard input. I stopped it with Ctrl+C and re-ran
  the full command as one line.
- The wizard's default of 6 GB RAM was too much for a console server on a
  16 GB host, so I lowered it to 3 GB.
- The root filesystem is only 9.75 GB of the 20 GB disk because the Ubuntu
  installer's default LVM layout does not use the whole disk.

## Evidence
- evidence/vm-settings.png (CPU and memory; disk: 20 GB)
- evidence/guest-release.txt
- evidence/broken.png
- evidence/snapshot-list.png
- evidence/rollback-proof.png (bonus)

