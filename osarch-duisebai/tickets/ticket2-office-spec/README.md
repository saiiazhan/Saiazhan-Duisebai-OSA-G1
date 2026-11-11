# Ticket 2: "We are kitting out the new office"

Prices taken 2026-11-11. Currency: Kazakhstani tenge (KZT).

## 1. What was asked

```
From: Daniyar K. (Director)
Subject: computers for the new office

We are opening the second office and need four computers — accountant,
sales, web developer, designer. Budget 3,000,000 tenge for everything.
Everyone says we should just buy the same four machines, is that right?
Make sure they last a few years. Monitors included.
```

## 2. What was actually needed

**The director's question has a direct answer and the answer is no.** "The same four machines" is wrong because the four people stress a computer in four different ways. Memory is the scarce resource for the sales manager and the developer, storage reliability for the accountant, and the screen and graphics for the designer. Four identical machines would overspend on the accountant (who needs 16GB, not 32GB) and underspend on the designer (who needs a better monitor than the others). The sensible part of the instinct is spare parts and re-imaging, so the four builds share motherboard, case, PSU, SSD and OS licence and differ only in memory, CPU and monitor (builds.md).

**What the request left out, and what I assumed instead.** I could not ask the director, so each gap has a stated assumption. Each question below is what I would have asked.

| Gap | Question I would have asked | What I assumed |
|---|---|---|
| Desktop or laptop | "Do these people sit at desks or move between offices?" | Desktops. "Monitors included" implies desks, and desktops give more performance per tenge. |
| What the four people run | "Which programs does each person have open all day?" | Accountant: 1C plus large Excel files. Sales: CRM in a browser with 30 to 40 tabs, video calls. Developer: IDE, containers, build tools. Designer: Figma, Photoshop, Illustrator, 2D only (no video, no 3D). |
| "A few years" | "Three years, or five?" | About five years, which is why I paid for the AM5 platform (newer CPUs and a graphics card can be added later) and a 550 W Gold power supply. |
| What the 3,000,000 covers | "Does it include Windows, delivery, keyboards, a UPS, VAT?" | It covers computers, monitors and licensed Windows 11 Pro (the ticket requires a licensed OS). Prices are shop prices as shown, which include VAT. Keyboards, mice, webcams, UPS and delivery fees are not included. |
| Where the office is | "Which city?" | Almaty. The sellers used ship from Almaty and post across Kazakhstan. If the office is elsewhere, courier cost and times change. |
| Who looks after them | "Who assembles them and who handles warranty?" | The company has no IT person. This matters for the build-versus-buy answer below. |
| What happens to the data | "Is anything on the accountant's machine backed up?" | Not stated and not budgeted. I chose Windows 11 Pro for BitLocker disk encryption on that machine. A backup is a separate decision. |

**Where the request is wrong or misleading, beyond the "same four machines".**

1. "Budget 3,000,000 for everything" hides the fact that the memory market is at a peak. On 2026-11-11 a 32GB DDR5 kit costs 295,448 KZT and a single 16GB stick 119,381 KZT (evidence/vendor-quotes/01). Going from 16GB to 32GB costs 176,067 KZT per machine. At 750,000 KZT per computer ("3 million divided by four") a 32GB machine with a monitor and Windows barely fits, so the whole question is who gets 32GB.
2. "Make sure they last a few years" is not a specification. Memory, graphics and monitors age differently, so I answered it by naming the one thing on each machine that would be upgraded first (question 1).
3. "Monitors included" quietly adds about 60,000 to 130,000 KZT per person. For the designer the monitor is not an accessory, it is the main tool.

## 3. What I did

### 3.1 Steps, in order

1. Fixed the roles and the assumptions above, because prices depend on them.
2. Chose the platform: AM5, DDR5, micro-ATX. Compared against the pre-built AM4/DDR4 PULSER Compact 15 at 275,997 KZT (evidence/vendor-quotes/06).
3. Priced each part at a Kazakhstan seller that ships from Almaty, on 2026-11-11: alfa.kz (an Almaty marketplace) for RAM, CPU, monitor, Windows and pre-built PCs; e-katalog.kz (price aggregator listing Kazakhstan shops) for motherboard, SSD, PSU, case, Ryzen 7 7700 and cooler. Each price is in `budget.csv` with seller, URL and date.
4. Built the four configurations and recomputed the totals with a command, not by hand:

