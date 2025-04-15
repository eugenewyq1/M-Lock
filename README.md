# MacOS-Agent-App-lock

✅  Launches Agent

✅  Monitors if it’s frontmost

✅  Enters kiosk mode: disables force quit, Cmd+Tab, dock, and menu bar and prevents minimizing/closing/exiting the app

✅  Prompts for a password to unlock

✅ locking Swift script runs automatically after login

✅ Monitors and kills all other applications, keeping only Agent-TARS running (optional: Updated with App_lock2.swift)

1. Use Activity Monitor to find PID
Open Activity Monitor from:
```bash
Applications → Utilities → Activity Monitor
```
```bash
See the exact Process ID (PID)
```
1.2 Get the Process Name from PID
 ```bash
ps -p 693 -o comm=
```
1.3 Path name should match the following:
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
To go full kiosk and hide Dock and Menu Bar
```bash
defaults write com.apple.dock autohide -bool true; killall Dock
```
```bash
defaults write NSGlobalDomain _HIHideMenuBar -bool true; killall SystemUIServer
```
