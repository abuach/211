# Lab 1: Installing Linux and Logging In

**Week 1 · Day 1 · 50-minute class (about 40 minutes of lab work)**

> **The big idea:** Installing a Linux server works a lot like installing Windows Server. You boot from an ISO, answer some questions, and reboot. The big difference is what you get afterward: **no desktop, just a command line.** That's normal for servers, and by the end of today you'll be comfortable with it.

### What you'll do today
1. Start your VM on Proxmox and install Ubuntu Server 26.04 LTS
2. Log in and run your first Linux commands
3. Connect to your server **remotely** with SSH (so you can copy and paste!)
4. Install the `lab` checking tool and take a snapshot

### Windows ↔ Linux

| In Windows Server you... | In Linux you... |
|---|---|
| Installed from a Windows Server ISO | Install from an Ubuntu Server ISO |
| Chose "Desktop Experience" or "Server Core" | Get the equivalent of **Server Core**: text only |
| Logged in as **Administrator** | Log in as a normal user who can *become* admin with **`sudo`** |
| Connected with **Remote Desktop (RDP)** | Connect with **SSH** (Secure Shell): a remote command line |
| Ran `ipconfig` | Run `ip a` |
| Ran `hostname` | Run `hostname` (same!) |

### Before you start
Log in to a CS Lab computer, open **Firefox**, and log in to **https://proxmox.cs.wallawalla.edu:8006** (realm **CS-LDAP**), just like in [Before Day 1](lab00-before-day-1.md).

---

## Part A: Start the VM and install Ubuntu Server (≈25 min, about 10 of it waiting)

1. In Proxmox, click your **Ubuntu Server** VM: **`cptr211-yourusername-u26.04s`** (the one ending in **`-u26.04s`**).
2. Click **▶ Start** (top right). Then click **Console** in the VM's menu on the left. You'll see the VM's screen right inside Firefox.

> 💡 **There's no mouse in the installer.** Click once inside the black console screen. Then use the **arrow keys** to move, **Enter** to choose, **Space** to check a box, and **Tab** to jump between items.

3. At the menu, choose **Try or Install Ubuntu Server** and press **Enter**. Wait for the installer to load (1-2 minutes).

Now answer the installer's questions. Each screen ends with **[ Done ]** at the bottom. Highlight it and press **Enter** to go to the next screen.

| # | Screen | What to do |
|---|---|---|
| 4 | **Language** | **English** → Enter |
| 5 | **Installer update available** | Choose **Continue without updating** |
| 6 | **Keyboard configuration** | Leave as **English (US)** → **Done** |
| 7 | **Choose type of installation** | Leave **Ubuntu Server** selected → **Done** |
| 8 | **Network configuration** | You should see one network card with an address like `172.27.60.123/18`. **Write down that address** (without the `/18`). Then **Done**. |
| 9 | **Proxy configuration** | Leave blank → **Done** |
| 10 | **Ubuntu archive mirror** | Wait until it says the mirror test passed → **Done** |
| 11 | **Guided storage configuration** | Leave **Use an entire disk** selected → **Done** |
| 12 | **Storage configuration** (summary) | **Done**, then on the warning box choose **Continue** |
| 13 | **Profile configuration** | See below ⬇️ |
| 14 | **Upgrade to Ubuntu Pro** | Leave **Skip for now** → **Continue** |
| 15 | **SSH configuration** | ⚠️ Press **Space** to check **[X] Install OpenSSH server**. Leave "Allow password authentication" checked. → **Done** |
| 16 | **Featured server snaps** | Don't select anything → **Done** |

> 💬 **"Use an entire disk" erases the disk?!** Only your VM's *virtual* 25 GB disk, which is empty. Nothing else is touched.

**Step 13, Profile configuration.** Type these exactly:

| Field | What to type | Example |
|---|---|---|
| Your name | Your real name | `Maria Garcia` |
| Your server's name | your first name in lowercase + `-linux` | `maria-linux` |
| Pick a username | **`student`** (exactly this) | `student` |
| Choose a password | A **strong** password you will remember | |
| Confirm your password | Same password again | |

> ⚠️ **Your server is on the CS department network**, so pick a real password, not `password123`. **Write it down.** There's no "forgot password" link on a Linux server.

17. The installer now copies files. This takes **5-15 minutes**. ☕ While you wait, read the **Windows ↔ Linux** table above and the "prompt" table in Part B below.
18. When the top says **Installation complete!**, **don't** press Reboot yet. First, **take the install disc out**:
    - In Proxmox, click **Hardware** in the VM's menu on the left
    - Double-click **CD/DVD Drive**
    - Choose **Do not use any media** → **OK**
19. Go back to **Console**, highlight **[ Reboot Now ]**, and press **Enter**.
    - If you see *"Please remove the installation medium, then press ENTER"*, just press **Enter**.

---

## Part B: First login (≈4 min)

20. The VM restarts. When you see a line like:
    ```
    maria-linux login:
    ```
    type `student` and press **Enter**, then type your password and press **Enter**.

> 💡 **When you type your password, nothing appears on screen.** No dots, no stars. That's a Linux security feature. Just type it and press Enter.

> 💡 **Messages appeared after the login prompt?** Sometimes a few lines (mentioning `cloud-init` or `ci-info`) print *after* the login prompt shows up. They're harmless. Press **Enter** to get a fresh `login:` prompt.

