https://github.com/user-attachments/assets/99c4c52f-a317-43cc-870f-202d04851c51

# M-Lock
First MacOS-Agent-App-lock powered by swift®

✅  Launches Agent

✅  Monitors if it’s frontmost

✅  Enters kiosk mode: disables force quit, Cmd+Tab, dock, and menu bar and prevents minimizing/closing/exiting the app

✅  Prompts for a password to unlock

✅ locking Swift script runs automatically after login

# ⚠️ kazel please read: MacOS environment was tested on a 1 core 2 thread CPU (Intel Celeron 3965U equivalent- used in Ultra-low-end laptops and small form-factor PCs) hence the slow application loading speed from the launch agent in the video
# For better performance please use a MacOS machine with more cores 
Set automatic login on MacOS
```bash
Disable FileVault first
```
```bash
Open System Settings
```
```bash
Go to Users & Groups
```
```bash
Click the Lock icon to authenticate as admin
```
```bash
Click Login Option
```
```bash
Set:

Automatic Login: Select your user account

Enter your user password
```
Go to accessbilities and allow terminal, swift, agent tars permissions

1. Use Activity Monitor to find PID
Open Activity Monitor from:
```bash
Applications → Utilities → Activity Monitor
```
```bash
See the exact Process ID (PID)
```
1.1 Get the Process Name from PID
 ```bash
ps -p 693 -o comm=
```
1.2 Path name should match the following:
 ```bash
/Applications/Agent TARS.app/Contents/MacOS/Agent-TARS
```
2. Install Command Line Tools for Swift compiler and macOS frameworks:
```bash
xcode-select --install
```
2.1. Save the Swift script you were given to your home folder:
```bash
nano ~/app_lock.swift
```
2.2 Make it executable:
```bash
chmod +x ~/app_lock.swift
```
3. Create a LaunchAgent

3.1 Go to Your LaunchAgents Folder
In Terminal:
```bash
mkdir -p ~/Library/LaunchAgents
```
```bash
cd ~/Library/LaunchAgents
```

3.2 Create the LaunchAgent .plist
```bash
nano ~/Library/LaunchAgents/com.agentlock.start.plist
```
```bash
Replace YOUR_USERNAME with your actual macOS username
```
3.3 Load the LaunchAgent
```bash
launchctl load ~/Library/LaunchAgents/com.agentlock.start.plist
```
Run Script:
```bash
swift ~/app_lock.swift
```

Troubleshooting:

when encountering the following:
```bash
/Users/test/app_lock.swift:67:1: error: insufficient indentation of line in multi-line string literal
true
^
/Users/test/app_lock.swift:71:1: note: should match space here
        """
^
/Users/test/app_lock.swift:67:1: note: change indentation of this line to match closing delimiter
true
^
```
the issue is at maximizeAgentWindow() function
