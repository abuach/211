# Lab 7: Monitoring, Logs, and the Firewall

**Week 3 · Day 7 · 50-minute class (about 40 minutes of lab work)**

> **The big idea:** A sysadmin's job isn't only building things. It's also **watching** them. In Windows you used **Task Manager** and **Event Viewer** to see what's happening, and **Windows Defender Firewall** to block traffic. Linux has command-line tools for every one of these jobs. Today you'll check the server's health, stop a runaway program, **investigate a break-in attempt**, and turn on the firewall.

### Windows ↔ Linux

| Windows | Linux |
|---|---|
| Task Manager → Performance | `uptime`, `free -h`, `htop` |
| Task Manager → Processes / Details | `htop`, `ps aux`, `pgrep` |
| Task Manager → **End task** | `kill <PID>` |
| This PC → drive free space | `df -h` |
| **Event Viewer** | `journalctl` and the files in `/var/log` |
| Event Viewer → **Security** log | `/var/log/auth.log` |
| Event ID **4625** (failed logon) | `Failed password` lines in `auth.log` |
| Event ID 4624 (successful logon) | `Accepted password` lines / the `last` command |
| Windows Defender Firewall | `ufw` (**U**ncomplicated **F**ire**w**all) |

### Before you start
Start your VM and connect with SSH. Then:
```bash
mkdir ~/lab7
```

---

## Part A: Is the server healthy? (≈5 min)

1. Run these three health checks:
   ```bash
   uptime
   free -h
   df -h
   ```
   | Command | What to look at |
   |---|---|
   | `uptime` | **load average**: how busy the CPU has been over the last 1, 5, and 15 minutes. Below **2** (your number of CPUs) is fine. |
   | `free -h` | the **available** column: how much memory programs can still use. (`-h` = **h**uman-readable, like `G` and `M`.) |
   | `df -h` | the line **Mounted on `/`** (your main disk, like `C:`), and its **Use%**. A full disk is the #1 cause of surprise outages! |

2. **Save a health report** to a file. Remember: `>` creates (or replaces) a file, and `>>` **adds** to the end:
   ```bash
   date > ~/lab7/health.txt
   df -h >> ~/lab7/health.txt
   free -h >> ~/lab7/health.txt
   cat ~/lab7/health.txt
   ```

---

## Part B: Find and stop a runaway program (≈8 min)

3. **Create a problem on purpose.** The `yes` command prints "y" forever, as fast as it can. The `&` at the end means "run it in the background and give me my prompt back." (`/dev/null` is a "black hole": anything sent there disappears.)
   ```bash
   yes > /dev/null &
   ```

4. **Open htop**, Linux's Task Manager:
   ```bash
   htop
   ```
   One CPU bar is now **full**, and `yes` is at the top of the list using about 100% CPU. This is what a stuck or runaway program looks like. Each row is a **process**, and **PID** is its ID number. Write down the PID of `yes`, then press **q**.

5. You can also find a process by name with `pgrep`:
   ```bash
   pgrep -a yes
   ```

6. **Stop it** with `kill`, using **your** PID number, then check that it's gone (no output = gone ✅):
   ```bash
   kill 1234
   pgrep -a yes
   ```

> 💡 `kill` politely asks a program to stop. If a program ignores that, `kill -9 <PID>` forces it, like **End task** on a Windows program that's "Not Responding." You can also stop processes **by name** with `pkill yes`.

---

## Part C: Investigate a break-in attempt (≈15 min)

Someone is trying to guess Bob's password! You'll play **both** roles: first the attacker, then the investigator.

### 🦹 Be the attacker

7. **Open a second terminal tab** on the lab computer (**Ctrl + Shift + T**). Pretend to be an attacker guessing Bob's password. Type a **wrong** password **3 times**:
   ```bash
   ssh bob@172.27.60.123
   ```
8. Then try a username that doesn't exist (attackers try names like `admin` and `root`). Type anything as the password, 3 times:
   ```bash
   ssh admin@172.27.60.123
   ```
   Close this second tab when you're done, and go back to your `student` tab.

### 🕵️ Be the investigator

