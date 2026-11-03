# Ticket 1: New developer starts Monday, needs a test machine

## 1. What was asked

> From: Aigerim T. (Office Manager)
> Subject: test machine for new dev
>
> Hi, we have someone starting on Monday and he needs a test computer
> set up. Nothing special, just so he can try things without breaking
> anything. Can you write down how to do it so I can do the next one
> myself? Thanks

## 2. What was actually needed

DRAFT. Check every line is true for you, and keep only what you can explain in sixty seconds.

- **"A test computer" does not say physical or virtual.** I assumed virtual (two VMs on my Mac), because "without breaking anything" is solved by a snapshot, which a physical PC does not have.
- **It does not say which operating system.** I assumed Linux and Windows, because the ticket's output asks for both guests. I would have asked the developer which one he uses.
- **"Nothing special" gives no sizes.** I chose the sizes myself from my host's real memory and disk (section 3).
- **Where the request is wrong.** Aigerim asked for one computer, but what she needs is a repeatable procedure: the real reader of BUILD.md is her, not the developer. So every step is written for someone who does not know words like "ISO" or "hypervisor".
- **Hidden requirement: the processor type.** My Mac has an Apple chip, so the Windows and Ubuntu images have to be the ARM64 versions. The ticket says nothing about this and a wrong download will not start.
- **It does not say where Windows comes from or who pays for the licence.** I assumed the company buys the licence; BUILD.md says so.
- **"Without breaking anything"** I read as "he must be able to go back to a clean state": a snapshot called `clean-install`.

## 3. What I did

**Host (real numbers):** MacBook Pro, Apple M5, 10 cores, 16 GB memory, 512 GB SSD (500 GB shown by macOS).

| Setting | Ubuntu Server (ARM64) | Windows 11 (ARM64) | Default / why changed |
|---------|----------------------|--------------------|------------------------|
| CPU cores | 2 | [check: 2] | [the default is bigger; I lowered it because ...] |
| Memory | 6 GB | [check: 4 GB] | [why] |
| Disk | 20 GB | [check: 64 GB] | [why] |
| Network | NAT | NAT | [why NAT, and not Bridged] |

**Resource calculation:** two machines use 6 GB + [4 GB] = [10 GB] of the Mac's 16 GB, which leaves [6 GB] for macOS. Disks use 20 + [64] = [84 GB] of 500 GB.

**Alternatives I considered (fill in):**
- Bridged network instead of NAT: [why not].
- Ubuntu Desktop instead of Server: [why not].
- A physical test PC instead of VMs: [why not].

**One thing that went wrong:** [write one REAL problem from your own build and how you fixed it. A document with no problems is not believed.]

Steps are in order in `BUILD.md`.

## 4. Evidence

| File | What it proves |
|------|----------------|
| `evidence/01-new-vm-wizard.png` | [the wizard with the ISO selected: the starting point] |
| `evidence/02-disk-settings.png` | [the size I gave the machine] |
| `evidence/03-network-adapter.png` | [that the adapter is NAT] |
| `evidence/04-guest-uname.txt` | [that the Linux guest runs: output of `uname -a`] |
| `evidence/05-ping-between-guests.txt` | [that the guests see each other and the internet] |
| `evidence/06-snapshot-list.png` | [that the clean snapshot exists] |
| `review/feedback-from-<surname>.md` | [added in week 5: where a classmate got stuck] |

## 5. What I would do differently

[Write ONE specific thing, for example about this build. "Nothing" earns 0.]
