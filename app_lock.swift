#!/usr/bin/swift

import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate {
    var window: NSWindow!
    let correctPassword = "letmein"
    var monitorTimer: Timer?

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Launch Agent-TARS
        launchAgentTARS()

        // Wait 2 seconds to ensure it starts, then monitor
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.monitorTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.checkFrontApp), userInfo: nil, repeats: true)
        }
    }

    func launchAgentTARS() {
        let agentPath = "/Applications/Agent TARS.app/Contents/MacOS/Agent-TARS"
        if FileManager.default.isExecutableFile(atPath: agentPath) {
            let task = Process()
            task.launchPath = agentPath
            task.launch()
        } else {
            print("Agent-TARS not found or not executable.")
        }
    }

    @objc func checkFrontApp() {
        let script = """
        tell application "System Events"
            set frontApp to name of first process whose frontmost is true
        end tell
        return frontApp
        """

        var error: NSDictionary?
        if let scriptObject = NSAppleScript(source: script) {
            let result = scriptObject.executeAndReturnError(&error)

            if let output = result.stringValue, output == "Agent-TARS" {
                monitorTimer?.invalidate()
                enterKioskMode()
                showPasswordPanel()
            }
        }
    }

    func enterKioskMode() {
        NSApp.setActivationPolicy(.accessory) // Hide from Cmd+Tab
        NSApp.presentationOptions = [
            .hideDock,
            .hideMenuBar,
            .disableProcessSwitching,
            .disableForceQuit,
            .disableSessionTermination,
            .disableHideApplication
        ]
    }

    func showPasswordPanel() {
        NSApp.activate(ignoringOtherApps: true)

        let panel = NSPanel(
            contentRect: NSMakeRect(0, 0, 400, 160),
            styleMask: [.titled],
            backing: .buffered,
            defer: false
        )

        panel.title = "Enter Password to Exit"
        panel.level = .mainMenu + 1
        panel.isFloatingPanel = true
        panel.isMovable = false
        panel.center()

        panel.standardWindowButton(.closeButton)?.isHidden = true
        panel.standardWindowButton(.miniaturizeButton)?.isHidden = true
        panel.standardWindowButton(.zoomButton)?.isHidden = true

        let contentView = NSView(frame: panel.contentView!.frame)

        let passwordField = NSSecureTextField(frame: NSRect(x: 50, y: 70, width: 300, height: 24))
        passwordField.placeholderString = "Password"
        contentView.addSubview(passwordField)

        let unlockButton = NSButton(frame: NSRect(x: 150, y: 20, width: 100, height: 30))
        unlockButton.title = "Unlock"
        unlockButton.bezelStyle = .rounded
        unlockButton.target = self
        unlockButton.action = #selector(unlockButtonClicked(_:))
        contentView.addSubview(unlockButton)

        panel.contentView = contentView
        panel.makeKeyAndOrderFront(nil)

        NSApp.runModal(for: panel)
    }

    @objc func unlockButtonClicked(_ sender: NSButton) {
        guard let panel = sender.window as? NSPanel,
              let passwordField = panel.contentView?.subviews.first(where: { $0 is NSSecureTextField }) as? NSSecureTextField else {
            return
        }

        if passwordField.stringValue == correctPassword {
            NSApp.stopModal()
            panel.orderOut(nil)
            NSApp.presentationOptions = []
            NSApp.terminate(nil)
        } else {
            passwordField.stringValue = ""
            NSSound.beep()
        }
    }
}

// MARK: - Run App
let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.run()
