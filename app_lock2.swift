import Cocoa

let agentPath = "/Applications/Agent TARS.app"
let agentBundleID = "com.example.Agent-TARS" // Replace with actual bundle ID if needed
let correctPassword = "YourPassword123" // Change this to your actual password

class LockApp: NSObject, NSApplicationDelegate {
    var lockWindow: NSWindow!
    var passwordField: NSSecureTextField!
    var unlockButton: NSButton!
    var iconButton: NSButton!
    var agentRunning = false
    var lockTimer: Timer?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
        launchAgentTARS()
        setupIcon()
        startAppMonitor()
    }

    func launchAgentTARS() {
        if !NSWorkspace.shared.runningApplications.contains(where: { $0.bundleIdentifier == agentBundleID }) {
            NSWorkspace.shared.open(URL(fileURLWithPath: agentPath))
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.fullscreenAgent()
        }
    }

    func fullscreenAgent() {
        let script = """
        tell application "System Events"
            tell application process "Agent TARS"
                try
                    set frontmost to true
                    set value of attribute "AXFullScreen" of window 1 to true
                end try
            end tell
        end tell
        """
        executeAppleScript(script)
    }

    func executeAppleScript(_ script: String) {
        if let appleScript = NSAppleScript(source: script) {
            var errorDict: NSDictionary?
            appleScript.executeAndReturnError(&errorDict)
            if let error = errorDict {
                print("AppleScript Error: \(error)")
            }
        }
    }

    func setupIcon() {
        let screenFrame = NSScreen.main!.frame
        let iconSize: CGFloat = 40

        iconButton = NSButton(frame: NSRect(x: screenFrame.maxX - iconSize - 20, y: screenFrame.midY, width: iconSize, height: iconSize))
        iconButton.title = ""
        iconButton.bezelStyle = .regularSquare
        iconButton.isBordered = false
        iconButton.wantsLayer = true
        iconButton.layer?.backgroundColor = NSColor.gray.withAlphaComponent(0.4).cgColor
        iconButton.layer?.cornerRadius = iconSize / 2
        iconButton.action = #selector(showUnlockPopup)
        iconButton.target = self

        let iconWindow = NSWindow(contentRect: iconButton.frame, styleMask: .borderless, backing: .buffered, defer: false)
        iconWindow.level = .floating
        iconWindow.isOpaque = false
        iconWindow.backgroundColor = .clear
        iconWindow.ignoresMouseEvents = false
        iconWindow.contentView?.addSubview(iconButton)
        iconWindow.makeKeyAndOrderFront(nil)
    }

    @objc func showUnlockPopup() {
        let popupWidth: CGFloat = 300
        let popupHeight: CGFloat = 120
        let screenFrame = NSScreen.main!.frame

        lockWindow = NSWindow(contentRect: NSRect(x: screenFrame.midX - popupWidth/2, y: screenFrame.midY - popupHeight/2, width: popupWidth, height: popupHeight), styleMask: [.titled], backing: .buffered, defer: false)
        lockWindow.level = .floating
        lockWindow.isOpaque = false
        lockWindow.backgroundColor = NSColor.black.withAlphaComponent(0.7)
        lockWindow.title = "Enter Password"

        passwordField = NSSecureTextField(frame: NSRect(x: 40, y: 60, width: 220, height: 24))
        unlockButton = NSButton(frame: NSRect(x: 110, y: 20, width: 80, height: 30))
        unlockButton.title = "Unlock"
        unlockButton.bezelStyle = .rounded
        unlockButton.action = #selector(unlockApp)
        unlockButton.target = self

        let contentView = lockWindow.contentView!
        contentView.addSubview(passwordField)
        contentView.addSubview(unlockButton)
        lockWindow.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    @objc func unlockApp() {
        if passwordField.stringValue == correctPassword {
            print("Unlocked!")
            NSApp.terminate(nil)
        } else {
            passwordField.stringValue = ""
        }
    }

    func startAppMonitor() {
        lockTimer = Timer.scheduledTimer(withTimeInterval: 1.5, repeats: true) { _ in
            self.fullscreenAgent()
            self.enforceAppLock()
        }
    }

    func enforceAppLock() {
        let runningApps = NSWorkspace.shared.runningApplications
        for app in runningApps {
            guard let bundleID = app.bundleIdentifier else { continue }
            if bundleID != agentBundleID && !self.isSystemApp(bundleID: bundleID) {
                print("Killing: \(bundleID)")
                app.forceTerminate()
            }
        }
    }

    func isSystemApp(bundleID: String) -> Bool {
        return bundleID.hasPrefix("com.apple.") || bundleID == Bundle.main.bundleIdentifier
    }
}

let app = NSApplication.shared
let delegate = LockApp()
app.delegate = delegate
app.run()
