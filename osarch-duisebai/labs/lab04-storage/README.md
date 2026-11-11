# Lab 4 — Storage

Pair: TODO / TODO         Driver first half: TODO
Machine: MacBook (Apple Silicon), VMware Fusion; guests: Windows 11 64-bit Arm, Ubuntu Server (aarch64)
Date: 11.11.2026

## What I did

### Windows

```powershell
Get-Disk
Initialize-Disk -Number 1 -PartitionStyle GPT
New-Partition -DiskNumber 1 -UseMaximumSize -DriveLetter E
Format-Volume -DriveLetter E -FileSystem NTFS -NewFileSystemLabel LAB4
Get-Disk
Get-Partition -DiskNumber 1
$env:firmware_type
```

### Linux

Disks: system disk `nvme0n1` (20 GB, has `/boot` and `/`, not touched). Three new 2 GB disks, no partitions and no mount point.

| Role            | Device    |
|-----------------|-----------|
| Mirror half A   | nvme0n2p1 |
| Failed half     | nvme0n3p1 |
| Replacement     | nvme0n4p1 |

```bash
# layout before
lsblk -o NAME,SIZE,TYPE,FSTYPE,MOUNTPOINT > lsblk-before.txt

# partition two disks and build the mirror
sudo parted /dev/nvme0n2 --script mklabel gpt mkpart lab4 1MiB 100% set 1 raid on
sudo parted /dev/nvme0n3 --script mklabel gpt mkpart lab4 1MiB 100% set 1 raid on
sudo mdadm --create /dev/md0 --level=1 --raid-devices=2 --bitmap=internal --run /dev/nvme0n2p1 /dev/nvme0n3p1
# healthy state -> evidence/array-healthy.txt

# filesystem, proof files, checksum
sudo mkfs.ext4 -L lab4 /dev/md0
sudo mount /dev/md0 /mnt/mirror
sudo chown $USER /mnt/mirror
echo "Lab 4 - Duisebai - $(date)" > /mnt/mirror/proof.txt
dd if=/dev/urandom of=/mnt/mirror/random.bin bs=1M count=200
sync
sha256sum /mnt/mirror/proof.txt /mnt/mirror/random.bin > checksum-before.txt

# fail one half
sudo mdadm /dev/md0 --fail /dev/nvme0n3p1
# degraded state -> evidence/array-degraded.txt
sudo mdadm /dev/md0 --remove /dev/nvme0n3p1

# prove the data survived (from disk, not cache)
sudo umount /mnt/mirror
sudo mount /dev/md0 /mnt/mirror
sha256sum /mnt/mirror/proof.txt /mnt/mirror/random.bin > checksum-after-failure.txt
diff checksum-before.txt checksum-after-failure.txt && echo MATCH

# rebuild onto the spare
sudo sysctl -w dev.raid.speed_limit_max=10000
sudo parted /dev/nvme0n4 --script mklabel gpt mkpart lab4 1MiB 100% set 1 raid on
sudo mdadm /dev/md0 --add /dev/nvme0n4p1
watch -n 1 cat /proc/mdstat
# rebuilt state -> evidence/array-rebuilt.txt
```

## Result

### Windows

Disk 0 (system disk, 64 GB): partition style GPT, `$env:firmware_type` = UEFI — because Windows booted in UEFI mode, and a UEFI machine boots only from a GPT disk (Legacy BIOS would mean MBR).

New disk (Disk 1, 2 GB): partition style GPT — because GPT is not limited to 2 TB and four primary partitions like MBR, and it keeps a backup copy of the partition table at the end of the disk. A 2 GB disk would also fit MBR, so the choice would only matter for a disk over 2 TB, for more than four partitions, or if this disk had to boot a UEFI system (then GPT is required).

Output after initialising, partitioning and formatting the new disk as `E:` (NTFS, label LAB4):

```
Number FriendlyName             Size PartitionStyle OperationalStatus
------ ------------             ---- -------------- -----------------
     0 VMware Virtual NVMe Disk 68719476736 GPT      Online
     1 VMware Virtual NVMe Disk 2147483648  GPT      Online

PartitionNumber DriveLetter Offset      Size Type
--------------- ----------- ------      ---- ----
1                              17408 15.98 MB Reserved
2               E           16777216  1.98 GB Basic

UEFI
```

Screenshot of this output: [evidence/windows-disks.png](evidence/windows-disks.png)

### Linux layout — before

```
NAME                      SIZE TYPE FSTYPE      MOUNTPOINT
sr0                       2.9G rom  iso9660
nvme0n1                    20G disk
├─nvme0n1p1               953M part vfat        /boot/efi
├─nvme0n1p2               1.8G part ext4        /boot
└─nvme0n1p3              17.3G part LVM2_member
  └─ubuntu--vg-ubuntu--lv   10G lvm  ext4        /
nvme0n2                     2G disk
nvme0n4                     2G disk
nvme0n3                     2G disk
```