21. You're in! You'll see a welcome message and then a **prompt**:
    ```
    student@maria-linux:~$
    ```
    This is like the `PS C:\Users\Administrator>` prompt in PowerShell. It tells you:

    | Part | Meaning |
    |---|---|
    | `student` | who you are logged in as |
    | `@maria-linux` | which computer you're on |
    | `~` | which folder you're in (`~` means *your home folder*) |
    | `$` | you are a normal user. (`#` would mean you're the all-powerful **root** user) |

22. Type your first commands. Press **Enter** after each one:
    ```bash
    whoami
    hostname
    ip a
    ```
    - `whoami` → who am I logged in as?
    - `hostname` → what's this computer's name?
    - `ip a` → show my network addresses (like `ipconfig`). Find the line that says `inet 172.27.___.___`. **That's your server's address.** Make sure it matches what you wrote down in step 8.

---

## Part C: Connect with SSH (≈7 min)

The Proxmox console works, but it's awkward, and **copy/paste doesn't work well there.** Real sysadmins almost never sit at the server's screen. They connect remotely with **SSH**. It's like Remote Desktop, but text only.

23. Leave the Proxmox tab open. On the **lab computer**, open a terminal: press **Ctrl + Alt + T** (or click **Activities**, type **Terminal**, and press Enter).

24. Type this, using **your** server's address:
    ```bash
    ssh student@172.27.60.123
    ```
25. The first time, it asks:
    ```
    Are you sure you want to continue connecting (yes/no/[fingerprint])?
    ```
    Type **`yes`** and press Enter. This saves the server's "ID card" so your account recognizes it next time.
26. Type your **server's** password (the one you just made, not your lab password). It's invisible again! Press Enter.

You should see the same `student@maria-linux:~$` prompt, but now **inside the terminal window**. 🎉

> ✅ **From now on, always work through SSH.** You can copy commands from these instructions and paste them into the terminal:
> - **Paste:** **Ctrl + Shift + V** (or right-click → Paste)
> - **Copy** text from the terminal: select it, then **Ctrl + Shift + C**
>
> (In a terminal, plain Ctrl+C means "cancel," not "copy." More on that in Lab 2.)

---

## Part D: Install the `lab` tool and check your work (≈3 min)

Your instructor made a tool called `lab` that checks your work and tells you what to fix. Copy and paste this whole line into your SSH window. It asks for your password because it uses `sudo` ("run as administrator"):

> 💡 `sudo` asks with **`[sudo: authenticate] Password:`**. Unlike the login prompt, it shows a **`*` for each character** you type.

```bash
curl -fsSL https://raw.githubusercontent.com/abuach/cptr211-linux/main/labtools/install.sh | sudo bash
```

Then run:
```bash
lab check 1
```

You'll see a list of ✔ PASS and ✘ FAIL lines. Each FAIL includes a **hint** telling you what to do. Fix any problems and run `lab check 1` again until everything passes.

---

## Part E: Take a snapshot (≈3 min)

A **snapshot** saves the exact state of your VM so you can go back to it if something breaks. It's like a Windows **System Restore point** for the whole computer. **Always take a snapshot before risky changes.**

27. In Proxmox, click **Snapshots** in your VM's menu on the left.
28. Click **Take Snapshot**.
    - **Name:** `lab1-fresh-install` (snapshot names can't have spaces)
    - Leave **Include RAM** unchecked
    - Click **Take Snapshot** and wait for the task to say **OK**

> 💡 **Your VM keeps running when you log out.** It lives on the Proxmox server, not on the lab computer, so next class you can sit at **any** CS Lab computer and SSH right back in. You don't need to shut it down.

> ⏱️ **Ran out of time?** Finish before next class. You can do it from any CS Lab computer. Lab 2 starts from here.

---

## ✅ What to submit

1. A **screenshot** of `lab check 1` showing all checks passing
2. Answers to these questions (a few sentences each):
   1. What does the `$` at the end of the prompt tell you? What would `#` mean?
   2. Why is it better to manage a server through SSH than by sitting at its screen? Give two reasons.
   3. Compare installing Ubuntu Server to installing Windows Server. What was similar? What was different?
   4. What is a snapshot, and when would a sysadmin take one?

---

## 🛠️ Troubleshooting

| Problem | Fix |
|---|---|
| I can't log in to Proxmox, or I don't see my VM | Check that the realm says **CS-LDAP**. If it still doesn't work, tell your instructor. |
| The console is black | Click inside it and press **Enter**. If the VM isn't running, click **▶ Start**. |
| After rebooting, the **installer** started again | The install disc was still in. Do step 18 (Hardware → CD/DVD Drive → Do not use any media), then click **Reboot** at the top of Proxmox. |
| In step 8, the network card has **no address** | Wait 30 seconds. If it still has none, finish the install anyway and tell your instructor. |
| `ssh: connect to host ... Connection timed out` | Check the address with `ip a` *in the Proxmox console*. Make sure you typed it correctly. |
| `ssh: Connection refused` | The SSH server isn't installed. In the Proxmox console, run `sudo apt install -y openssh-server` |
| `Permission denied, please try again` | Wrong password. Use your **server's** password (not your lab password). The username is `student`. |
| `WARNING: REMOTE HOST IDENTIFICATION HAS CHANGED!` | You reinstalled your VM, so it has a new "ID card." Run `ssh-keygen -R 172.27.60.123` (your address) and connect again. |
| Typed the wrong server name during install | Run `sudo hostnamectl set-hostname yourname-linux` and reboot with `sudo reboot` |
| Screen fills with text and you can't see the prompt | Press **Enter**. Or type `clear`. |
