# Lab 2: Finding Your Way Around (Files and Folders)

**Week 1 · Day 2 · 50-minute class (about 40 minutes of lab work)**

> **The big idea:** In Windows you mostly manage files by clicking in File Explorer. On a Linux server you do the same jobs (open folders, create, copy, move, rename, delete) by typing short commands. Once you know about 10 commands, you can do almost anything.

### Windows ↔ Linux

| Windows | Linux | Notes |
|---|---|---|
| `C:\` | `/` | Linux has **one** tree starting at `/` (called "root"). No drive letters. |
| `C:\Users\maria` | `/home/maria` | Your home folder. Shortcut: `~` |
| Backslash `\` | Forward slash `/` | `C:\Users\maria\Documents` → `/home/maria/Documents` |
| `Notes.txt` = `notes.txt` | `Notes.txt` ≠ `notes.txt` | ⚠️ **Linux is case sensitive!** |
| Hidden file = an attribute | Hidden file = name starts with a **dot**: `.bashrc` | |
| `dir` | `ls` | PowerShell also accepts `ls`. It borrowed the name from Linux! |
| `cd`, `mkdir` | `cd`, `mkdir` | Same! |
| `copy`, `move`, `del`, `type` | `cp`, `mv`, `rm`, `cat` | |
| Notepad | `nano` | A simple text editor that runs inside the terminal |
| `Get-Help` | `man` or `--help` | |

### Before you start: how to start every lab
1. Log in to **any** CS Lab computer and open a terminal (**Ctrl + Alt + T**).
2. Connect to your server (use **your** server's address from Lab 1):
   ```bash
   ssh student@172.27.60.123
   ```

> 💡 **Your VM is always on.** It runs on the Proxmox server, so you don't need to start it. If `ssh` times out, open https://proxmox.cs.wallawalla.edu:8006 and check that your VM is running (click **▶ Start** if it isn't). Then open its **Console** and run `ip a`. Your address can occasionally change after the VM has been off for a while.
>
> **Paste** into the terminal with **Ctrl + Shift + V**.

---

## Part A: Warm-up and "Where am I?" (≈7 min)

1. Learn these **time-saving keys** first. You'll use them every day:

   | Key | What it does |
   |---|---|
   | **↑** (up arrow) | Brings back your previous command |
   | **Tab** | Finishes a word for you |
   | **Ctrl + C** | **Cancels** whatever is running. Your "panic button." |
   | `clear` | Clears the screen |

   Try the panic button: `ping` keeps going forever on Linux (Windows stops after 4). Press **Ctrl + C** to stop it.
   ```bash
   ping ubuntu.com
   ```
   Try **Tab**: type `cat /etc/os-` and press **Tab**. It finishes the name `/etc/os-release` for you. Press Enter to see which Linux version you're running.

2. Every terminal is always "standing" inside one folder, called the **current directory** (directory = folder). Ask where you are:
   ```bash
   pwd
   ```
   **p**rint **w**orking **d**irectory. It says `/home/student`. That's your home folder.

3. See what's in it, including **hidden** files:
   ```bash
   ls
   ls -a
   ```
   The `-a` is an **option** (also called a *flag*). It changes how the command behaves. `-a` means "show **a**ll, including hidden files." Files starting with `.` are hidden.

---

## Part B: Take a tour (≈7 min)

4. Go to the very top of the tree and look around:
   ```bash
   cd /
   ls
   ```
   Here are the important folders, compared to Windows:

   | Linux folder | What's in it | Windows equivalent |
   |---|---|---|
   | `/home` | Users' personal folders | `C:\Users` |
   | `/root` | The administrator's home folder | `C:\Users\Administrator` |
   | `/etc` | **Settings and configuration files** | The Registry + config files in `C:\Windows` |
   | `/var/log` | **Log files** | Event Viewer logs |
   | `/usr/bin` | Programs (commands) | `C:\Program Files`, `C:\Windows\System32` |
   | `/tmp` | Temporary files | `C:\Windows\Temp` |
   | `/srv` | Data the server shares with others | A folder like `D:\Shares` |

5. Visit two of them:
   ```bash
   cd /etc
   ls
   cd /var/log
   ls
   ```

6. Move around with **relative** paths. `..` means "the folder above this one." **Predict** what each `pwd` will say before you press Enter:
   ```bash
   cd /var
   cd log
   pwd
   cd ..
   pwd
   cd ../..
   pwd
   ```
   - An **absolute path** starts with `/` and works from anywhere: `/var/log`
   - A **relative path** starts from where you are now: from `/var`, `cd log` takes you to `/var/log`

7. Go back home. `cd` by itself always takes you home:
   ```bash
   cd
   pwd
   ```

---

## Part C: Create folders and files (≈12 min)

We'll build this structure in your home folder:

```
lab2/
├── documents/
│   ├── notes.txt
│   ├── notes-backup.txt
│   ├── README
│   └── readme
├── projects/
│   ├── website/
│   │   └── index.html
│   └── scripts/
└── archive/
    └── old-notes.txt
