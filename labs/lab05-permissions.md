# Lab 5: File Permissions

**Week 2 · Day 5 · 50-minute class (about 40 minutes of lab work)**

> **The big idea:** In Windows you set NTFS permissions on the **Security** tab: you add users or groups and check boxes like *Read* and *Modify*. Linux starts simpler. Every file has **one owner**, **one group**, and **three sets of permissions**. When you need something more complex, Linux also has **ACLs** that work a lot like the Windows Security tab.

### Windows ↔ Linux

| Windows (NTFS) | Linux |
|---|---|
| Security tab → list of users/groups | **Owner**, **Group**, **Others** (everyone else) |
| *Read* | `r`: read a file / list a folder |
| *Write* | `w`: change a file / create and delete files in a folder |
| *Read & Execute* | `r` + `x`: run a program / **enter** a folder |
| `.exe` extension makes a file a program | The `x` permission makes a file a program |
| Edit permissions / `icacls` | `chmod` |
| Change owner (Advanced → Owner) | `chown`, `chgrp` |
| New files **inherit** the folder's permissions | Not automatic. You use the **setgid** bit and **default ACLs** (Parts C and D) |
| Add another group with its own permissions | ACLs: `setfacl` / `getfacl` |

### Before you start
Start your VM and connect with SSH. You need the users and groups from Lab 4.

---

## Part A: Reading permissions (≈6 min)

1. Make a practice folder and a file:
   ```bash
   mkdir ~/lab5
   cd ~/lab5
   echo "my secret plans" > secret.txt
   ls -l
   ```
   ```
   -rw-rw-r-- 1 student student 16 Oct 20 10:02 secret.txt
   ```

2. Here is what that first part means:
   ```
     -    rw-    rw-    r--     student   student
     │    └┬┘    └┬┘    └┬┘       │         │
     │     │      │      │        │         └── the file's GROUP
     │     │      │      │        └──────────── the file's OWNER
     │     │      │      └── what OTHERS (everyone else) can do
     │     │      └───────── what the GROUP can do
     │     └──────────────── what the OWNER can do
     └────────────────────── type: - = file, d = directory (folder)
   ```
   Each set has three slots, always in the order **r w x**. A `-` means "no." So `rw-rw-r--` means: the owner and the group can read and write, and others can only read.

3. Compare two system files:
   ```bash
   ls -l /etc/passwd /etc/shadow
   ```
   Others can read `/etc/passwd` (`r--` at the end) but not `/etc/shadow` (`---`). That's why you needed `sudo` to read `shadow` in Lab 3.

---

## Part B: Changing permissions with chmod (≈8 min)

`chmod` (**ch**ange **mod**e) changes permissions. Sysadmins usually use **numbers**. Each permission has a value, and you add them up for the owner, the group, and others:

| r | w | x |
|---|---|---|
| **4** | **2** | **1** |

| Number | Letters | Meaning |
|---|---|---|
| **7** | `rwx` | 4+2+1, everything |
| **6** | `rw-` | 4+2, read and write |
| **5** | `r-x` | 4+1, read and run/enter |
| **4** | `r--` | read only |
| **0** | `---` | nothing |

So `chmod 600 file` means owner **6** (rw-), group **0**, and others **0**: only you can use it.

4. Make `secret.txt` private:
   ```bash
   chmod 600 secret.txt
   ls -l secret.txt
   ```
   Now it's `rw-------`.

5. Create a tiny program (a **script**). nano saves with **Ctrl+O, Enter** and exits with **Ctrl+X**:
   ```bash
   nano hello.sh
   ```
   Type:
   ```bash
   #!/bin/bash
   echo "Hello from $(hostname)! Today is $(date +%A)."
   ```
   The first line, `#!/bin/bash`, tells Linux "run this file with the bash program."

6. Try to run it:
   ```bash
   ./hello.sh
   ```
   **Permission denied!** In Windows, a file is a program because its name ends in `.exe`. In Linux, it's a program because it has the **`x`** permission. (`./` means "the file in **this** folder.")

7. You can also use **letters** with chmod: `u`/`g`/`o` (user/owner, group, others), then `+` or `-`, then `r`/`w`/`x`. Give the owner execute permission and run it:
   ```bash
   chmod u+x hello.sh
   ls -l hello.sh
   ./hello.sh
   ```
   🎉 Notice the `x` in `-rwxrw-r--`.

> 💡 **The most common numbers:** `755` for programs and shared folders, `644` for normal files, `600` for private files, and `770` for team folders.

---

## Part C: Build the Riverbend department folders (≈16 min)

Riverbend wants these shared folders on the server:

| Folder | Who can use it |
|---|---|
| `/srv/company/sales` | **Sales** group: full access. Everyone else: **no access** |
| `/srv/company/hr` | **HR** group: full access. Everyone else: **no access** (HR files are confidential!) |
| `/srv/company/public` | **IT** group can change files. **Everyone** can read. |

This is the same job you did in Windows with NTFS permissions on a shared folder.

8. Create the folders (they go in `/srv`, so we need `sudo`):
   ```bash
   sudo mkdir -p /srv/company/sales /srv/company/hr /srv/company/public
   ```

9. **Give each folder to its department group** with `chgrp` (**ch**ange **gr**ou**p**):
   ```bash
   sudo chgrp sales /srv/company/sales
   sudo chgrp hr /srv/company/hr
   sudo chgrp it /srv/company/public
   ```

10. **Set the permissions.** `770` = owner and group get everything; others get nothing:
    ```bash
    sudo chmod 770 /srv/company/sales /srv/company/hr
    sudo chmod 775 /srv/company/public
    ls -l /srv/company
    ```

