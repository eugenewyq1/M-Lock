#!/usr/bin/swift

import Cocoa

class LockAppDelegate: NSObject, NSApplicationDelegate {
    var iconWindow: NSWindow!
    var monitorTimer: Timer?
    let agentPath = "/Applications/Agent TARS.app"
    let agentProcessName = "Agent TARS"
    let correctPassword = "letmein"

    func applicationDidFinishLaunching(_ notification: Notification) {
        launchAgentIfNotRunning()
        enterKioskMode()
        showUnlockIcon()
        startMonitoring()
    }

    func launchAgentIfNotRunning() {
        let isRunning = NSWorkspace.shared.runningApplications.contains {
            $0.localizedName == agentProcessName
        }
        if !isRunning {
            let url = URL(fileURLWithPath: agentPath)
            let config = NSWorkspace.OpenConfiguration()
            NSWorkspace.shared.openApplication(at: url, configuration: config, completionHandler: nil)

            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                self.maximizeAgentWindow()
            }
        }
    }

    func enterKioskMode() {
        NSApp.setActivationPolicy(.accessory)
        NSApp.presentationOptions = [
            .hideDock,
            .hideMenuBar,
            .disableForceQuit,
            .disableHideApplication,
            .disableProcessSwitching,
            .disableSessionTermination
        ]
    }

    func forceFocusOnAgent() {
        let script = """
        tell application "System Events"
            set frontmost of process "\(agentProcessName)" to true
        end tell
        """
        var error: NSDictionary?
        if let appleScript = NSAppleScript(source: script) {
            appleScript.executeAndReturnError(&error)
        }
    }

    func maximizeAgentWindow() {
        let script = """
        tell application "System Events"
            tell process "\(agentProcessName)"
                try
                    set frontmost to true
                    set value of attribute "AXFullScreen" of window 1 to true
                end try
            end tell
        end tell
        """
        var error: NSDictionary?
        if let appleScript = NSAppleScript(source: script) {
            appleScript.executeAndReturnError(&error)
        }
    }

    func startMonitoring() {
        monitorTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { _ in
            self.forceFocusOnAgent()
            self.maximizeAgentWindow()
            let isRunning = NSWorkspace.shared.runningApplications.contains {
                $0.localizedName == self.agentProcessName
            }
            if !isRunning {
                let url = URL(fileURLWithPath: self.agentPath)
                let config = NSWorkspace.OpenConfiguration()
                NSWorkspace.shared.openApplication(at: url, configuration: config, completionHandler: nil)
            }
        }
    }

    func showUnlockIcon() {
        let iconSize: CGFloat = 60
        guard let screenFrame = NSScreen.main?.frame else { return }
        let iconFrame = NSRect(x: screenFrame.maxX - iconSize - 20, y: screenFrame.midY, width: iconSize, height: iconSize)

        iconWindow = NSWindow(contentRect: iconFrame,
                              styleMask: .borderless,
                              backing: .buffered,
                              defer: false)
        iconWindow.isOpaque = false
        iconWindow.backgroundColor = .clear
        iconWindow.level = .floating
        iconWindow.ignoresMouseEvents = false
        iconWindow.hasShadow = true
        iconWindow.alphaValue = 0.5

        let iconButton = NSButton(frame: NSMakeRect(0, 0, iconSize, iconSize))
        iconButton.bezelStyle = .regularSquare
        iconButton.isBordered = false
        iconButton.image = NSImage(named: NSImage.lockLockedTemplateName)
        iconButton.imageScaling = .scaleProportionallyUpOrDown
        iconButton.target = self
        iconButton.action = #selector(showPasswordPrompt)

        iconWindow.contentView = iconButton
        iconWindow.makeKeyAndOrderFront(nil)
    }

    @objc func showPasswordPrompt() {
        let panel = NSPanel(contentRect: NSMakeRect(0, 0, 400, 160),
                            styleMask: [.titled],
                            backing: .buffered,
                            defer: false)
        panel.title = "Enter Password to Exit"
        panel.level = .mainMenu + 1
        panel.center()
        panel.standardWindowButton(.closeButton)?.isHidden = true
        panel.alphaValue = 0.95

        let view = NSView(frame: panel.contentView!.frame)
        let passwordField = NSSecureTextField(frame: NSRect(x: 50, y: 70, width: 300, height: 24))
        passwordField.placeholderString = "Password"
        view.addSubview(passwordField)

        let unlockButton = NSButton(frame: NSRect(x: 150, y: 20, width: 100, height: 30))
        unlockButton.title = "Unlock"
        unlockButton.bezelStyle = .rounded
        unlockButton.action = #selector(tryToUnlock(_:))
        unlockButton.target = self
        view.addSubview(unlockButton)

        panel.contentView = view
        panel.makeKeyAndOrderFront(nil)
        NSApp.runModal(for: panel)
    }

    @objc func tryToUnlock(_ sender: NSButton) {
        guard let panel = sender.window as? NSPanel,
              let passwordField = panel.contentView?.subviews.first(where: { $0 is NSSecureTextField }) as? NSSecureTextField else { return }

        if passwordField.stringValue == correctPassword {
            NSApp.stopModal()
            panel.orderOut(nil)
            iconWindow.orderOut(nil)
            monitorTimer?.invalidate()
            NSApp.presentationOptions = []
            terminateAgentTARS()
            NSApp.terminate(nil)
        } else {
            passwordField.stringValue = ""
            NSSound.beep()
        }
    }

    func terminateAgentTARS() {
        for app in NSWorkspace.shared.runningApplications {
            if app.localizedName == agentProcessName {
                app.terminate()
            }
        }
    }
}

let app = NSApplication.shared
let delegate = LockAppDelegate()
app.delegate = delegate
app.run()
