# Windows → Linux Cheat Sheet

**CPTR 211 · Keep this open during every lab.**

## Starting every lab
1. Log in to any **CS Lab** computer and open a terminal: **Ctrl + Alt + T**
2. `ssh student@172.27.___.___` ← your server's address (find it with `ip a` in the Proxmox console)
3. Paste into the terminal with **Ctrl + Shift + V**. Copy with **Ctrl + Shift + C**.
4. Your VM stays on when you leave. **Proxmox** (VM console, Start, snapshots): https://proxmox.cs.wallawalla.edu:8006 (realm **CS-LDAP**)

## Keyboard survival kit
| Keys | What it does |
|---|---|
| **↑ / ↓** | Previous / next command |
| **Tab** | Auto-complete a name (press twice to see choices) |
| **Ctrl + C** | **Stop** the running command (panic button!) |
| **Ctrl + L** | Clear the screen |
| **q** | Quit `less`, `man`, `htop`, `systemctl status`, `journalctl` |
| **Ctrl + O**, **Enter** | **Save** in nano |
| **Ctrl + X** | **Exit** nano |
| **Ctrl + W** | Search in nano |

---

## Files and folders
| Task | Windows (PowerShell / CMD) | Linux |
|---|---|---|
| Where am I? | `pwd` / `cd` | `pwd` |
| List files | `dir` / `ls` | `ls`, `ls -l`, `ls -a`, `ls -lh` |
| Change folder | `cd C:\Users` | `cd /home` |
| Go to my home folder | `cd ~` | `cd` or `cd ~` |
| Up one folder | `cd ..` | `cd ..` |
| Make a folder | `mkdir` | `mkdir`, `mkdir -p a/b/c` |
| Create an empty file | `New-Item file.txt` | `touch file.txt` |
| Edit a file | `notepad file.txt` | `nano file.txt` |
| Show a file | `type` / `Get-Content` | `cat`, `less`, `head`, `tail` |
| Copy | `copy` / `Copy-Item` | `cp source dest` |
| Move / rename | `move`, `ren` | `mv old new` |
| Delete a file | `del` / `Remove-Item` | `rm file` ⚠️ no Recycle Bin |
| Delete a folder | `rmdir /s` | `rmdir` (empty) / `rm -r` (everything) |
| Search inside files | `findstr` / `Select-String` | `grep word file` |
| Find a file by name | `dir /s name` / `Get-ChildItem -Recurse` | `find /path -name "name"` |
| Help | `Get-Help cmd` | `man cmd` or `cmd --help` |

## Important folders
| Linux | What it holds | Windows |
|---|---|---|
| `/` | Top of everything | `C:\` |
| `/home/<user>` (`~`) | User files | `C:\Users\<user>` |
| `/root` | Admin's home | `C:\Users\Administrator` |
| `/etc` | Settings / config files | Registry, `C:\Windows\System32\config` |
| `/var/log` | Log files | Event Viewer |
| `/usr/bin`, `/usr/sbin` | Programs | `C:\Program Files`, `C:\Windows\System32` |
| `/srv` | Shared data | `D:\Shares` |
| `/tmp` | Temporary files | `C:\Windows\Temp` |

## Redirection and pipes
| Symbol | Meaning | Example |
|---|---|---|
| `>` | Send output **into** a file (replaces it) | `ls /etc > list.txt` |
| `>>` | **Add** output to the end of a file | `date >> log.txt` |
| `\|` | Send output **into another command** | `ps aux \| grep nginx` |
| `$( )` | Insert a command's output | `echo "Today is $(date +%A)"` |

---

## Software and services
| Task | Windows | Linux |
|---|---|---|
| Run as administrator | Right-click → Run as admin | `sudo command` |
| Check for updates | Windows Update | `sudo apt update` |
| Install updates | Windows Update | `sudo apt upgrade -y` |
| Install software | Installer / `winget` / Add Roles | `sudo apt install -y pkg` |
| Uninstall | Apps & Features | `sudo apt remove pkg` |
| Service status | `Get-Service name` | `systemctl status name` |
| Start / stop / restart | `Start-Service` ... | `sudo systemctl start` / `stop` / `restart name` |
| Start at boot? | Startup type: Automatic | `sudo systemctl enable name` |
| Don't start at boot | Startup type: Disabled | `sudo systemctl disable name` |
| Restart the computer | `Restart-Computer` | `sudo reboot` |
| Shut down | `Stop-Computer` | `sudo poweroff` |
| Network addresses | `ipconfig` | `ip a` |
| Computer name | `hostname` | `hostname` |

---

## Users and groups
| Task | Windows | Linux |
|---|---|---|
| Who am I? | `whoami` | `whoami`, `id` |
| Create a user | `New-LocalUser` | `sudo adduser name` |
| Create a group | `New-LocalGroup` | `sudo addgroup name` |
| Add user to group | `Add-LocalGroupMember` | `sudo usermod -aG group user` ⚠️ don't forget the **a** |
| Make an admin | Add to *Administrators* | `sudo usermod -aG sudo user` |
| List a user's groups | `whoami /groups` | `groups user` |
| Reset a password | `Set-LocalUser -Password` | `sudo passwd user` |
| Disable an account | *Account is disabled* | `sudo passwd -l user` (unlock: `-u`) |
| Account status | | `sudo passwd -S user` (L = locked, P = OK) |
| Account expires | AD: *Account expires* | `sudo chage -E 2026-12-31 user` |
| Force password change | *User must change password at next logon* | `sudo chage -d 0 user` |
| Delete a user | `Remove-LocalUser` | `sudo deluser --remove-home user` |
| Become another user | `runas /user:name` | `su - name` (then `exit`) |

---

## Permissions
```
-rwxr-x---  1  alice  sales  ...  file
 └┬┘└┬┘└┬┘     owner  group
 owner group others