```sh
# run on Linux (GNU awk); plain POSIX awk, so it should also work in macOS Terminal (BSD awk) but I have not run it on a Mac
awk -F, 'NR>1{t[$1]+=$4; s+=$4} END{for(r in t) printf "%-14s %9d\n", r, t[r]; printf "%-14s %9d\n", "TOTAL", s; printf "%-14s %9d\n", "RESERVE", 3000000-s}' budget.csv | sort
```

Output: accountant 566,423; sales 742,490; web developer 750,958; designer 813,430; total 2,873,301; reserve 126,699 (full output in evidence/budget-check.txt).

5. Checked the hard requirements (16GB or more, 1TB SSD, licensed OS, monitor) for every role with a second command (same file).
6. Priced the pre-built alternative (question 2) and wrote the three answers.

### 3.2 Decisions, with the alternative and the trade-off

| Decision | Alternative I considered | Why this one, and what it costs |
|---|---|---|
| AM5 + DDR5 | AM4 + DDR4 pre-built, 154,231 KZT cheaper for the accountant tier | AM5 can take newer CPUs and a graphics card; AM4 is at the end of its life and the 300 W PSU in the pre-built cannot power a card. It costs 154,231 KZT more on the accountant machine alone, and the premium is mostly DDR5 memory prices. |
| Windows 11 Pro OEM, 76,980 | Windows 11 Home OEM at 70,657; keys at 2,950 to 10,000 KZT on other marketplaces | Pro adds BitLocker and domain join for a 6,323 KZT difference. The cheap keys have no licence paperwork, and the ticket requires a licensed OS, so they were not counted. An OEM licence is tied to the machine it is first installed on. |
| Accountant: one 16GB stick | A 2x8GB kit at 133,311 | Single channel is slower but not noticeably so for this load; saves 13,930; leaves three free slots for a clean upgrade. |
| Developer: Ryzen 7 7700 OEM + separate cooler (108,395) | Boxed 7700 at 157,705 | 49,310 KZT cheaper for the same chip and a comparable cooler. The cost is one more part to assemble. |
| Designer: no graphics card, QHD 99% sRGB monitor | RTX 5050 8GB at 168,050 with the cheap monitor | The card would have taken the total to 3,041,351, over budget. The designer's first deficit is the cost of keeping the colours right. |
| A620 motherboard | A B650 board | A620 is enough for these CPUs at stock speeds. It saves money and gives up overclocking and a second fast M.2 slot, neither of which these roles need. |
| 550 W 80 PLUS Gold PSU for all | A cheaper 450 W unit (not priced) | Enough headroom for the designer's later graphics card, and a PSU is the part whose failure damages other parts. The cost is the price gap to a cheaper unit, which I did not look up. |
| Several sellers (five named, plus two alfa.kz listings that show no seller) | One seller for everything | Buying from one shop would simplify delivery but I could not confirm one shop had every part at a competitive price. The cost is more invoices and deliveries; Section 5 says what I would do about it. |

### 3.3 Answers to the director's three questions

**Question 1. Which of the four machines will you upgrade first, 18 months from now, and why?**

The designer's. It is the only machine with a deliberately deferred component (the graphics card). Image files and the tools' use of graphics acceleration both grow, while the rest of the machine (32GB, 550 W PSU, free PCIe x16 slot) is already prepared for it. The upgrade is one part, about 168,000 KZT at today's price (RTX 5050 8GB, Greenprice.kz via e-katalog.kz). The second upgrade, a second 16GB stick, goes to the accountant and costs about 119,000 KZT today. Memory prices may be lower in 18 months, which is a reason not to buy the accountant's extra RAM now.

**Question 2. Price the same four as pre-built machines from a vendor. What does the company gain and what does it lose by not building them?**

Priced at alfa.kz on 2026-11-11, each with Windows 11 Pro (76,980) and a monitor added because the pre-built listings found do not list them:

| Role | Closest pre-built found | Pre-built + OS + monitor | My build | Difference |
|---|---|---|---|---|
| Accountant | PULSER Compact 15, Ryzen 5 5600GT, 16GB DDR4, 1TB, 300 W: 275,997 | 412,192 | 566,423 | pre-built 154,231 cheaper |
| Sales | PULSER Advanced 422, Ryzen 5 7500F, 32GB, 1TB, **RTX 5060 Ti**: 1,134,490 | 1,270,685 | 742,490 | pre-built 528,195 dearer |
| Web developer | same as sales | 1,270,685 | 750,958 | pre-built 519,727 dearer |
| Designer | same as sales, with the QHD monitor | 1,341,625 | 813,430 | pre-built 528,195 dearer |
| **Total** | | **4,295,187** | **2,873,301** | **pre-built 1,421,886 (49%) dearer, over the 3,000,000 budget** |

