# Lab 9: Automation and the Troubleshooting Challenge

**Week 3 · Day 9 · 50-minute class (about 40 minutes of lab work)**

> ⏱️ **Plan your time:** about **15 minutes** for Part A and **25 minutes** for Part B. Write the ticket reports **after class**.

> **The big idea:** Today brings everything together. First, you'll **automate** a boring, repetitive job: creating accounts for new employees, the way you probably did with PowerShell and a CSV file in Windows. Then your server will **break in six different ways**, and you'll fix it using everything you've learned, just like a real day on the help desk.

### Windows ↔ Linux

| Windows (PowerShell) | Linux (bash) |
|---|---|
| `Import-Csv newhires.csv` | `while IFS=, read -r ...` |
| `ForEach-Object { ... }` | `while ... do ... done` |
| `New-LocalUser` / `New-ADUser` | `useradd` |
| `-ChangePasswordAtLogon $true` | `chage -d 0 <user>` |
| `if (...) { ... }` | `if [ ... ]; then ... fi` |
| `$args[0]` | `$1` |

### Before you start
- Start your VM and connect with SSH.
- Make sure you have the **`lab8-before-troubleshooting`** snapshot in Proxmox (your VM → **Snapshots**). If you don't, **take one now.**

---

## Part A: Automate new-hire accounts (≈15 min)

Riverbend just hired four people. HR sent you a spreadsheet. In Lab 4 you created users one at a time and answered the same questions again and again. Now imagine HR sends 40 names. Time to automate!

### The data file

1. Make a folder and create the CSV file (Comma-Separated Values, the same kind of file Excel can save):
   ```bash
   mkdir ~/lab9
   cd ~/lab9
   nano newhires.csv
   ```
   Type exactly this. The first line is the **header**:
   ```
   username,fullname,department
   gina,Gina Lopez,sales
   hank,Hank Brown,it
   iris,Iris Chen,hr
   jack,Jack Wilson,sales
   ```
   Save and exit.

### The script

2. Create the script:
   ```bash
   nano onboard.sh
   ```
   **Paste** this (copy it from this page), then change `YOUR NAME`:
   ```bash
   #!/bin/bash
   # onboard.sh - create accounts for new employees from a CSV file
   # Usage:  sudo ./onboard.sh newhires.csv
   # Written by: YOUR NAME

   CSV_FILE="$1"
   TEMP_PASSWORD="Welcome2Riverbend!"

   # This script must be run as root (with sudo)
   if [ "$(id -u)" -ne 0 ]; then
       echo "Please run with sudo:  sudo ./onboard.sh $CSV_FILE"
       exit 1
   fi

   # Make sure the CSV file exists
   if [ ! -f "$CSV_FILE" ]; then
       echo "Error: can't find the file '$CSV_FILE'"
       echo "Usage:  sudo ./onboard.sh newhires.csv"
       exit 1
   fi

   # Read the file one line at a time, skipping the header (line 1)
   tail -n +2 "$CSV_FILE" | while IFS=, read -r username fullname department; do

       # Skip blank lines
       if [ -z "$username" ]; then
           continue
       fi

       # Don't create someone who already exists
       if id "$username" &>/dev/null; then
           echo "SKIPPED: $username already exists"
           continue
       fi

       # Create the account, with a home folder, a bash shell, the full name, and the department group
       useradd -m -s /bin/bash -c "$fullname" -G "$department" "$username"

       # Set a temporary password and force them to change it at first login
       echo "$username:$TEMP_PASSWORD" | chpasswd
       chage -d 0 "$username"

       echo "CREATED: $username ($fullname) in group $department"
   done
   ```
   Save and exit.