9. Find all the failed password attempts. This is the Linux version of filtering the Windows Security log for **Event ID 4625**:
   ```bash
   sudo grep "Failed password" /var/log/auth.log
   ```
   `grep` shows only the lines containing the words in quotes. A line looks like this:
   ```
   2026-10-22T10:51:07.348211-07:00 maria-linux sshd-session[2214]: Failed password for bob from 172.27.10.53 port 50122 ssh2
   ```
   It tells you **when**, **which account**, and **which IP address** the attempt came from. (Here, the "attacker" is the lab computer you're sitting at.)

10. **Count** them by piping into `wc -l` (**w**ord **c**ount, **l**ines):
    ```bash
    sudo grep "Failed password" /var/log/auth.log | wc -l
    ```

11. Find attempts on usernames that **don't exist**, and see who logged in **successfully** (like Event ID 4624):
    ```bash
    sudo grep "Invalid user" /var/log/auth.log
    sudo grep "Accepted password" /var/log/auth.log
    ```

12. **Save your evidence** for the report:
    ```bash
    sudo grep "Failed password" /var/log/auth.log > ~/lab7/failed-logins.txt
    cat ~/lab7/failed-logins.txt
    ```

> 🔐 **In the real world,** a server on the internet gets **thousands** of these attempts every day from automated bots. Defenses include strong passwords, SSH keys instead of passwords, and tools like **fail2ban** that automatically block an IP after too many failures (like Windows' *Account lockout policy*).

---

## Part D: Turn on the firewall (≈10 min)

Right now, your server accepts connections on **any** port. A firewall lets you allow only what's needed: SSH (port 22), web (port 80), and Samba (port 445).

13. Check the firewall status:
    ```bash
    sudo ufw status
    ```
    It says **`Status: inactive`**. The firewall is off!

> ⚠️ **STOP and read this.** You're connected through **SSH**. If you turn the firewall on **before** allowing SSH, it will **cut off your own connection**, and you'll have to fix it from the Proxmox console. Real sysadmins have locked themselves out of servers hundreds of miles away this way! **Always allow SSH first.**

14. Allow the three services Riverbend needs:
    ```bash
    sudo ufw allow OpenSSH
    sudo ufw allow "Nginx HTTP"
    sudo ufw allow Samba
    ```

15. **Now** turn it on. It warns that this *"may disrupt existing ssh connections."* Since you allowed SSH, type **`y`** and press Enter:
    ```bash
    sudo ufw enable
    sudo ufw status verbose
    ```
    You should see `Default: deny (incoming)` plus your three **ALLOW** rules. **Everything else coming in is blocked.**

16. **Prove that the firewall works.** Remove the web rule, then refresh your Riverbend web page in your browser:
    ```bash
    sudo ufw delete allow "Nginx HTTP"
    ```
    The page won't load, even though nginx is still running! The firewall is blocking it. Put the rule back and refresh again:
    ```bash
    sudo ufw allow "Nginx HTTP"
    ```

---

## ✅ Check your work

```bash
lab check 7
```

---

## ✅ What to submit

1. A **screenshot** of `lab check 7` with everything passing
2. A short **incident report** (one paragraph) about the attack in Part C, written like you're telling your boss:
   - **When** did the failed logins happen? (first and last time)
   - **How many** failed attempts were there?
   - **Which usernames** were targeted? Did any of them exist?
   - **Which IP address** did they come from?
   - **Was the attacker successful?** How do you know?
   - **What would you recommend** to prevent this in the future?
3. Answers to these questions:
   1. What is the Linux equivalent of Event Viewer? Of Task Manager?
   2. Why is running out of disk space so dangerous for a server? Which command checks it?
   3. Why must you allow SSH *before* enabling ufw?
   4. In step 16, nginx was running but the page still didn't load. Explain why.

## ⭐ Challenge (optional, or at home)
- **Watch the security log live.** In one window run `sudo tail -f /var/log/auth.log`. In another, try a wrong SSH password. The failed attempt appears **instantly**. Press **Ctrl + C** to stop.
- **The system journal** (like Event Viewer): try `journalctl -u nginx` (one service's messages) and `journalctl -p err -b` (only errors since boot). Press **q** to quit.
- **Web visitor log:** `sudo tail /var/log/nginx/access.log` shows every visit to your website. Can you find your own browser?
- Read about **fail2ban**. How would it have helped in Part C? (Don't install it on your VM. It could block *you*!)

---

## 🛠️ Troubleshooting

| Problem | Fix |
|---|---|
| **I enabled the firewall and my SSH connection froze!** | Open your VM's **Console** in Proxmox, log in there as `student`, and run `sudo ufw allow OpenSSH`. Then SSH in again. |
| `/var/log/auth.log: No such file or directory` | Use the journal instead: `sudo journalctl -u ssh \| grep "Failed password"` |
| No "Failed password for bob" lines | Make sure you typed the wrong password for **bob** (not student) and that you connected to the right address. |
| The `ssh bob@...` command connected without asking for a password | You typed the right password! Type `exit` and try again with a wrong one. |
| `kill: (1234) - No such process` | Use **your** PID number from `pgrep -a yes`, not the one in the example. |
| `ERROR: Could not find a profile matching 'Nginx HTTP'` | Check the exact name with `sudo ufw app list`. The quotes are needed because of the space. |
