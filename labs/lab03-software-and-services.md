# Lab 3: Installing Software and Managing Services

**Week 1 · Day 3 · 50-minute class (about 40 minutes of lab work)**

> **The big idea:** In Windows you install software with installers or Server Manager's **Add Roles and Features**, and you control background programs in **Services** (`services.msc`). Linux has one command for each job: **`apt`** installs software, and **`systemctl`** controls services. Today you'll turn your VM into a real **web server**.

### Windows ↔ Linux

| Windows | Linux |
|---|---|
| **Run as administrator** / UAC prompt | `sudo` in front of a command |
| Windows Update | `sudo apt update` then `sudo apt upgrade` |
| Microsoft Store / `winget install` | `sudo apt install <package>` |
| Server Manager → Add Roles → **Web Server (IIS)** | `sudo apt install nginx` |
| Apps & Features → Uninstall | `sudo apt remove <package>` |
| `services.msc` / `Get-Service` | `systemctl status <service>` |
| `Start-Service`, `Stop-Service`, `Restart-Service` | `sudo systemctl start` / `stop` / `restart <service>` |
| Startup type: **Automatic** / **Disabled** | `sudo systemctl enable` / `disable <service>` |

> 💡 A **package** is a program bundled up so `apt` can install it. Ubuntu keeps tens of thousands of free packages in online **repositories**, a bit like an app store.

### Before you start
Start your VM and connect with SSH: `ssh student@<your-server-address>`

---

## Part A: Start the updates, then learn sudo (≈10 min)

Updates can take a few minutes, so we'll start them first and learn while they run.

1. **Refresh the list** of available software and updates, then **install the updates**:
   ```bash
   sudo apt update
   sudo apt upgrade -y
   ```
   - `apt update` doesn't install anything. It downloads the latest **list** of what's available, like *Check for updates* in Windows Update.
   - `apt upgrade` actually **installs** the updates. `-y` answers "yes" to "Do you want to continue?" automatically.

   > 💡 If a purple or pink screen pops up asking about restarting services, just press **Enter**.

2. **While it runs, read this:** in Windows you logged in as **Administrator**, who can do anything all the time. Linux is more careful. You work as a normal user, and you put **`sudo`** in front of a command only when it needs admin power. `sudo` asks for **your** password (`[sudo: authenticate] Password:`, showing a `*` per character), then remembers it for about 15 minutes. With `sudo`, you are temporarily **`root`**, Linux's all-powerful administrator account.

   > ⚠️ **Only use `sudo` when you need it.** A mistake with `sudo` can damage the whole system. A mistake without it can usually only hurt your own files.