3. **Skim the script before you run it.** That's a professional habit, especially for scripts you didn't write yourself! Here's what the new parts do (read this table more carefully after class):

   | Code | What it does |
   |---|---|
   | `CSV_FILE="$1"` | `$1` is the **first thing you type after the script name**. So in `./onboard.sh newhires.csv`, `$1` is `newhires.csv`. |
   | `if [ ... ]; then ... fi` | An **if** statement. (`fi` is just `if` spelled backwards!) |
   | `[ "$(id -u)" -ne 0 ]` | "Is my user ID **n**ot **e**qual to 0?" Root's ID is always 0. |
   | `[ ! -f "$CSV_FILE" ]` | "Is this **not** (`!`) a **f**ile that exists?" |
   | `tail -n +2` | Print the file starting at line 2 (skips the header) |
   | `while IFS=, read -r a b c; do ... done` | For each line: split it at the commas (`IFS=,`) into three variables, then run the commands between `do` and `done` |
   | `continue` | Skip to the next line of the file |
   | `useradd -m -s /bin/bash -c ... -G ...` | The no-questions-asked version of `adduser`. Made for scripts. |
   | `chpasswd` | Sets a password without asking questions |
   | `chage -d 0` | Expires the password now, so they must choose a new one at first login |

   Compare it with the PowerShell version you might have written earlier in the course:
   ```powershell
   Import-Csv newhires.csv | ForEach-Object {
       New-LocalUser -Name $_.username -FullName $_.fullname -Password $pw
       Add-LocalGroupMember -Group $_.department -Member $_.username
   }
   ```
   Same idea, different words!

4. Make the script executable and **test the error checking** first. Running it with a wrong file name should print an error instead of doing anything:
   ```bash
   chmod +x onboard.sh
   sudo ./onboard.sh wrongname.csv
   ```

5. **Run it for real:**
   ```bash
   sudo ./onboard.sh newhires.csv
   ```
   ```
   CREATED: gina (Gina Lopez) in group sales
   CREATED: hank (Hank Brown) in group it
   CREATED: iris (Iris Chen) in group hr
   CREATED: jack (Jack Wilson) in group sales
   ```

6. **Run it again.** A good script is safe to run twice:
   ```bash
   sudo ./onboard.sh newhires.csv
   ```
   Every line should say **SKIPPED**.

7. **Verify:**
   ```bash
   groups gina hank iris jack
   sudo chage -l gina
   ```
   `chage` should say **`Last password change : password must be changed`**.

> 🎉 **You just automated a real sysadmin task.** With 4 users it saved a few minutes. With 400 users it would save a whole day, and there would be no typos.

---

## Part B: The troubleshooting challenge (≈25 min)

### ⚠️ First: snapshot!
Make sure you have your **`lab8-before-troubleshooting`** snapshot (or take one called **`lab9-before-break`** now). If anything goes badly wrong, you can restore it: Proxmox → your VM → **Snapshots** → select it → **Rollback**.

### Break the server

8. Run:
   ```bash
   sudo lab break
   ```
   Six things on your server are now broken. **Don't restore your snapshot to fix them.** That would be cheating! Fix them like a sysadmin would.

### The troubleshooting method

Use these steps for **every** ticket. It's the same method you'd use on Windows.

| Step | Ask yourself | Example tools |
|---|---|---|
| **1. Understand** | What exactly is the user saying? Who is affected, and who isn't? | Re-read the ticket |
| **2. Check** | What's the status? Is it running? Does it exist? | `systemctl status`, `ls -l`, `groups`, `id` |
| **3. Read the logs** | What do the error messages say? | `journalctl -u <service>`, `/var/log/...` |
| **4. Fix** | Change **one thing** at a time | `systemctl`, `chmod`, `chgrp`, `usermod`, `nano` |
| **5. Verify** | Is it really fixed? Test it **the way the user would.** | `curl`, `su - <user>`, your browser |
| **6. Document** | Write down what happened | Your ticket report |

### 🎫 The help desk tickets

> **Ticket #1** from *Front desk*
> "The company website is down! Customers are calling. It was working yesterday."

> **Ticket #2** from *Bob Baker (Sales)*
> "I can't log in to the server. I KNOW my password is right. I've used it for weeks!"