What the pre-built prices say: the cheap tier is a real saving, but I found no pre-built with 32GB and a 1TB SSD that has no graphics card; every one at this marketplace came bundled with a GPU the sales manager and the developer do not need. A cheaper listing of the same model at 909,901 is wholesale only (5 or more units). A branded pre-built with Windows and a 3-year warranty in its model name (Lenovo ThinkCentre neo 50q Gen 4, 311,744) has a 512GB SSD and fails the requirement. This was a page-1 scan of one marketplace, not a full market survey (evidence/vendor-quotes/06).

What the company **gains** by buying pre-built: one invoice, a warranty on the whole machine, no assembly time, and nobody to blame for a compatibility fault. That matters because the company has no IT person.
What it **loses**: the 154,231 KZT saving exists only on the cheapest tier, and it comes with an end-of-life AM4/DDR4 platform and a 300 W power supply. In the 32GB tier it loses the ability to choose and pays for a GPU it will not use. It also gives up knowing which parts are inside.

My recommendation, and it is a judgement and not a measurement: build three (sales, developer, designer) and consider buying the accountant's machine pre-built if the company wants one warranty-backed machine and accepts a shorter life. I did not do that in the build because it mixes platforms and breaks the shared-spares argument.

**Question 3. One of these four people will complain about performance within a month. Which one, and about what?**

The designer, about graphics: lag when zooming and panning a large Photoshop or Illustrator file, and graphics-accelerated effects that run slowly, because the machine has only the processor's small built-in graphics and is driving a QHD screen. This is a prediction from the specification; I did not benchmark it. It is also the complaint I accepted on purpose to keep the monitor and the memory (builds.md, Build 4). The accountant will not complain about speed. The sales manager and the developer have 32GB, so their performance complaint would come later.

## 4. Evidence

Every file in `evidence/` carries a first line starting "PROVES:". The vendor-quote files are text extractions made on 2026-11-11 from the pages listed, not screenshots. `budget.csv` (outside `evidence/`) holds every component, model, price, seller, URL and date, and the totals are computed from it.

| File | What it proves |
|---|---|
| `evidence/budget-check.txt` | Output of the totals command and the hard-requirement check on `budget.csv`. |
| `evidence/vendor-quotes/01-alfa-ddr5-listing.md` | DDR5 prices on 11 Nov and the 176,067 KZT difference between 16GB and 32GB. |
| `evidence/vendor-quotes/02-alfa-ryzen5-7600.md` | The Ryzen 5 7600 price and that it is the stalest in the sheet. |
| `evidence/vendor-quotes/03-alfa-windows11-oem.md` | Licensed Windows 11 prices and why the cheap keys were not counted. |
| `evidence/vendor-quotes/04-monitors.md` | The two monitor prices and the rejected 4K alternative. |
| `evidence/vendor-quotes/05-ekatalog-parts.md` | Seller and price of motherboard, SSD, PSU, case, Ryzen 7 7700 and cooler, each shipping from Almaty. |
| `evidence/vendor-quotes/06-prebuilt-prices.md` | The pre-built prices used for question 2. |
| `evidence/pcpartpicker-links.md` | The part lists to paste into PCPartPicker for the compatibility check; the saved list links are still to be added. |

**What is not proven yet, stated plainly.**

- Nobody other than the author has worked from this document. A second person re-pricing three parts from the URLs in `budget.csv` is the test I would run before submitting.
- The four PCPartPicker lists have not been created yet (see the file). PCPartPicker has no Kazakhstan shops, so it is used only to check that parts fit together, not for prices.
- The Ryzen 5 7600 price is from a listing last updated 23 Oct. It appears on three of the four builds.

## 5. What I would do differently

- I would ask the director which programs each person uses before choosing anything. Every spec above rests on my guesses about the four workloads, and the designer's missing graphics card is the biggest risk if the guess is wrong.
- I would take every price within one hour, from a browser screenshot plus saved page text, and phone the two largest sellers (RAM and CPU) to ask for a written quote for four machines. DDR5 prices moved noticeably within the weeks I looked at, and a seller's written quote would be a stronger piece of evidence than a listing.
- I would test "can someone else follow this" by handing `budget.csv` to a classmate with the URLs only, before submitting, instead of listing it as a gap.
- I used five named sellers and two listings with no seller shown. I would ask one or two shops for a combined offer, because the saving from shopping around is probably smaller than the handling cost of that many deliveries and invoices for an office with no IT person.
