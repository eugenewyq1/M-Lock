# MacOS-Agent-App-lock

✅  Launches Agent-TARS

✅  Monitors if it’s frontmost

✅  Enters kiosk mode: disables force quit, Cmd+Tab, dock, and menu bar

✅  Prompts for a password to unlock

✅  Prevents closing or minimizing the password panel

1. Save the Swift script you were given to your home folder:
```bash
nano ~/app_lock.swift
```
1.2 Make it executable:
```bash
chmod +x ~/app_lock.swift
```
2. Create a LaunchAgent
2.1 Go to Your LaunchAgents Folder
In Terminal:
```bash
mkdir -p ~/Library/LaunchAgents
```
```bash
cd ~/Library/LaunchAgents
```

2.2 Create the LaunchAgent .plist
```bash
nano ~/Library/LaunchAgents/com.agentlock.start.plist
```

2.3 Load the LaunchAgent
```bash
launchctl load ~/Library/LaunchAgents/com.agentlock.start.plist
```