### Linux layout — after the rebuild

```
NAME                      SIZE TYPE  FSTYPE            MOUNTPOINT
sr0                       2.9G rom   iso9660
nvme0n1                    20G disk
├─nvme0n1p1               953M part  vfat              /boot/efi
├─nvme0n1p2               1.8G part  ext4              /boot
└─nvme0n1p3              17.3G part  LVM2_member
  └─ubuntu--vg-ubuntu--lv   10G lvm   ext4              /
nvme0n2                     2G disk
└─nvme0n2p1                 2G part  linux_raid_member
  └─md0                     2G raid1 ext4              /mnt/mirror
nvme0n4                     2G disk
└─nvme0n4p1                 2G part  linux_raid_member
  └─md0                     2G raid1 ext4              /mnt/mirror
nvme0n3                     2G disk
└─nvme0n3p1                 2G part  linux_raid_member
```

`md0` now sits under both `nvme0n2p1` and `nvme0n4p1`; `nvme0n3p1` still carries an old RAID signature but belongs to no array.

### The three states of the array

| State    | Evidence                       | What it shows                                   |
|----------|--------------------------------|-------------------------------------------------|
| Healthy  | evidence/array-healthy.txt     | `[2/2] [UU]`, `clean`, two disks `active sync`  |
| Degraded | evidence/array-degraded.txt    | `nvme0n3p1(F)`, `[2/1] [U_]`, `clean, degraded` |
| Rebuilt  | evidence/array-rebuilt.txt     | `[2/2] [UU]`, `clean`, `nvme0n2p1` + `nvme0n4p1` |

The checksums of `proof.txt` and `random.bin` are identical before and after the failure (`diff` printed `MATCH` after unmounting and mounting the array again, so the data was read from the one surviving disk).

## The question

Your colleague deleted the wrong file from the mirror an hour ago. Does RAID 1 help? Why?

No, RAID 1 does not help here. A mirror writes every change to both disks at the same time, so the deletion was copied to the second disk immediately and the file is gone from both. RAID 1 protects against the failure of a disk, not against deletion or mistakes; what would have helped is a backup or snapshot taken before the deletion, from which the file could be restored.

## What did not work the first time

- On Windows, `Initialize-Disk` failed with `PermissionDenied` because PowerShell was not started as administrator. As a result `New-Partition`, `Format-Volume` and `Get-Partition` also failed (no partition, no drive letter E) and Disk 1 stayed RAW. I reopened PowerShell with "Run as administrator" and repeated the commands; they worked.
- Copy and paste from the Mac into the Windows PowerShell window did not work, so I typed the commands by hand.
- `mdadm --create` asked two questions in a row (write-intent bitmap, then continue creating the array). I answered `yes`, but mdadm accepts only `y` or `n`, so it printed `bad option` and `create aborted`. I then re-ran the command with `--bitmap=internal --run`, which skips the questions. At one point I also lost one of the two partitions in the command, and mdadm said `You haven't given enough devices`; the array was created after I typed both partitions.
- I mistyped `mkfs.ext4` as `mkfs.ext`, so no filesystem was created and `mount` failed with `wrong fs type`. After running the correct command everything worked.
- I saved the checksums to `checksum-befor.txt` (typo), so `checksum-before.txt` stayed empty. I removed the wrong file and ran `sha256sum` again with the right name.
- `array-healthy.txt` first lacked the `mdadm --detail` output because I skipped that line; I saved the file again while the array was still healthy.
- The first `mdadm --add` was not actually run, and `watch` showed only one disk (`[2/1] [U_]`). I ran `--add /dev/nvme0n4p1` and saw the recovery start.

## Evidence

- [evidence/windows-disks.png](evidence/windows-disks.png) — Get-Disk, Get-Partition and firmware_type on Windows: both disks GPT, E: created, UEFI
- [evidence/lsblk-before.txt](evidence/lsblk-before.txt) — layout before: three new 2 GB disks, no partitions
- [evidence/array-healthy.txt](evidence/array-healthy.txt) — healthy mirror, `[UU]`, `clean`
- [evidence/checksum-before.txt](evidence/checksum-before.txt) — SHA-256 of `proof.txt` and `random.bin` before the failure
- [evidence/array-degraded.txt](evidence/array-degraded.txt) — one disk failed, `[U_]`, `clean, degraded`
- [evidence/checksum-after-failure.txt](evidence/checksum-after-failure.txt) — same checksums after unmount/mount with one disk, `diff` printed `MATCH`
- [evidence/array-rebuilt.txt](evidence/array-rebuilt.txt) — rebuilt onto the spare, `[UU]`, `clean`