3. When the upgrade finishes, try reading a protected file without and with `sudo`:
   ```bash
   cat /etc/shadow
   sudo cat /etc/shadow
   sudo whoami
   ```
   The first says **Permission denied**. The second works (`/etc/shadow` holds every user's scrambled passwords). The third shows that `sudo` makes you `root`.

---

## Part B: Install and remove software (≈3 min)

4. **Install** `htop`, a Task Manager for the terminal. (Ubuntu Server already includes it, so apt will just say *"htop is already the newest version"*. That's fine.)
   ```bash
   sudo apt install -y htop
   htop
   ```
   It shows CPU, memory, and running programs. Press **q** to quit. You'll use it in Lab 7.

5. **Remove** a package. Let's remove and reinstall `tree` from Lab 2 to see how it works:
   ```bash
   sudo apt remove -y tree
   tree
   sudo apt install -y tree
   ```
   After removing it, `tree` says *command not found*. On a real server, **remove anything you don't need**. Every extra program needs updates and could have security bugs.

---

## Part C: Install a web server (≈12 min)

In Windows Server, you'd add the **IIS** role. On Linux, one of the most popular web servers is **nginx** (pronounced "engine-x").

6. Install it:
   ```bash
   sudo apt install -y nginx
   ```

7. Check that its **service** is running:
   ```bash
   systemctl status nginx
   ```
   Look for these two lines:
   ```
   Loaded: loaded (/usr/lib/systemd/system/nginx.service; enabled; ...)
   Active: active (running) since ...
   ```
   - **`active (running)`** = it's running right now (like *Status: Running* in services.msc)
   - **`enabled`** = it will start automatically at boot (like *Startup type: Automatic*)

   Press **q** to get your prompt back.

8. **See it in your browser.** On the lab computer, open **Firefox** and go to your server's address:
   ```
   http://172.27.60.123
   ```
   You should see **"Welcome to nginx!"** 🎉 Your VM is now a web server.

9. **Make the page your own.** The web page files live in `/var/www/html`. That folder belongs to `root`, so you need `sudo` to edit:
   ```bash
   sudo nano /var/www/html/index.html
   ```
   Type this, replacing the name with yours:
   ```html
   <h1>Riverbend Outfitters</h1>
   <p>Welcome to the CPTR 211 server, managed by Maria Garcia.</p>
   ```
   Save (**Ctrl + O**, **Enter**) and exit (**Ctrl + X**). **Refresh your browser** and you should see your page.

   > 💡 For the rest of this course, imagine you've just been hired as the sysadmin at **Riverbend Outfitters**, a small outdoor-gear company. This server is theirs.

10. You can also test the web server from **inside** the server with `curl`, a command-line web browser:
    ```bash
    curl http://localhost
    ```

---

## Part D: Control the service (≈8 min)

11. **Stop** the web server, then refresh your browser:
    ```bash
    sudo systemctl stop nginx
    systemctl status nginx
    ```
    Status now says **`inactive (dead)`**, and your browser shows an error. The website is down! Press **q**.

12. **Start** it again and refresh the browser:
    ```bash
    sudo systemctl start nginx
    ```

13. **Restart** it. You do this after changing a service's settings, so it re-reads them:
    ```bash
    sudo systemctl restart nginx
    ```

14. **Disable** and **enable** it. This doesn't start or stop it now. It controls what happens **at boot**:
    ```bash
    sudo systemctl disable nginx
    systemctl is-enabled nginx
    sudo systemctl enable nginx
    systemctl is-enabled nginx
    ```

---

## Part E: Set the time zone (≈4 min)

Servers need the correct time. Log files, scheduled tasks, and security investigations all depend on it.

15. Find your time zone. The list is long, so we filter it:
    ```bash
    timedatectl list-timezones | grep America
    ```
    The `|` is called a **pipe**. It sends the output of the first command *into* the second one. Here, `grep` keeps only the lines containing "America." Press **q** if the list doesn't end on its own.

16. Set it. Use your own zone, for example `America/New_York`, `America/Chicago`, `America/Denver`, or `America/Los_Angeles`:
    ```bash
    sudo timedatectl set-timezone America/New_York
    timedatectl
    ```

---

## ✅ Check your work

```bash
lab check 3
```

---

## ✅ What to submit

1. A **screenshot** of `lab check 3` with everything passing
2. A **screenshot** of your browser showing your Riverbend web page
3. Answers to these questions:
   1. What is the difference between `apt update` and `apt upgrade`?
   2. What is the difference between a service being **active** and being **enabled**? Give the Windows services.msc words for each.
   3. You changed a service's configuration file, but nothing happened. What command did you probably forget?
   4. Why should you avoid using `sudo` for everything?

## ⭐ Challenge (optional, or at home)
- **Prove "enabled" works:** run `sudo reboot`, SSH back in after 30 seconds, and check `systemctl status nginx`.
- List **all** running services (like the services.msc list): `systemctl list-units --type=service --state=running`. Can you find `ssh.service`?
- Add a second page: `sudo nano /var/www/html/about.html`, then visit `http://<your-address>/about.html`.

---

## 🛠️ Troubleshooting

| Problem | Fix |
|---|---|
| `Could not get lock /var/lib/dpkg/lock-frontend` | Another update is already running in the background (this often happens right after boot). Wait 2-3 minutes and try again. |
| `E: Unable to locate package` | Check spelling. Run `sudo apt update` first. |
| `Temporary failure resolving 'archive.ubuntu.com'` | The VM has no internet. Try `sudo reboot`, wait 30 seconds, and reconnect. If it still fails, tell your instructor. |
| Browser can't reach the page | Is nginx running (`systemctl status nginx`)? Are you using your server's `172.27.x.x` address (check with `ip a`)? Use `http://`, not `https://`. |
| Browser still shows "Welcome to nginx!" after you edited the page | Make sure the file is named exactly `index.html` in `/var/www/html`. Force a refresh with **Ctrl + Shift + R**. |
| `systemctl status` output won't go away | Press **q** |
