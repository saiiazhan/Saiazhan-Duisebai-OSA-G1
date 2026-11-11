# Four builds, with reasoning

Prices are in tenge, taken on 2026-11-11 from Kazakhstan sellers (see `budget.csv` for every line, seller and URL). Totals below are recomputed by the command in README section 3, not typed by hand.

## What the four machines share, and why

All four use the same motherboard (Gigabyte A620M GAMING X AX), case (Zalman M5), power supply (be quiet! Pure Power 12 M 550 W Gold), SSD (Kingston NV3 1TB) and Windows 11 Pro OEM licence. The director's instinct that "same machines" is easier is right about one thing: spare parts and re-imaging. I kept that for the parts that do not decide performance, and varied only the things that do: memory, CPU, monitor.

Platform: AM5 with DDR5. The alternative was AM4 with DDR4, which is cheaper today (README, question 2). I took AM5 because the requirement is "last a few years": AM5 can take newer CPUs and a graphics card later without replacing the board, AM4 cannot.

| Role | Build total KZT | RAM | CPU | Monitor |
|---|---|---|---|---|
| Accountant | 566,423 | 16GB (1 stick) | Ryzen 5 7600 | AOC 27in FHD |
| Sales manager | 742,490 | 32GB (2x16GB) | Ryzen 5 7600 | AOC 27in FHD |
| Web developer | 750,958 | 32GB (2x16GB) | Ryzen 7 7700 + tower cooler | AOC 27in FHD |
| Designer | 813,430 | 32GB (2x16GB) | Ryzen 5 7600 | ASUS 27in QHD 99% sRGB |
| **All four** | **2,873,301** | | | **Reserve 126,699** |

Hard requirements (16GB+, 1TB SSD, licensed OS, monitor) are met by every row; the check is in `evidence/budget-check.txt`.

---

## Build 1: Accountant

**Load.** Accounting software (assumed 1C), large Excel workbooks, a browser, PDF and e-mail. Documents contain financial data.

**Bottleneck.** Storage reliability and responsiveness, not CPU or graphics. The CPU idles. A slow or failing disk loses data and stalls 1C; a 1TB NVMe drive removes the slow-disk problem. Memory only matters when several large workbooks and 1C are open together, and 16GB covers that.

**Trade-off accepted.** 16GB in a single stick instead of a 2x8GB kit. A single stick runs memory in single-channel mode, which halves memory bandwidth; for Excel and 1C that is not noticeable, and it only hurts integrated graphics. In exchange the machine has three free DIMM slots and the first upgrade is "buy a second identical stick" (dual channel, 32GB). The 2x8GB kit would cost 133,311 against 119,381 now, 13,930 more, and leaves no clean upgrade path. Windows 11 **Pro** rather than Home, for BitLocker (disk encryption), because this is the machine holding financial data.

**Not in the build.** A second monitor. Accountants work with two windows side by side all day, and a second AOC (59,215) is the first thing to buy from the reserve.

**Total: 566,423 KZT.**

## Build 2: Sales manager

**Load.** A CRM in the browser with 30 to 40 tabs, Excel, several hours of video calls per day, often all at once.

**Bottleneck.** Memory. A browser with that many tabs plus a video call plus Excel plus Windows itself approaches 16GB, and when RAM runs out Windows starts writing memory to disk in the middle of a customer call. CPU is secondary (6 cores is plenty) and graphics are irrelevant.

**Trade-off accepted.** Memory is the most expensive item right now: a 32GB DDR5 kit is 295,448 and a single 16GB stick is 119,381, so the extra 16GB costs 176,067 per machine. I paid it here because a stall during a customer call is visible to a customer, and I paid for it by taking the cheap 1080p monitor and the 6-core CPU.

**Total: 742,490 KZT.**

## Build 3: Web developer

**Load.** Code editor or IDE, local containers or virtual machines, several browsers, a build tool that runs on every save, often a database next to it.

**Bottleneck.** Memory first (containers and an IDE each take several GB), then the number of CPU cores for compiling and test runs. Disk speed matters less than for the accountant.

**Trade-off accepted.** Ryzen 7 7700 (8 cores / 16 threads) instead of the Ryzen 5 7600 (6 / 12), bought as an OEM chip at 92,745 plus a separate cooler at 15,650 = 108,395. The boxed 7700 comes with a cooler but costs 157,705, which is 49,310 more than the OEM chip plus cooler. The cost of putting the money into CPU and RAM is the monitor: a 27in 1080p panel is soft for reading code. A QHD monitor (ASUS BE27AQ, 130,155, +70,940) is the first thing to buy from the reserve for this role.

**Total: 750,958 KZT.**

## Build 4: Designer

**Load.** Interface and graphic design: Figma, Photoshop, Illustrator, large image files, many layers. Assumed to be 2D work (no video editing, no 3D rendering); if the role includes either, this build is wrong.

**Bottleneck.** Three things, in this order: the monitor (a designer who cannot trust colours cannot do the job, whatever the computer does), memory (large layered files), then graphics performance when panning and zooming a big canvas.

**Trade-off accepted.** There is **no discrete graphics card**. The Ryzen 7600 has a small integrated GPU and that is all this machine has. The money went to the monitor (QHD, 99% sRGB, 350 cd/m2, adjustable stand) and 32GB of memory. A GeForce RTX 5050 8GB was priced at 168,050 (Palit, Greenprice.kz, e-katalog.kz, 2026-11-11); buying it now would have put the total at 3,041,351, over budget. The board has a free PCIe x16 slot and the 550 W power supply is the size those cards ask for, so the card can be added later without replacing anything. I also rejected a 4K monitor (Samsung ViewFinity S8, 165,298; 35,143 more than the ASUS) because a 4K canvas on integrated graphics would be the first thing to feel slow.

**Honest limit.** The monitor covers 99% of sRGB but has no hardware calibration. For print work a colorimeter is needed; it is not in the budget.

**Total: 813,430 KZT.**

---

## What is not in the 3,000,000

Keyboards, mice, webcams, headsets, a UPS, cables, delivery fees and assembly time. The reserve of 126,699 KZT is intended for the two upgrades named above (the accountant's second monitor, 59,215, and the developer's QHD monitor, 70,940 more than the FHD one), which together are 130,155 and slightly exceed it; do one of them, or wait for prices to fall.
