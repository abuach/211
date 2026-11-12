---
marp: true
theme: default
paginate: true
size: 16:9
header: 'CPTR 211 · Linux unit'
footer: 'Weeks 8–10'
style: |
  section {
    font-size: 28px;
    background: #fbfaf7;
    color: #1f2933;
  }
  h1, h2 { color: #1d3557; }
  strong { color: #b5482a; }
  table { font-size: 24px; }
  th { background: #1d3557; color: #fbfaf7; }
  section.tight { font-size: 24px; }
  section.tight table { font-size: 21px; }
  section.lead {
    justify-content: center;
    text-align: center;
  }
  section.lead h1 { font-size: 64px; }
  section.dark {
    background: #1d3557;
    color: #e8eef5;
  }
  section.dark h1, section.dark h2 { color: #fbfaf7; }
  section.dark strong { color: #f4a261; }
  section.dark header, section.dark footer { color: #9fb3c8; }
  blockquote { border-left: 6px solid #b5482a; color: #52606d; }
---

<!-- _class: lead -->
<!-- _paginate: false -->

# Linux System Administration

### CPTR 211 · Weeks 8–10

Same jobs. Different tools.

<!--
Welcome to the Linux half. Timing: about 15 minutes for the whole deck.
For a 5-minute version on Day 1, show slides 1–5, the timeline (slide 10), and slides 17–19; save the rest of the history for Day 2's intro.
-->

---

## You already know how to run a server

In 7 weeks of Windows Server you have:

- installed an operating system
- created **users and groups**
- set **permissions** on folders and **shared** them
- read **logs** and set **firewall** rules
- made **backups** and **scheduled tasks**

**For the next 3 weeks you'll do the same jobs on Linux.** The ideas carry over. Only the tools are new.

<!--
Key message: this is not starting over. Every lab maps to something they already did in Windows.
Ask: "Who has used Linux before? Who has never typed a command into a terminal?" Reassure the second group.
-->

---

<!-- _class: tight -->

## At a glance: the big picture

| | Windows Server | Linux (Ubuntu Server) |
|---|---|---|
| **Made by** | One company: Microsoft | Thousands of contributors; packaged by a *distribution* (Ubuntu, Red Hat, …) |
| **Cost** | Paid licenses + client access licenses (CALs) | Free to use, copy and change; paid support is optional |
| **Source code** | Closed | Open: anyone can read it |
| **Main interface** | Graphical (Server Manager); Server Core is optional | **Command line**; most servers have no GUI at all |
| **Remote admin** | Remote Desktop (RDP), PowerShell remoting | **SSH** (a secure terminal over the network) |
| **Updates** | Windows Update | `apt` updates the OS *and* every installed program |

<!--
Don't read the table. Pick three rows:
- Cost: no license keys, no CALs. You can run 1,000 Linux servers for free.
- Interface: the command line is the normal way, not the fallback. Server Core is the closest Windows comparison.
- Updates: one command updates everything, not just Microsoft's software.
-->

---

<!-- _class: tight -->

## At a glance: day to day

| | Windows | Linux |
|---|---|---|
| **Admin account** | Administrator / *Administrators* group | `root`, used through **`sudo`** |
| **Files** | `C:\Users\maria` (drive letters, backslash) | `/home/maria` (one tree from `/`, forward slash) |
| **Names** | `Report.txt` = `report.txt` | `Report.txt` ≠ `report.txt` (**case-sensitive**) |
| **Settings** | Registry and GUI panels | Plain-text files in `/etc` |
| **Installing software** | Installers, Add Roles and Features, `winget` | `sudo apt install nginx` |
| **Services** | `services.msc`, `Get-Service` | `systemctl status nginx` |
| **Logs** | Event Viewer | `/var/log`, `journalctl` |
| **Scripting** | PowerShell (passes objects) | Bash (passes text) |
| **Deleted a file?** | Recycle Bin | **Gone.** There is no Recycle Bin. |

<!--
These are the gotchas that trip beginners in week 1: case sensitivity, forward slashes, no Recycle Bin.
Point out that every row is on the Windows → Linux Cheat Sheet in the handouts folder.
-->

---

## What stays the same

| Job | Windows tool | Linux tool |
|---|---|---|
| Accounts | Local Users and Groups | `adduser`, `usermod` |
| Folder permissions | NTFS Security tab | `chmod`, `chown`, ACLs |
| File shares | File Server role, `\\server\share` | **Samba** (speaks the same SMB protocol) |
| Firewall | Defender Firewall | `ufw` |
| Backups | Windows Server Backup | `tar`, `rsync` |
| Scheduled jobs | Task Scheduler | `cron` |

The **concepts** are identical: least privilege, groups over individuals, back up before you change things.

<!--
Samba is a nice bridge: a Linux server can serve shares to Windows PCs, and Windows can't tell the difference. They'll do this in Lab 6.
-->

---

<!-- _class: lead dark -->

# Why are they so different?

### A short history

<!--
Transition: the differences on the last slides aren't random. They come from two very different family trees.
-->

---

## 1969: Unix

- Written at **AT&T Bell Labs** by Ken Thompson and Dennis Ritchie
- Rewritten in **C** in 1973, so it could move to new kinds of computers
- Universities got the source code and changed it (Berkeley's version became **BSD**)
- Built for **many users sharing one machine** over terminals

Ideas Linux still uses today:
- **Everything is a file**, in one tree starting at `/`
- **Small tools that do one thing**, joined with pipes: `ps aux | grep nginx`
- **Settings in plain text** you can read and edit

<!--
Unix was multi-user from day one: users, groups, and file permissions (owner/group/others, rwx) date from this era. That's exactly what Labs 4 and 5 cover, and why Linux permissions look so different from NTFS.
Fun fact: Ritchie also created the C language, partly to write Unix.
-->

---

## 1983–1991: GNU + Linux

**1983 · GNU.** Richard Stallman starts building a free Unix-like system that anyone may **run, study, share and change**. By 1991 it has the tools, but **no kernel**.

**1991 · Linux.** Linus Torvalds, a 21-year-old student in Helsinki, posts a hobby kernel online:

> "just a hobby, won't be big and professional like gnu" (Linus Torvalds, 1991)

**GNU tools + the Linux kernel = a complete, free OS.** Programmers worldwide sent improvements, and still do.

<!--
The kernel is the core that talks to the hardware. GNU supplied almost everything else.
In 1992 Linus put Linux under the GNU General Public License (GPL): anyone can use and change it, but if you share your changes you must share the source too. That rule is why Linux stayed open.
Linus also wrote Git in 2005 to manage the kernel's code.
-->

---

## Meanwhile, at Microsoft

- **1981 · MS-DOS** ships on the IBM PC: one user, one computer, drive letters (`A:`, `C:`)
- **1985 · Windows 1.0**: a graphical layer on top of DOS
- **1993 · Windows NT**: a new, multi-user, networked OS, designed by a team led by Dave Cutler
- Every Windows Server you used this term is a **descendant of NT**

Windows grew from **personal computers** toward servers.
Linux grew from **shared, multi-user servers** toward everything else.

<!--
This explains a lot:
- Drive letters and backslashes come from DOS.
- Case-insensitive file names come from DOS.
- GUI-first administration comes from the desktop heritage.
- Linux's command-line-first, text-file culture comes from Unix terminals.
-->

---

<!-- _class: tight -->

## Two family trees

| Year | Unix / Linux | Windows |
|---|---|---|
| 1969 | Unix at Bell Labs | |
| 1981 | | MS-DOS |
| 1983 | GNU project begins | |
| 1985 | | Windows 1.0 |
| 1991 | Linux kernel announced | |
| 1993 | Debian, Slackware (early distributions) | Windows NT 3.1 |
| 2004 | **Ubuntu** 4.10 | |
| 2008 | Android (Linux inside) ships | Windows Server 2008 |
| 2016 | | Windows Subsystem for Linux (WSL) |
| 2024 | | Windows Server 2025 |
| 2026 | **Ubuntu 26.04 LTS** (what we'll install) | |

<!--
Linux is about 35 years old; its Unix roots are over 55 years old.
Ubuntu's name comes from a Southern African philosophy, often translated "humanity towards others."
-->

---

## From rivals to roommates

- **2001:** Microsoft's CEO Steve Ballmer calls Linux "a cancer"
- **2014:** new CEO Satya Nadella: "Microsoft ♥ Linux"
- **2016:** Microsoft joins the Linux Foundation and ships **WSL**, which runs Linux inside Windows
- **Today:** Microsoft's Azure cloud runs more Linux VMs than Windows VMs

**Most real companies run both.** Being able to manage both makes you far more employable.

<!--
The point for students: this isn't a Windows-vs-Linux contest. A typical shop has Active Directory and Windows file servers next to Linux web servers, databases and containers.
WSL: they can run Ubuntu on a Windows laptop to practice outside the lab.
-->

---

## Where Linux runs today

- **Every one** of the world's 500 fastest supercomputers (since 2017; source: TOP500.org)
- **Most of the cloud** and most web servers
- **Android** phones: billions of devices
- Routers, smart TVs, cars, the Steam Deck, the Mars helicopter *Ingenuity*
- **Containers** (Docker, Kubernetes) are Linux under the hood

If you work in IT, you **will** log in to a Linux server, usually over SSH, with no GUI.

<!--
Ask the class: "How many of you have a Linux computer in your pocket?" (Anyone with an Android phone.)
-->

---

<!-- _class: tight -->

## One kernel, many distributions

Windows is **one product**. Linux is a **kernel** that others package into a complete OS called a **distribution** ("distro"):

| Distro | Who makes it | Known for |
|---|---|---|
| **Ubuntu** | Canonical (company) | Easy to use; very common on servers and in the cloud |
| Debian | Volunteers | Stable; Ubuntu is built on it |
| Red Hat Enterprise Linux | Red Hat (IBM) | Big companies; paid support |
| Fedora, Rocky, Alma | Community | Free relatives of Red Hat |

We use **Ubuntu Server 26.04 LTS**: released April 2026, with **Long-Term Support** (security updates for 5 years).

<!--
Distros differ mostly in the package manager and defaults. What you learn on Ubuntu works on Debian almost unchanged, and most of it works on Red Hat (dnf instead of apt, a few file locations differ).
-->

---

<!-- _class: lead dark -->

# The next 3 weeks

<!--
Transition from history to logistics.
-->

---

## You're the new sysadmin at Riverbend Outfitters

A small outdoor-gear company needs its first Linux server. Over 9 class days you will:

1. **Install** it and connect to it remotely
2. Create the **staff accounts** and department groups
3. Lock down each department's **folders**
4. **Share** them with the company's Windows PCs
5. Watch for **break-in attempts** and turn on the firewall
6. **Back it all up**, then fix it when it **breaks**

<!--
Each lab builds on the last, on the same server. Stress: finish each lab before the next class or you'll fall behind.
-->

---

<!-- _class: tight -->

## The plan

| Week | Day | Lab | The Windows version |
|---|---|---|---|
| 1 | 1 | Installing Linux & logging in | Windows Server install, Remote Desktop |
| 1 | 2 | Files & folders | File Explorer, `C:\` |
| 1 | 3 | Software & services | Windows Update, Add Roles (IIS), services.msc |
| 2 | 4 | Users & groups | Local Users and Groups, ADUC |
| 2 | 5 | Permissions | NTFS permissions, the Security tab |
| 2 | 6 | File sharing with Samba | File Server role, `\\server\share` |
| 3 | 7 | Monitoring, logs & firewall | Task Manager, Event Viewer, Defender Firewall |
| 3 | 8 | Backups & scheduled tasks | Windows Server Backup, Task Scheduler |
| 3 | 9 | Automation & troubleshooting | PowerShell scripts, the help desk |

All labs are at **github.com/abuach/211**

<!--
Day 9 is a troubleshooting challenge: the lab tool will break their server in six ways and they have to find and fix each one. Don't reveal the specifics.
-->

---

## How every lab works

1. Your server is a **VM on Proxmox** (it stays on when you log out)
2. On any CS Lab computer, open a terminal: **Ctrl + Alt + T**
3. Connect: `ssh student@172.27.x.x`
4. Follow the lab, **pasting** commands with **Ctrl + Shift + V**
5. Check your work: `lab check 3` → ✔ PASS / ✘ FAIL, with a hint for every FAIL
6. Screenshot the passing check and submit it

**Broke something?** Roll back to a Proxmox **snapshot**.

<!--
Proxmox: https://proxmox.cs.wallawalla.edu:8006, realm CS-LDAP. They should have checked this in the "Before Day 1" homework.
Snapshots are the safety net: tell them it's fine to experiment.
-->

---

## Survival tips

| Keys / habit | Why |
|---|---|
| **Tab** | Finishes names for you: fewer typos |
| **↑** | Brings back your last command |
| **Ctrl + C** | Stops whatever is running (the panic button) |
| **Ctrl + Shift + V** | Paste into the terminal (plain Ctrl + V won't work) |
| No news is good news | Most commands print **nothing** when they succeed |
| Read the error | It usually tells you exactly what's wrong |

Keep the **Windows → Linux Cheat Sheet** open during every lab.

<!--
"No news is good news" surprises Windows users the most: a silent prompt means success.
-->

---

<!-- _class: lead -->

## Today: Lab 1

Install **Ubuntu Server 26.04** · log in over **SSH** · install the `lab` tool

**First step:** in Proxmox, check that your VM's CD drive holds the **Ubuntu** ISO

<!--
Go straight into Lab 1. The installer takes about 10 minutes of waiting, so have students read Part B while it runs.
Some VMs may have a Windows ISO or no disc loaded; Lab 1 step 2 tells students how to fix it.
-->