> **Ticket #3** from *Alice Adams (Sales)*
> "I get 'Permission denied' when I open the sales folder. Bob says it works fine for him."

> **Ticket #4** from *Carol Chen (HR)*
> "Nobody in HR can open our HR folder this morning. We have payroll due today!"

> **Ticket #5** from *Your manager*
> "The backup log says nothing ran last night. Please make sure tonight's backup will work."

> **Ticket #6** from *Dave Diaz (IT)*
> "The server has been really slow since this morning. Can you look into it?"

### Tools you'll need

- **Check your progress at any time:**
  ```bash
  lab check 9
  ```
- **Stuck? Get a hint** (try for at least 5 minutes first!):
  ```bash
  lab hint 1
  lab hint 1 more
  ```

### Useful commands from the past 3 weeks

| To check... | Use |
|---|---|
| a service | `systemctl status <name>`, `journalctl -u <name>` |
| nginx's config file | `sudo nginx -t` |
| a user account | `id <user>`, `groups <user>`, `sudo passwd -S <user>` |
| a folder's permissions | `ls -ld <folder>`, `getfacl <folder>` |
| a file's permissions | `ls -l <file>` |
| what's using the CPU | `htop`, `ps aux`, `pgrep -a <name>` |
| what a process belongs to | `systemctl status <PID>` |
| a scheduled job | `sudo crontab -l` |

---

## ✅ Check your work

```bash
lab check 9
```
Keep going until every ticket passes. Then run the **final check** of the whole unit:
```bash
lab check all
```

---

## ✅ What to submit

1. A **screenshot** of `lab check 9` with everything passing
2. A **screenshot** of `lab check all`
3. Your `onboard.sh` script (copy and paste the text)
4. **A ticket report for each of the 6 tickets** (do this after class, while it's fresh). Use this format:

   ```
   Ticket #:
   Symptom:      (what the user saw)
   Cause:        (what was actually wrong)
   How I found it: (the commands I used to find the cause)
   Fix:          (the exact command(s) I used to fix it)
   Verified by:  (how I proved it was fixed)
   ```

5. Answers to these final reflection questions:
   1. In Ticket #6, why didn't `kill` fix the problem permanently? What did you have to do instead?
   2. For Ticket #3, why was it a good clue that **Bob** could still get in?
   3. Which ticket was hardest? What would you do differently next time?
   4. **Looking back over all 10 weeks:** name **three** tasks that are easier in Linux and **three** that are easier in Windows. For each one, explain why.
   5. If you were the sysadmin at a company that uses both Windows and Linux servers, which tasks would you automate first? Why?

## ⭐ Challenge (optional, or at home)
- **Test it like a new employee would.** Run `su - gina` and type the temporary password `Welcome2Riverbend!`. Linux forces her to choose a new password (it asks for the current one again first). Then type `exit`.
- Improve `onboard.sh` so it also gives each new user a **Samba password**. (Hint: `(echo "$TEMP_PASSWORD"; echo "$TEMP_PASSWORD") | smbpasswd -a -s "$username"`)
- Make the script write each `CREATED:` line to a log file, `/var/log/onboard.log`, as well as to the screen. (Hint: `echo ... | tee -a /var/log/onboard.log`)
- Write `offboard.sh`. It takes a username and **locks** the account instead of deleting it. Then it moves the user's home folder to `/backups/departed/`.

---

## 🛠️ Troubleshooting

| Problem | Fix |
|---|---|
| `useradd: group 'sales ' does not exist` (note the space) | There's an extra space in your CSV file. Open it with nano and remove spaces around the commas. |
| `useradd: group 'xyz' does not exist` | The department in the CSV doesn't match a real group. Check with `getent group`. |
| `$'\r': command not found` | You created the file on Windows and copied it over. Recreate it in nano on the server. |
| `lab break` says to finish earlier labs | Do what it says, then run `sudo lab break` again. |
| Everything is a mess and I can't recover | Restore your **Lab 8** snapshot, then run `sudo lab break` again. Ask your instructor if it happens twice. |