11. **Test it as alice (sales).** `su - alice` lets you become Alice (use the employee password). Let's see what happens when she creates a file:
    ```bash
    su - alice
    echo "test" > /srv/company/sales/test.txt
    ls -l /srv/company/sales
    ```
    ```
    -rw-rw-r-- 1 alice alice 5 Oct 20 10:30 test.txt
    ```
    🤔 **Problem!** The file's group is **`alice`** (her personal group), not **`sales`**. That means Bob can't edit it. In Windows, the file would have **inherited** the folder's permissions automatically. Linux needs one more setting. Type `exit` to go back to student.

12. **The fix: the "setgid" bit.** Putting a **2** in front of the number tells the folder: *"every new file inside me gets my group."*
    ```bash
    sudo chmod 2770 /srv/company/sales /srv/company/hr
    sudo chmod 2775 /srv/company/public
    ls -l /srv/company
    ```
    Look for the `s` in the group spot: `drwxrws---`. That `s` is the setgid bit.

13. **Test again as alice.** This time she creates the real sales report:
    ```bash
    su - alice
    cd /srv/company/sales
    rm test.txt
    echo "Q3 sales: 1,200 tents and 3,400 sleeping bags" > q3-report.txt
    ls -l
    exit
    ```
    Now the group is **`sales`**. ✅

14. **Can bob (sales) add to alice's report?** (`>>` **adds** to the end of a file. One `>` would replace it.)
    ```bash
    su - bob
    echo "Bob: great quarter!" >> /srv/company/sales/q3-report.txt
    cat /srv/company/sales/q3-report.txt
    exit
    ```

15. **Can carol (HR) get in?**
    ```bash
    su - carol
    ls /srv/company/sales
    exit
    ```
    **Permission denied.** Good, because she's not in sales.

16. **Dave (IT) puts a welcome file in the public folder:**
    ```bash
    su - dave
    echo "Welcome to Riverbend! Help desk: ext. 4357" > /srv/company/public/welcome.txt
    exit
    ```

---

## Part D: A complex scenario with ACLs (≈8 min)

**New request:** *"HR needs to read the sales reports to calculate commissions. They should be able to **read** files in the sales folder, but **not change** anything."*

Problem: a folder has only **one** group, and sales is using it. In Windows you'd just click **Add...** on the Security tab and add the HR group with *Read*. Linux can do the same thing with an **ACL** (Access Control List).

17. Give HR read access to everything **already** in the sales folder:
    ```bash
    sudo setfacl -R -m g:hr:rX /srv/company/sales
    ```
    | Part | Meaning |
    |---|---|
    | `setfacl` | **set** **f**ile **ACL** |
    | `-R` | **R**ecursive: the folder and everything inside |
    | `-m` | **m**odify (add) an entry |
    | `g:hr:rX` | **g**roup **hr** gets **r**ead, plus **X** (capital X = "enter" permission on *folders only*) |

18. Make **future** files in sales readable by HR too. This is called a **default ACL**, and it's Linux's version of Windows inheritance:
    ```bash
    sudo setfacl -d -m g:hr:rx /srv/company/sales
    getfacl /srv/company/sales
    ```
    You'll see `group:hr:r-x` and `default:group:hr:r-x` in the list.

19. **Test it as carol:**
    ```bash
    su - carol
    cat /srv/company/sales/q3-report.txt
    echo "changed" >> /srv/company/sales/q3-report.txt
    exit
    ```
    She can read it ✅ but can't change it ✅. Exactly what HR asked for.

---

## ✅ Check your work

```bash
lab check 5
```

> 📸 **Take a snapshot now.** In Proxmox: your VM → **Snapshots** → **Take Snapshot**, name it `lab5-permissions`. You can take one while the VM is running.

---

## ✅ What to submit

1. A **screenshot** of `lab check 5` with everything passing
2. A **screenshot** of `ls -l /srv/company` and `getfacl /srv/company/sales`
3. Answers to these questions:
   1. Write the meaning of `-rwxr-x---` in plain English.
   2. What number would you give `chmod` for `rw-r-----`? For `rwxrwxr-x`? For "owner can do everything, nobody else can do anything"?
   3. What problem does the **setgid** bit (the `2` in `2770`) solve? What does Windows do instead?
   4. Why did we need an ACL for the HR request? Why couldn't we just use `chgrp`?
   5. Compare Linux permissions to NTFS permissions. Name one thing that's simpler in Linux and one thing that's simpler in Windows.

## ⭐ Challenge (optional, or at home)
- **Change an owner** with `chown`: `sudo touch /srv/company/hr/handbook.txt`, then `sudo chown carol:hr /srv/company/hr/handbook.txt`, then `ls -l /srv/company/hr`.
- **root ignores permissions.** Try `ls /srv/company/hr` (denied), then `sudo ls /srv/company/hr` (works). Why must admin accounts be protected so carefully?
- Look at the permissions of `/tmp` with `ls -ld /tmp`. What does the `t` at the end mean? (Search "sticky bit".)

---

## 🛠️ Troubleshooting

| Problem | Fix |
|---|---|
| `su: Authentication failure` | Use the **employee** password from Lab 4, not your own. (And remember erin is locked!) |
| `chmod: changing permissions of ...: Operation not permitted` | You don't own the file. Use `sudo`. |
| alice still gets *Permission denied* in the sales folder | Check `groups alice`. If `sales` isn't listed, re-do Lab 4 Part D. Also check `ls -ld /srv/company/sales`. |
| `setfacl: command not found` | Run `sudo apt install -y acl` |
| q3-report.txt has group `alice` instead of `sales` | You created it before the setgid step. Fix it with `sudo chgrp sales /srv/company/sales/q3-report.txt` |
| I'm still logged in as alice/bob/carol | Type `exit` until the prompt says `student@` |
