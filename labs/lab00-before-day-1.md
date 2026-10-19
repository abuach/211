# Before Day 1: Find Your Linux VM

**Do this before our first Linux class. It takes about 5 minutes.** You can do it from any CS Lab computer.

For the next 3 weeks you'll build and run your own **Linux server**. It lives on the department's **Proxmox** server, the same place as the Windows VMs you've been using. Your Linux VM is empty, like a brand-new computer with no operating system yet. On Day 1 you'll install Linux on it.

Today, just make sure you can log in and find it. If you already know Proxmox from the Windows weeks, this takes 1 minute.

---

## 1. Log in to Proxmox

1. On a CS Lab computer, open **Firefox** and go to:
   ```
   https://proxmox.cs.wallawalla.edu:8006
   ```
2. If Firefox warns *"Warning: Potential Security Risk Ahead"*, click **Advanced...** → **Accept the Risk and Continue**. (The server uses a certificate the department made itself. It's safe here.)
3. Log in:
   - **User name:** your CS Lab username (the same one you use to log in to the lab computers)
   - **Password:** your CS Lab password
   - **Realm:** leave it on **CS-LDAP**
   - Click **Login**
4. If a box says **"No valid subscription"**, click **OK**. That's normal.

## 2. Find your VM

5. On the left side you'll see a tree. Expand it until you see your VMs. You have four, one for each operating system in this course:

   | VM name ends in... | What it is |
   |---|---|
   | `-w2025s` | Windows Server 2025 |
   | `-w11d` | Windows 11 |
   | **`-u26.04s`** | **Ubuntu Server 26.04 ← the one for the Linux unit** |
   | `-u26.04d` | Ubuntu Desktop 26.04 |

   Find the one named like `2611 (cptr211-yourusername-u26.04s)`. The number is its **VM ID**.
6. Click it. You should see its **Summary** page.

> ⚠️ **Don't click Start yet.** We'll start it together in class.

## 3. Bring to class

- [ ] You can log in to Proxmox
- [ ] You found your VM and wrote down its **VM ID**: ________

> 😕 **Can't log in, or don't see a VM?** Email your instructor **before** Day 1 with your username, so it can be fixed in time.
