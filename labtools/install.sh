#!/bin/bash
# Installs the CPTR 211 "lab" helper tool into /usr/local/bin
# Students run this once (Lab 1, Part F):
#   curl -fsSL https://raw.githubusercontent.com/abuach/cptr211-linux/main/labtools/install.sh | sudo bash

COURSE_URL="https://raw.githubusercontent.com/abuach/cptr211-linux/main/labtools"

if [ "$(id -u)" -ne 0 ]; then
    echo "Please run this with sudo."
    exit 1
fi

echo "Downloading the lab tool..."
if ! curl -fsSL "$COURSE_URL/lab" -o /usr/local/bin/lab; then
    echo "Download failed. Check that the VM can reach the internet:  ping -c 3 ubuntu.com"
    exit 1
fi
chmod 755 /usr/local/bin/lab

# acl (getfacl/setfacl) is used in Lab 5; make sure it is present
if ! command -v getfacl >/dev/null 2>&1; then
    apt-get install -y acl >/dev/null 2>&1
fi

echo
echo "Done! $(/usr/local/bin/lab version) is installed."
echo "Try it now:   lab check 1"