```
| | r | w | x |
|---|---|---|---|
| **File** | read it | change it | run it as a program |
| **Folder** | list what's inside | create/delete files inside | enter it (`cd`) |
| **Number** | 4 | 2 | 1 |

| Number | Means | Typical use |
|---|---|---|
| `755` | rwxr-xr-x | programs, public folders |
| `644` | rw-r--r-- | normal files |
| `600` | rw------- | private files |
| `770` | rwxrwx--- | team folders |
| `2770` | rwxrws--- | team folders where new files keep the folder's group (**setgid**) |

| Task | Windows | Linux |
|---|---|---|
| Change permissions | Security tab / `icacls` | `chmod 750 file`, `chmod u+x file` |
| Change owner | Advanced → Owner | `sudo chown user file`, `sudo chown user:group file` |
| Change group | | `sudo chgrp group file` |
| Add one more group/user | Security tab → Add | `sudo setfacl -m g:group:rx folder` |
| View ACL | `icacls` | `getfacl file` |
| Inheritance for new files | automatic | `sudo setfacl -d -m g:group:rx folder` |

---

## Monitoring, logs, firewall
| Task | Windows | Linux |
|---|---|---|
| CPU / memory / processes | Task Manager | `htop`, `top`, `ps aux` |
| Memory | Task Manager → Performance | `free -h` |
| Disk space | This PC | `df -h` |
| Folder size | Properties | `du -sh folder` |
| End a task | End task | `kill PID`, `kill -9 PID`, `pkill name` |
| View logs | Event Viewer | `journalctl`, `journalctl -u service`, `/var/log/*` |
| Security log | Security log (4624/4625) | `sudo grep "Failed password" /var/log/auth.log` |
| Watch a log live | | `sudo tail -f /var/log/auth.log` |
| Who logged in | | `last`, `who` |
| Firewall status | Windows Defender Firewall | `sudo ufw status verbose` |
| Allow a service | New inbound rule | `sudo ufw allow OpenSSH` |
| Turn on firewall | | `sudo ufw enable` ⚠️ allow SSH first! |

## Backups and scheduling
| Task | Windows | Linux |
|---|---|---|
| Make an archive | Compress to .zip | `tar -czvf backup.tar.gz /folder` |
| List an archive | open the .zip | `tar -tzvf backup.tar.gz` |
| Restore | Extract All | `sudo tar -xzvf backup.tar.gz -C /` |
| Mirror a folder | `robocopy /MIR` | `rsync -av /source/ /dest/` |
| Scheduled tasks | Task Scheduler | `sudo crontab -e`, `sudo crontab -l` |

```
 minute  hour  day-of-month  month  day-of-week   command
   0      2        *           *         *        /usr/local/sbin/backup-company.sh
```
Check cron lines at **https://crontab.guru**

## The lab tool
| Command | What it does |
|---|---|
| `lab check 3` | Check your work for Lab 3 |
| `lab check all` | Check everything |
| `lab hint 2` | (Lab 9) Hint for ticket 2 |