```

8. Make the folders:
   ```bash
   cd ~
   mkdir lab2
   cd lab2
   mkdir documents archive
   mkdir -p projects/website projects/scripts
   ```
   - `mkdir` = **m**a**k**e **dir**ectory. You can make several at once.
   - `-p` makes the **p**arent folders too. `projects` didn't exist yet, so `-p` creates it on the way.

9. Install a helpful program called `tree` and look at what you built. (You'll learn about `sudo` and installing software next lab.)
   ```bash
   sudo apt install -y tree
   tree ~/lab2
   ```

10. Create an empty file with `touch`:
    ```bash
    touch projects/website/index.html
    ```

11. Now create a file **with text in it** using the `nano` editor:
    ```bash
    nano documents/notes.txt
    ```
    Type these lines:
    ```
    My Linux notes
    Linux is case sensitive: File.txt and file.txt are different files.
    The top of the file system is / (called root).
    ```
    Now **save and exit**:
    - Press **Ctrl + O** (the letter O, for "**O**utput"), then **Enter**. This **saves**.
    - Press **Ctrl + X** to e**x**it.

    > 💡 The bottom of the nano screen lists shortcuts. `^` means the **Ctrl** key, so `^X` = Ctrl + X.

12. Show the file's contents (`cat` is like `type` in CMD):
    ```bash
    cat documents/notes.txt
    ```

13. **Prove that Linux is case sensitive.** In Windows, this would make *one* file. In Linux it makes *two*:
    ```bash
    touch documents/README documents/readme
    ls documents
    ```

---

## Part D: Copy, move, rename, delete (≈7 min)

14. **Copy** a file with `cp` (*from* → *to*):
    ```bash
    cp documents/notes.txt documents/notes-backup.txt
    ```

15. **Move and rename** with `mv`. In Linux, rename and move are the **same command**. Create a draft file, then move it into `archive` **and** rename it, in one step:
    ```bash
    echo "first draft of my notes" > draft.txt
    mv draft.txt archive/old-notes.txt
    ls
    ls archive
    ```
    (`echo` prints text. The `>` sends that text **into a file** instead of the screen.)

16. **Delete** a file with `rm`:
    ```bash
    touch trash-me.txt
    rm trash-me.txt
    ls
    ```

> ⚠️ **There is no Recycle Bin on the command line.** `rm` deletes immediately and permanently. `rm -r foldername` deletes a folder **and everything inside it**. Always double-check before pressing Enter, and **never** run `sudo rm -rf` unless you are 100% sure.

---

## Part E: Save output and get help (≈6 min)

17. **Save a command's output to a file** with `>` (PowerShell has the same trick!):
    ```bash
    ls /etc > ~/lab2/etc-list.txt
    less ~/lab2/etc-list.txt
    ```
    Nothing printed on screen. The output went *into the file*. `less` lets you scroll a long file: use **↑ ↓** or **Space**, and press **q** to **q**uit.

18. **Getting help.** Nobody memorizes every option:
    ```bash
    ls --help
    man ls
    ```
    `man` opens the full **man**ual page. Press **q** to quit. Use it to find out: **what does `ls -l` show? What does adding `-h` change?** Try `ls -lh /var/log`.

---

## ✅ Check your work

```bash
lab check 2
```
Fix anything that fails, then run it again.

> 💡 **Don't use `sudo` in this lab** except for `apt install`. If you used `sudo` to create files in your home folder, they'll belong to `root` instead of you, and the check will tell you how to fix it.

---

## ✅ What to submit

1. A **screenshot** of `lab check 2` with everything passing
2. Answers to these questions:
   1. What is the difference between an absolute path and a relative path? Give one example of each.
   2. You're in `/var/log`. What folder are you in after `cd ../..`?
   3. In Windows, could you have both `README` and `readme` in the same folder? Why might case sensitivity cause problems when copying files from Windows to Linux?
   4. `mv` does two jobs. What are they?
   5. Why is `rm` more dangerous than pressing Delete in File Explorer?

## ⭐ Challenge (optional, or at home)
- **Search inside files** with `grep` (like `findstr`): `grep case ~/lab2/documents/notes.txt`
- **Find files by name** with `find`: `find ~/lab2 -name "*.txt"`. The `*` is a **wildcard** meaning "anything."
- `head` and `tail` show the first and last 10 lines of a file. Try `head /etc/services`.
- What does `cd -` do? Try it after moving between two folders.

---

## 🛠️ Troubleshooting

| Problem | Fix |
|---|---|
| `No such file or directory` | Check spelling and **upper/lower case**. Run `pwd` to see where you are, then `ls`. |
| `Permission denied` when creating a file | You're probably outside your home folder. Run `cd ~/lab2` first. |
| I'm stuck inside a screen and can't type commands | You're in `less` or `man` (press **q**) or `nano` (press **Ctrl + X**). |
| nano asks *"Save modified buffer?"* | Press **Y** for yes, then **Enter**. |
| A command seems frozen | Press **Ctrl + C** |
| I made a mess of `~/lab2` | Start over: `rm -r ~/lab2` and begin Part C again. |
