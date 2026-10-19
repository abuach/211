# Lab 4: Users and Groups

**Week 2 · Day 4 · 50-minute class (about 40 minutes of lab work)**

> **The big idea:** Linux users and groups work just like Windows local users and groups. You create accounts, put them in groups, and give permissions to *groups* instead of individual people. The tools are commands instead of the **Local Users and Groups** window (or **Active Directory Users and Computers**).

### The scenario
Riverbend Outfitters has hired you to set up accounts for their staff:

| Employee | Username | Department | Notes |
|---|---|---|---|
| Alice Adams | `alice` | Sales | |
| Bob Baker | `bob` | Sales | |
| Carol Chen | `carol` | HR | |
| Dave Diaz | `dave` | IT | Needs **admin** rights |
| Erin Evans | `erin` | HR | On leave. Account should be **locked** |
| Frank Fox | `frank` | Sales | Contractor. Account must **expire** at year end |
| (temp) | `intern` | | Summer intern who **left**. Delete the account. |

### Windows ↔ Linux

| Windows | Linux |
|---|---|
| Local Users and Groups / ADUC | Commands: `adduser`, `usermod`, `deluser` |
| `New-LocalUser` | `sudo adduser <name>` |
| `New-LocalGroup` | `sudo addgroup <name>` |
| `Add-LocalGroupMember` | `sudo usermod -aG <group> <user>` |
| **Administrators** group | **sudo** group |
| *Account is disabled* checkbox | `sudo passwd -l <user>` (lock) |
| *Account expires* (AD) | `sudo chage -E <date> <user>` |
| `Remove-LocalUser` | `sudo deluser --remove-home <user>` |
| SID (`S-1-5-21-...`) | UID (a number like `1001`) |
| `whoami /groups` | `id` or `groups` |
| User accounts are stored in the SAM / AD database | User accounts are stored in **text files**: `/etc/passwd`, `/etc/group`, `/etc/shadow` |

### Before you start
Start your VM and connect with SSH.

> 🔑 **Pick ONE password for all of the pretend employees** and write it down, for example `Riverbend2Go!`. (In real life every person gets their own password, of course!)

---

## Part A: Look at the user database (≈5 min)

In Windows, user accounts live in a hidden database. In Linux they live in plain text files you can read.

1. See who you are:
   ```bash
   id
   ```
   ```
   uid=1000(student) gid=1000(student) groups=1000(student),4(adm),24(cdrom),27(sudo),...
   ```
   - **uid** = your **U**ser **ID** number (like a Windows SID)
   - **gid** = your main group. Linux gives every user their own private group with the same name.
   - **groups** = every group you're in. See `sudo`? That's what makes you an admin.

2. Look at the list of all accounts:
   ```bash
   cat /etc/passwd
   ```
   Each line is one account. Fields are separated by colons `:`. Look at the last line, which is you:
   ```
   student:x:1000:1000:Maria Garcia:/home/student:/bin/bash
   ```
   | Field | Meaning |
   |---|---|
   | `student` | username |
   | `x` | password is stored elsewhere (in `/etc/shadow`) |
   | `1000` | user ID |
   | `1000` | main group ID |
   | `Maria Garcia` | full name |
   | `/home/student` | home folder |
   | `/bin/bash` | the shell (command line program) they get when they log in |

   > 💡 Most of the accounts above yours (`daemon`, `www-data`, `sshd`, ...) aren't people. They're **service accounts** that programs run as, like Windows' *NETWORK SERVICE* or *LOCAL SERVICE*. Real people usually start at UID 1000.

---

## Part B: Create the department groups (≈2 min)

3. Create one group per department:
   ```bash
   sudo addgroup sales
   sudo addgroup hr
   sudo addgroup it
   ```
4. Check that they exist:
   ```bash
   tail -5 /etc/group
   ```

---

## Part C: Create the user accounts (≈12 min)

5. Create **alice**:
   ```bash
   sudo adduser alice
   ```
   It asks a few questions:
   - **New password:** type the employee password (invisible), press Enter, and type it again
   - **Full Name:** `Alice Adams`
   - **Room Number, Work Phone, Home Phone, Other:** just press **Enter** to skip each one
   - **Is the information correct? [Y/n]** press **Enter**

   `adduser` also created `/home/alice` and copied in default settings files.

6. Repeat for the others. Use the scenario table above for full names:
   ```bash
   sudo adduser bob
   sudo adduser carol
   sudo adduser dave
   sudo adduser erin
   sudo adduser frank
   sudo adduser intern
   ```
   > 😩 **Getting tired of answering the same questions over and over?** Good, remember that feeling. On Day 9 you'll write a script that creates a whole list of users automatically.

7. Check the home folders:
   ```bash
   ls /home
   ```

---

## Part D: Put users in groups (≈10 min)

