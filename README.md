# MacOS-Agent-App-lock

✅  Launches Agent-TARS

✅  Monitors if it’s frontmost

✅  Enters kiosk mode: disables force quit, Cmd+Tab, dock, and menu bar

✅  Prompts for a password to unlock

✅  Prevents closing or minimizing the password panel



Create a LaunchAgent
1. Go to Your LaunchAgents Folder
In Terminal:

mkdir -p ~/Library/LaunchAgents

cd ~/Library/LaunchAgents


2. Create the LaunchAgent .plist

nano ~/Library/LaunchAgents/com.agentlock.start.plist


3. Load the LaunchAgent

launchctl load ~/Library/LaunchAgents/com.agentlock.start.plist
