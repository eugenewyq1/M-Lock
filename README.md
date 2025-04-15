# MacOS-Agent-App-lock

1. Launches Agent-TARS

2. Monitors if it’s frontmost

3. Enters kiosk mode: disables force quit, Cmd+Tab, dock, and menu bar

4. Prompts for a password to unlock

5. Prevents closing or minimizing the password panel



Create a LaunchAgent
1. Go to Your LaunchAgents Folder
In Terminal:

mkdir -p ~/Library/LaunchAgents

cd ~/Library/LaunchAgents