8. Add each person to their department:
   ```bash
   sudo usermod -aG sales alice
   sudo usermod -aG sales bob
   sudo usermod -aG sales frank
   sudo usermod -aG hr carol
   sudo usermod -aG hr erin
   sudo usermod -aG it dave
   ```

   > ⚠️ **Never forget the `a`!** `-aG` means **a**ppend to these **G**roups. If you type only `-G`, Linux **removes the user from every other group** and leaves just the one you listed. This is one of the most common sysadmin mistakes.

9. Make **dave** an administrator by adding him to the `sudo` group. This is like adding someone to the Windows **Administrators** group:
    ```bash
    sudo usermod -aG sudo dave
    ```

10. Check everyone's groups:
    ```bash
    groups alice bob carol dave erin frank
    ```
    Or see the members of one group:
    ```bash
    getent group sales
    ```

11. **Test dave's admin rights.** `su` (**s**witch **u**ser) lets you become another user:
    ```bash
    su - dave
    ```
    Type **dave's** password. Your prompt changes to `dave@...`. Now:
    ```bash
    whoami
    sudo whoami
    ```
    It should say `dave` and then `root`. Dave is an admin! Type **`exit`** to go back to being `student`.

12. Try the same as **alice**:
    ```bash
    su - alice
    sudo whoami
    ```
    You get **"sudo: I'm sorry alice. I'm afraid I can't do that"**. Good! That's correct, because Alice isn't an admin. Type `exit`.

> ✅ **Checkpoint:** Run `whoami`. It should say `student`. If it says another name, type `exit` until you're back.

---

## Part E: Lock, expire, and delete accounts (≈8 min)

These are everyday jobs for a sysadmin.

13. **Lock** erin's account while she's on leave (like checking *Account is disabled* in Windows):
    ```bash
    sudo passwd -l erin
    sudo passwd -S erin
    ```
    `passwd -S` shows the account **S**tatus. The second word is **`L`** for **Locked** (or **`P`** for a usable **P**assword).

    Test it. Try to become erin. Her password won't work anymore:
    ```bash
    su - erin
    ```
    You'll see *"Authentication failure."* When she comes back, you'd unlock her with `sudo passwd -u erin` (**u** = unlock). **Leave her locked for now.**

14. **Set an expiration date** for frank, the contractor, so his account stops working at the end of this year:
    ```bash
    sudo chage -E $(date +%Y)-12-31 frank
    sudo chage -l frank
    ```
    - `chage` = **ch**ange **age** (password and account aging settings)
    - `$(date +%Y)` is replaced by the current year, so this becomes something like `2026-12-31`
    - The `Account expires` line should now show December 31.

15. **Delete** the intern's account and home folder:
    ```bash
    sudo deluser --remove-home intern
    ls /home
    ```
    > 💡 In real companies, sysadmins often **lock** a departed employee's account first and delete it weeks later. That way, files can be recovered if a manager needs them.

---

## ✅ Check your work

```bash
lab check 4
```

---

## ✅ What to submit

1. A **screenshot** of `lab check 4` with everything passing
2. A **screenshot** of the output of: `groups alice bob carol dave erin frank`
3. Answers to these questions:
   1. What happens if you run `sudo usermod -G sales bob` (without the `a`)? Why is that dangerous?
   2. What is the Linux equivalent of the Windows *Administrators* group? How did you make dave an admin?
   3. Why is it better to give permissions to **groups** instead of to individual users? (You learned this in the Windows part of the course, too!)
   4. Why might a company *lock* an account instead of deleting it right away?
   5. Look at `/etc/passwd`. Name one service account you see and guess what program uses it.

## ⭐ Challenge (optional, or at home)
- **Reset a password.** Bob forgot his. As admin, run `sudo passwd bob` to set a new one without knowing the old one. (Use the same employee password so you don't forget it.)
- What's the difference between `adduser` and `useradd`? (Try `man useradd`.) Which one is friendlier for a human? Which do you think scripts use?
- Make the employee passwords **expire every 90 days**: `sudo chage -M 90 alice`, then check with `sudo chage -l alice`. Where would you set this in Windows?
- Use `sudo lastlog` to see when each user last logged in.

---

## 🛠️ Troubleshooting

| Problem | Fix |
|---|---|
| `adduser: The user 'alice' already exists` | You already made her. Move on! |
| `adduser: Please enter a username matching the regular expression...` | Usernames must be **lowercase**, with no spaces. |
| `deluser` says *"you need to install the 'perl' package"* | Run `sudo apt install -y perl`, then try again. |
| I typed the full name wrong | `sudo chfn -f "Alice Adams" alice` |
| `groups` doesn't show the new group for **you** (`student`) | Group changes take effect at your *next* login. Type `exit` and SSH in again. |
| I forgot the `a` and ran `usermod -G` on myself (`student`), and now `sudo` doesn't work! | If dave is already an admin, he can fix it: `su - dave`, then `sudo usermod -aG sudo,adm student`, then `exit` twice and SSH in again. Otherwise ask your instructor. |
| I'm "stuck" as another user | Type `exit` |
