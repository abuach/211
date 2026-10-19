# Lab 6: Sharing Folders with Windows (Samba)

**Week 2 · Day 6 · 50-minute class (about 40 minutes of lab work)**

> **The big idea:** Windows computers share folders with a protocol called **SMB** (that's what `\\server\share` uses). Linux can speak SMB too, using a program called **Samba**. Today your Linux server becomes a file server that Windows (and Linux) computers can connect to, **just like the Windows file server you built earlier in the course.**

### What you'll do today
1. Install Samba
2. Safely edit a configuration file
3. Share the Riverbend department folders
4. Connect to the shares over the network
5. See how share permissions and file permissions work **together**

### Windows ↔ Linux

| Windows Server | Linux + Samba |
|---|---|
| Add the **File Server** role | `sudo apt install samba` |
| Folder → Properties → **Sharing** → Advanced Sharing | Add a `[sharename]` section to `/etc/samba/smb.conf` |
| **Share permissions** | Samba settings: `valid users`, `read only`, `write list` |
| **NTFS permissions** | Linux permissions and ACLs (Lab 5) |
| The **most restrictive** of share and NTFS permissions wins | **Same!** Both Samba *and* Linux must allow it |
| Users log in with their Windows/AD password | Users need a separate **Samba password** (`smbpasswd`) |
| Computer Management → Shared Folders → Sessions | `sudo smbstatus` |
| Connect with `\\server\share` | Connect with `\\server-address\share`, exactly the same! |

### Before you start
Start your VM and connect with SSH. You need the folders from Lab 5.

---

## Part A: Install Samba (≈3 min)

1. Install it:
   ```bash
   sudo apt install -y samba
   ```
2. Check that the service is running:
   ```bash
   systemctl status smbd
   ```
   `smbd` is the **SMB d**aemon. (A *daemon* is the Linux word for a background service.) Press **q**.

---

## Part B: Edit the configuration file safely (≈12 min)

Almost every Linux service is configured with a **text file** in `/etc`. For Samba, it's `/etc/samba/smb.conf`.

> 🛡️ **Golden rule of sysadmins: make a backup before you edit a config file.** If you break it, you can copy the backup back.

3. Make a backup copy:
   ```bash
   sudo cp /etc/samba/smb.conf /etc/samba/smb.conf.bak
   ```

4. Open the file to edit it. (Lines starting with `#` or `;` are **comments** that Samba ignores.)
   ```bash
   sudo nano /etc/samba/smb.conf
   ```
   Jump to the **very end** of the file by pressing **Ctrl + End** (or **Alt + /**). Then **paste** in this text (copy it from this page, and paste with right-click or Ctrl+V / ⌘V):

   ```ini
   # ===== Riverbend Outfitters shares =====

   [sales]
      comment = Sales department
      path = /srv/company/sales
      valid users = @sales @hr
      read only = no
      create mask = 0660
      directory mask = 2770

   [hr]
      comment = HR department - confidential
      path = /srv/company/hr
      valid users = @hr
      read only = no
      create mask = 0660
      directory mask = 2770

   [public]
      comment = Company-wide documents
      path = /srv/company/public
      read only = yes
      write list = @it
      create mask = 0664
      directory mask = 2775
   ```
   Save (**Ctrl + O**, **Enter**) and exit (**Ctrl + X**).

   Here's what each setting means:

   | Setting | Meaning | Windows equivalent |
   |---|---|---|
   | `[sales]` | The share name people will type: `\\server\sales` | Share name |
   | `path` | Which folder on the server is shared | The folder you right-clicked |
   | `valid users = @sales @hr` | Only these people may connect. `@` means "a group." | Share permissions list |
   | `read only = no` | Allow changes through this share | Share permission: *Change* |
   | `write list = @it` | Even though the share is read-only, these people may write | Share permission: *Change* for one group |
   | `create mask = 0660` | Permissions for new files (rw for owner and group) | NTFS inheritance |
   | `directory mask = 2770` | Permissions for new folders | NTFS inheritance |

   > 💡 Notice that **HR is allowed to connect to the sales share**, but the Linux ACL from Lab 5 only lets them *read*. Both layers matter, just like share + NTFS permissions in Windows.

5. **Check your work** with `testparm`, Samba's built-in config checker:
   ```bash
   testparm
   ```
   Look for **`Loaded services file OK.`** near the top. Press **Enter** when it asks, and it prints your shares. If you see an error, it tells you the line number. Go back into nano and fix it.

   > 💡 Many services have a checker like this. You'll see `nginx -t` in Lab 9. **Always test a config before restarting the service.**

6. **Restart Samba** so it reads the new settings:
   ```bash
   sudo systemctl restart smbd
   ```

---

## Part C: Give users Samba passwords (≈4 min)

Samba keeps its **own** password list, separate from the Linux login password. (In a Windows domain, one AD password works everywhere. Linux can do that too, but it takes more setup.)

7. Add Samba passwords for the employees. Use the **employee password** from Lab 4 so it's easy to remember. Each command asks for the password twice:
   ```bash
   sudo smbpasswd -a alice
   sudo smbpasswd -a bob
   sudo smbpasswd -a carol
   sudo smbpasswd -a dave
   ```
   The `-a` means **a**dd. You'll see `Added user alice.`

8. List the Samba users:
   ```bash
   sudo pdbedit -L
   ```

---

## Part D: Connect over the network (≈12 min)

Find your server's address again if you need it: `ip a` (the `172.27.x.x` one). Connect from **one** of these:

### 🐧 From the CS Lab computer (Ubuntu)

9. Open the **Files** app (the folder icon). In the left sidebar, click **+ Other Locations**. At the bottom, find **Connect to Server** and type (with your address):
    ```
    smb://172.27.60.123/sales
    ```
    Click **Connect**.
10. A login box appears:
    - **Connect As:** **Registered User**
    - **Username:** `alice`
    - **Domain:** leave it as `WORKGROUP`
    - **Password:** the employee password
    - Choose **Forget password immediately**
    - Click **Connect**
11. You should see `q3-report.txt`! Double-click it to open it.

### 🪟 From your Windows 11 VM

9. In Proxmox, start your **Windows 11** VM (`cptr211-yourusername-w11d`) and open its **Console**. Open **File Explorer**, click in the **address bar**, and type (with your address):
    ```
    \\172.27.60.123\sales
    ```
    Press **Enter**.
10. In the *"Enter network credentials"* box, type **User name:** `alice` and the employee password. Leave *Remember my credentials* **unchecked**. Click **OK**.
    > 💡 If `alice` doesn't work, try `maria-linux\alice` (your server's name, a backslash, then the username).
11. You should see `q3-report.txt`! Double-click it to open it in Notepad.

### 🧪 Test it

12. **Create a new text file in the `sales` share** named exactly **`from-network.txt`**:
    - **Ubuntu:** open the **Text Editor** app, type a sentence, and press **Ctrl + S**. In the save window, click the **sales** share in the left sidebar, name the file `from-network.txt`, and click **Save**.
    - **Windows:** in File Explorer, right-click → **New** → **Text Document**. Name it `from-network`. (Windows hides the `.txt`.)

13. Back in your **SSH window**, see that the file arrived on the Linux server:
    ```bash
    ls -l /srv/company/sales
    ```
    ```
    -rw-rw----+ 1 alice sales 0 Oct 21 10:15 from-network.txt
    ```
    The owner is **alice**, and the group is **sales**, because of the setgid bit from Lab 5. ✅

14. See who's connected (like **Computer Management → Shared Folders → Sessions** in Windows):
    ```bash
    sudo smbstatus
    ```

> 📱 **Can't connect at all?** Use the [Plan B](#-plan-b-test-from-the-server-itself) at the bottom of this lab so you can finish. Then ask your instructor.

---

## Part E: Test the two layers of permissions (≈6 min)

Now connect as **carol** and then as **alice**, and fill in the table. To switch users, you must **disconnect first**:

- **Ubuntu Files:** click the **⏏ eject** button next to the share in the left sidebar. Then connect again.
- **Windows:** close File Explorer. Open **PowerShell** and run `net use * /delete /y`. Then connect again.

| # | Connect as | To share | Try to... | Expected result | What happened? |
|---|---|---|---|---|---|
| 1 | `carol` (HR) | `sales` | open `q3-report.txt` | ✅ Works (ACL gives HR read) | |
| 2 | `carol` (HR) | `sales` | create a new file | ❌ Denied | |
| 3 | `alice` (sales) | `hr` | connect at all | ❌ Denied | |

> 🤔 Tests 2 and 3 were blocked by *different layers*. Which layer blocked each one: **Samba** (the share settings) or **Linux** (the folder permissions)? Write this in your answers.

---

## ✅ Check your work

```bash
lab check 6
```

---

## ✅ What to submit

1. A **screenshot** of `lab check 6` with everything passing
2. A **screenshot** of the Files app (or Windows File Explorer) showing the contents of the `sales` share
3. Your completed **table from Part E**
4. Answers to these questions:
   1. Why should you make a backup of a config file before editing it? How would you restore the backup?
   2. What does `testparm` do, and why should you run it before restarting Samba?
   3. In Part E, tests 2 and 3 were both denied. Which layer (Samba or Linux permissions) blocked each one? How is this like share permissions vs. NTFS permissions in Windows?
   4. Why do users need a separate `smbpasswd`? How is that different from a Windows domain?

## ⭐ Challenge (optional, or at home)
- Finish testing the shares: as `alice`, can you **read** `welcome.txt` in `public`? Can you **create** a file there? As `dave` (IT), can you create a file in `public`? Explain each result using the `[public]` settings.
- Create a **hidden** share (in Windows, a share whose name ends in `$` doesn't show up in browse lists). Add a share called `[it$]` for `/srv/company/public` with `valid users = @it`. Can you connect to `\\<address>\it$` as dave?
- Run `sudo smbpasswd -d bob`. What happens when Bob tries to connect? (`-e` turns him back on.)

---

## 🛠️ Troubleshooting

| Problem | Fix |
|---|---|
| `testparm` shows an error | Read the line number it mentions. Open the file with `sudo nano /etc/samba/smb.conf` and check for typos. If it's a mess, restore the backup with `sudo cp /etc/samba/smb.conf.bak /etc/samba/smb.conf` and redo step 5. |
| Windows: *"The network path was not found"* | Check the address and use backslashes `\\`. Can you `ping` your server's address from PowerShell? Is smbd running? |
| Windows: *"Multiple connections to a server... by the same user... are not allowed"* (error 1219) | You're still connected as someone else. Run `net use * /delete /y` in PowerShell and try again. |
| Windows: login keeps failing | Try the username as `yourserver\alice`. Check that you ran `smbpasswd -a alice`. |
| *Access denied* when you expected it to work | Check both layers: the share settings (`testparm`) and the folder permissions (`ls -ld /srv/company/...`, `getfacl`). |
| Ubuntu Files: *"Unable to access location"* or it keeps asking for the password | Make sure you typed `smb://` at the start and the right address. Check that you ran `smbpasswd -a` for that user. |
| Ubuntu Files connects as the **wrong** user | Eject the share in the sidebar first. If you picked *Remember password*, log out of the lab computer and back in. |

---

## 📱 Plan B: Test from the server itself

If you can't connect over the network, use `smbclient`, a command-line SMB client, from inside the VM. It talks to Samba exactly the way Windows does:

```bash
sudo apt install -y smbclient
smbclient -L localhost -U alice
```
That lists the shares (type alice's Samba password). Now copy a file into the sales share **over SMB**:
```bash
echo "hello from smbclient" > /tmp/from-network.txt
smbclient //localhost/sales -U alice -c 'put /tmp/from-network.txt from-network.txt'
ls -l /srv/company/sales
```
You can also do the Part E tests with commands like `smbclient //localhost/hr -U alice -c 'ls'` (test 3) or `smbclient //localhost/sales -U carol -c 'put /etc/hostname carol.txt'` (test 2).
