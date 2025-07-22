# Rclone (Server ↔ Onedrive)

This tutorial helps in copying stuff from a headless machine ( a server or computer without screen) to your Onedrive folders

One time setup Step 1 : Install rclone on your laptop or a computer that has screen (You will need this in the next)

```bash
Steps to install on windows : https://rclone.org/install/#windows

Steps to install on mac : https://rclone.org/install/#macos

Already available on skyriver : module load rclone
```

One time setup Step 2 : Now on the server you will setup an end point for your onedrive

```bash
https://rclone.org/onedrive/#configuration
```

Copy Data Step 3: Assuming your rclone config name for your onedrive is 
”my_one_drive“ and name of folder in your Onedrive to which you want to copy data is “backup”

```bash
rclone copy /home/source my_one_drive:backup
```

(If rclone command doesn’t work on other server, ask your admin for a global installation)
