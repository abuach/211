# Lab 8: Backups, Disaster Recovery, and Scheduled Tasks

**Week 3 · Day 8 · 50-minute class (about 40 minutes of lab work)**

> **The big idea:** Every sysadmin eventually gets the call: *"I deleted the important file. Can you get it back?"* If you have a backup, you're a hero. If you don't, you're in trouble. In Windows you used **Windows Server Backup** and **Task Scheduler**. In Linux you'll use **`tar`** to make backups, a **script** to automate them, and **`cron`** to run that script every night.

### What you'll do today
1. Back up Riverbend's files with `tar`
2. Survive a "disaster" by restoring a deleted file
3. Write your first real **script** to automate backups
4. Schedule the script to run automatically with `cron`

### Windows ↔ Linux

| Windows | Linux |
|---|---|
| Windows Server Backup / File History | `tar` (makes one compressed archive file) and `rsync` (copies/mirrors folders) |
| A `.zip` file | A `.tar.gz` file ("tarball") |
| Restore from backup | `tar -x` (e**x**tract) |
| **Task Scheduler** | **`cron`** |
| A scheduled task's *Trigger* | The 5 time fields of a cron line |
| A PowerShell script (`.ps1`) | A bash script (`.sh`) |
| VM checkpoint / System Restore point | VM snapshot (you've been doing this!) |

### The 3-2-1 backup rule
Professionals follow this rule:
- **3** copies of your data
- on **2** different kinds of storage
- with **1** copy **off-site** (another building, or the cloud)

A backup stored on the same server it protects is a good start, but if the server's disk dies, the backup dies with it. Keep this in mind for the questions at the end.

### Before you start
Start your VM and connect with SSH. You need the files from Labs 5 and 6.

---

## Part A: Make a backup by hand (≈8 min)

1. Create a folder to hold backups:
   ```bash
   sudo mkdir -p /backups
   ```

2. Back up **Riverbend's shared files** and **Samba's configuration** into one compressed file:
   ```bash
   sudo tar -czvf /backups/company-$(date +%F).tar.gz /srv/company /etc/samba
   ```
   Let's break that down:

   | Part | Meaning |
   |---|---|
   | `tar` | **t**ape **ar**chive (from the days when backups went to tape!) |
   | `-c` | **c**reate a new archive |
   | `-z` | compress it with g**z**ip (like a zip file) |
   | `-v` | **v**erbose: list each file as it's added |
   | `-f /backups/company-....tar.gz` | the **f**ile to create |
   | `$(date +%F)` | replaced by today's date, e.g. `2026-10-23` |
   | `/srv/company /etc/samba` | what to back up |

   > 💡 You'll see *"Removing leading '/' from member names."* That's normal. tar stores the paths without the starting `/` so you can choose where to restore them later.

3. See your backup and its size:
   ```bash
   ls -lh /backups
   ```

4. **List what's inside** without extracting it (**t** = lis**t**):
   ```bash
   tar -tzvf /backups/company-*.tar.gz
   ```
   Notice that the paths look like `srv/company/sales/q3-report.txt`, with no leading `/`.

> 💡 **Why back up `/etc/samba`?** If the server died, you'd need not only the files but also the **settings** that shared them. Config files in `/etc` are small and valuable. Always back them up.

---

## Part B: 🔥 Disaster! (≈5 min)

It's Monday morning. Alice calls: *"The Q3 sales report is gone! Bob says he didn't touch it."*

5. Let's "accidentally" delete it:
   ```bash
   sudo rm /srv/company/sales/q3-report.txt
   ls -l /srv/company/sales
   ```
   It's gone, and there's no Recycle Bin.

6. **Restore just that one file** from the backup. `-x` = e**x**tract, and `-C /` means "put it back starting at `/`." The last part is the path **as it's stored inside the archive** (no leading `/`):
   ```bash
   sudo tar -xzvf /backups/company-*.tar.gz -C / srv/company/sales/q3-report.txt
   ```

7. Check that it's back **with the correct owner and group**:
   ```bash
   ls -l /srv/company/sales
   cat /srv/company/sales/q3-report.txt
   ```
   Because you ran `tar` with `sudo`, it restored the original owner (`alice`) and group (`sales`) too. 🦸

> 💡 **Restore to a safe place first.** In real life you'd often restore to a temporary folder (`-C /tmp/restore`) and copy the file back *after* checking it. That way, you never overwrite something newer by mistake.

---

## Part C: Write a backup script (≈12 min)

Nobody will remember to type that `tar` command every night. Let's write a **script**: a text file containing the commands, which you can run as one program. It's like a PowerShell `.ps1` file.

8. Create the script. We'll put it in `/usr/local/sbin`, the standard place for admin scripts you write yourself:
   ```bash
   sudo nano /usr/local/sbin/backup-company.sh
   ```
   **Paste** this (copy it from this page), then change `YOUR NAME`:
   ```bash
   #!/bin/bash
   # backup-company.sh - nightly backup of Riverbend's files and settings
   # Written by: YOUR NAME

   # Where backups go, and a date-and-time stamp for the file name
   DEST=/backups
   STAMP=$(date +%F_%H-%M)

   # Make sure the backup folder exists
   mkdir -p "$DEST"

   # Create the backup
   tar -czf "$DEST/company-$STAMP.tar.gz" /srv/company /etc/samba 2>/dev/null

   # Delete backups older than 7 days so the disk doesn't fill up
   find "$DEST" -name "company-*.tar.gz" -mtime +7 -delete

   # Write a line to our log file
   echo "$(date): backup finished: company-$STAMP.tar.gz" >> /var/log/backup-company.log
   ```
   Save and exit.

   What's new here:

   | Line | Meaning |
   |---|---|
   | `#!/bin/bash` | "Run this with bash" (you saw this in Lab 5) |
   | `# ...` | A **comment** for humans. Bash ignores it. |
   | `DEST=/backups` | Creates a **variable** named `DEST`. ⚠️ **No spaces** around the `=`! |
   | `"$DEST"` | Uses the variable's value. Like `$dest` in PowerShell. |
   | `2>/dev/null` | Hides the "Removing leading '/'" notice so the log stays clean |
   | `find ... -mtime +7 -delete` | Finds backups **m**odified more than 7 days ago and deletes them |

9. Make it executable and **run it by hand** to test it:
   ```bash
   sudo chmod +x /usr/local/sbin/backup-company.sh
   sudo /usr/local/sbin/backup-company.sh
   ```
   No output is good! Check that it worked:
   ```bash
   ls -lh /backups
   cat /var/log/backup-company.log
   ```
   You should see a new backup with the time in its name, plus a line in the log.

> ✅ **Checkpoint:** Always **test a script by hand** before you schedule it. If it fails when you run it, it will also fail at 2:00 AM, and nobody will be watching.

---

## Part D: Schedule it with cron (≈12 min)

**cron** is Linux's Task Scheduler. Each scheduled job is one line with **5 time fields** and then the command:

```
 ┌───────────── minute        (0-59)
 │ ┌─────────── hour          (0-23)
 │ │ ┌───────── day of month  (1-31)
 │ │ │ ┌─────── month         (1-12)
 │ │ │ │ ┌───── day of week   (0-6, Sunday = 0)
 │ │ │ │ │
 * * * * *   command to run
```
A `*` means "every." Some examples:

| Cron line | Means |
|---|---|
| `0 2 * * *` | At 2:00 AM, every day |
| `30 17 * * 5` | At 5:30 PM, every Friday |
| `0 0 1 * *` | At midnight on the 1st of every month |
| `*/2 * * * *` | Every 2 minutes |

> 💡 Bookmark **https://crontab.guru**. Type a cron line and it explains it in plain English.

10. Open **root's** schedule (called a **crontab**). We use root's because the backup needs admin rights:
    ```bash
    sudo crontab -e
    ```
    The first time, it asks which editor to use. Type **`1`** for **nano** and press Enter.

11. Go to the **bottom** of the file (all the lines there start with `#`, so they're just comments). Add this line to run the backup **every 2 minutes**, so we can test it quickly:
    ```
    */2 * * * * /usr/local/sbin/backup-company.sh
    ```
    Save (**Ctrl + O**, **Enter**) and exit (**Ctrl + X**). You'll see `crontab: installing new crontab`.

12. Check the schedule:
    ```bash
    sudo crontab -l
    ```

13. **Wait 2-4 minutes.** ☕ While you wait, work on **question 1** below using https://crontab.guru. Then check:
    ```bash
    ls -lh /backups
    cat /var/log/backup-company.log
    ```
    New backups should be appearing **on their own**! You can also see cron's own record of running the job:
    ```bash
    grep CRON /var/log/syslog | tail
    ```

14. A backup every 2 minutes would fill the disk. Change it to **2:00 AM every night**:
    ```bash
    sudo crontab -e
    ```
    Change the line to:
    ```
    0 2 * * * /usr/local/sbin/backup-company.sh
    ```
    Save, exit, and confirm with `sudo crontab -l`.

---

## Part E: Snapshot before Lab 9 (≈2 min)

15. Next class you'll **intentionally break** your server. Take a snapshot now so you can always come back:
    In Proxmox: your VM → **Snapshots** → **Take Snapshot** → name it **`lab8-before-troubleshooting`**.

> 🤔 **Is a VM snapshot a backup?** Not really. It lives on the same disk as the VM, and if that disk fails, both are gone. It's great for "undo," but it doesn't follow the 3-2-1 rule.

---

## ✅ Check your work

```bash
lab check 8
```
(This check runs your backup script once to make sure it works, so you'll get one extra backup file. That's fine.)

---

## ✅ What to submit

1. A **screenshot** of `lab check 8` with everything passing
2. A **screenshot** of `sudo crontab -l` and `cat /var/log/backup-company.log`
3. Answers to these questions:
   1. Write the cron line for: *"every Sunday at 11:30 PM."* (Check it with crontab.guru!)
   2. Why did you test the script by hand before scheduling it?
   3. Right now, Riverbend's backups are stored on the same server as the data. Explain the 3-2-1 rule and describe how Riverbend could meet it.
   4. Why does the script delete backups older than 7 days? What could go wrong if it didn't?
   5. Compare cron to Windows Task Scheduler. Which do you find easier? Why?

## ⭐ Challenge (optional, or at home)
- **Mirror with rsync.** `tar` makes one archive file. `rsync` **copies** folders, and on later runs copies **only what changed**: run `sudo rsync -av /srv/company/ /backups/mirror/` twice and compare the output. To copy to *another* server you'd use `rsync -av /srv/company/ user@backupserver:/backups/`, which is how you'd keep the "1 copy off-site" of the 3-2-1 rule.
- Add `/home` to the backup script so everyone's personal files are backed up too. Run it by hand and confirm with `tar -tzf`.
- Test a **full restore** to a safe place: `sudo mkdir /tmp/restore`, then `sudo tar -xzf <newest backup> -C /tmp/restore`, then `ls -R /tmp/restore`.
- What does `@reboot` do in a crontab? (Look it up.)

---

## 🛠️ Troubleshooting

| Problem | Fix |
|---|---|
| `tar: Cannot open: No such file or directory` | Does `/backups` exist? Is the path typed correctly? |
| `tar: You must specify one of the ...` or `Cannot open` when you use `company-*.tar.gz` | You have more than one backup, so the `*` matched several files. Type the full file name instead (press **Tab** to fill it in). |
| Restoring says `Not found in archive` | Use the path **without** the leading `/`: `srv/company/...`. Check the exact name with `tar -tzf`. |
| `sudo: /usr/local/sbin/backup-company.sh: command not found` | Forgot `chmod +x`, or there's a typo in the path. Check with `ls -l /usr/local/sbin`. |
| Script error: `DEST: command not found` | You put spaces around `=`. It must be `DEST=/backups`. |
| Cron isn't creating backups | Test the script by hand first. Check `sudo crontab -l` (is the line there, and is it **not** commented out with `#`?). Check `grep CRON /var/log/syslog`. |
| I edited my own crontab instead of root's | You ran `crontab -e` without `sudo`. Open `crontab -e`, delete the line, then add it with `sudo crontab -e`. |
