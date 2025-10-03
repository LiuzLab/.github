**installation instructions** + a **tiny tutorial** to get around in WSL once it’s installed.

---

# 🖥️ Part 1: Install WSL (Windows Subsystem for Linux)

### 1. Open PowerShell as Administrator

* Press **Win + X → Windows PowerShell (Admin)**
* Or search **PowerShell** → right-click → *Run as Administrator*

### 2. Install WSL in one command

```powershell
wsl --install
```

✅ This will:

* Enable WSL and Virtual Machine Platform features
* Install **Ubuntu (default Linux distribution)**
* Set WSL2 as the default version

📌 If you’re on **Windows 10** and it errors, run these first:

```powershell
dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart
wsl --set-default-version 2
```

Then install Ubuntu from the [Microsoft Store](https://aka.ms/wslstore).

### 3. Reboot your computer

Required if it asked for restart.

### 4. Launch Ubuntu

* Open **Start Menu → Ubuntu**
* First run: you’ll be asked to create a **Linux username + password** (separate from Windows login).

---

# 🖥️ Part 2: Setup WSL for Daily Use

### 1. Update packages

Inside Ubuntu (the black terminal window):

```bash
sudo apt update && sudo apt upgrade -y
```

### 2. Install tools you need

For your script:

```bash
sudo apt install -y screen openssh-client
```

### 3. Find your Linux home folder from Windows

* Linux home is at:
  `\\wsl$\Ubuntu\home\<your-linux-username>\`
  You can open this in **File Explorer** to copy scripts/files.

---

# 📖 Tiny Tutorial: Using WSL

Here are the basics you’ll use most:

### Navigation

```bash
pwd          # print working directory
ls           # list files
cd myfolder  # change directory
cd ~         # go to home directory
```

### File operations

```bash
nano file.sh   # edit a file
cp a.txt b.txt # copy
mv a.txt b.txt # move/rename
rm a.txt       # delete
```

### Permissions

```bash
chmod +x script.sh   # make script executable
```

### Running commands

```bash
./script.sh -u USER -p 2222   # run your script
```

### SSH

```bash
ssh username@server   # connect to a server
```

---

# 🖥️ Part 3: Using WSL from Windows PowerShell

You don’t always have to open Ubuntu manually. From PowerShell you can run:

```powershell
wsl ls ~
wsl ./skycode.sh -u USERNAME -p 2222
```

That runs Linux commands inside WSL directly.


