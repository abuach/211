# CPTR 211: Linux System Administration Labs

These are the labs for the **Linux unit** (weeks 8-10) of **CPTR 211 Linux and Windows System Administration**. You've spent 7 weeks running Windows Server. Now you'll do the same jobs on **Linux**, and every lab shows you how the Linux way compares to the Windows way you already know.

**The story:** you've just been hired as the sysadmin at **Riverbend Outfitters**, a small outdoor-gear company. Over 9 class days you'll build its Linux server: install it, create the staff accounts, lock down department folders, share them with Windows PCs, watch for attacks, back everything up, and fix it when it breaks.

## The labs

| Week | Day | Lab | You'll learn | Windows version of the same idea |
|---|---|---|---|---|
| — | before class | [Before Day 1](labs/lab00-before-day-1.md) | Find your VM in Proxmox | |
| 1 | 1 | [Installing Linux & logging in](labs/lab01-install-linux.md) | Install Ubuntu Server, connect with SSH | Installing Windows Server, Remote Desktop |
| 1 | 2 | [Files & folders](labs/lab02-files-and-folders.md) | Move around and manage files from the command line | File Explorer, `C:\` |
| 1 | 3 | [Software & services](labs/lab03-software-and-services.md) | Install software, run a web server | Windows Update, Add Roles (IIS), services.msc |
| 2 | 4 | [Users & groups](labs/lab04-users-and-groups.md) | Create and manage accounts | Local Users and Groups, ADUC |
| 2 | 5 | [Permissions](labs/lab05-permissions.md) | Control who can open which files | NTFS permissions, the Security tab |
| 2 | 6 | [File sharing with Samba](labs/lab06-file-sharing-samba.md) | Share folders with Windows computers | The File Server role, `\\server\share` |
| 3 | 7 | [Monitoring, logs & firewall](labs/lab07-monitoring-and-security.md) | Spot problems and break-in attempts | Task Manager, Event Viewer, Defender Firewall |
| 3 | 8 | [Backups & scheduled tasks](labs/lab08-backups-and-scheduling.md) | Back up, restore, and automate | Windows Server Backup, Task Scheduler |
| 3 | 9 | [Automation & troubleshooting](labs/lab09-automation-and-troubleshooting.md) | Write a script, then fix a broken server | PowerShell scripts, the help desk |

Each lab builds on the one before it, so **finish each lab before the next class.**

📄 Keep the **[Windows → Linux Cheat Sheet](handouts/windows-to-linux-cheat-sheet.md)** open during every lab.

## How to start every lab

1. Log in to any **CS Lab** computer and open a terminal (**Ctrl + Alt + T**).
2. Connect to your server (use **your** server's address from Lab 1):
   ```bash
   ssh student@172.27.60.123
   ```
3. Paste commands into the terminal with **Ctrl + Shift + V**.

Your server runs on the department's **Proxmox** system, so it stays on even when you log out. To see its screen, start it, or take a snapshot, go to **https://proxmox.cs.wallawalla.edu:8006** and log in with your CS Lab account (realm **CS-LDAP**).

## Checking your work

In Lab 1 you'll install a small tool called `lab`. After each lab, run:

```bash
lab check 3
```

(Use the lab's number.) It prints ✔ PASS or ✘ FAIL for each part of the lab, and every FAIL comes with a **hint** telling you what to fix. When everything passes, take a screenshot for your submission.

## Getting help

- Every lab ends with a **🛠️ Troubleshooting** table of common problems and fixes. Check it first.
- Stuck for more than 5 minutes? Ask a classmate or your instructor.
- Broke something badly? You can always roll your VM back to a **snapshot** in Proxmox.
