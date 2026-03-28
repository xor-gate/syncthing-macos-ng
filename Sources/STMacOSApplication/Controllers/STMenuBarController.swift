import AppKit
import SwiftUI

public class STMenuBarController: NSObject, NSWindowDelegate {
    private var statusItem: NSStatusItem!
    private var webWindow: NSWindow?
    private var dashboardWindow: NSWindow?

    public override init() {
        super.init()

        // 1. Create the Status Item
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "arrow.triangle.2.circlepath", 
                                 accessibilityDescription: "Syncthing")
        }

        // 2. Create the Menu
        let menu = NSMenu()

        let openDashboardItem = NSMenuItem(title: "Open", action: #selector(openDashboard), keyEquivalent: "o")
        openDashboardItem.target = self
        menu.addItem(openDashboardItem)
    
        let openItem = NSMenuItem(title: "Open Web GUI", action: #selector(openWebView), keyEquivalent: "o")
        openItem.target = self
        menu.addItem(openItem)
    
        let settingsItem = NSMenuItem(title: "Settings...", action: #selector(openSettings), keyEquivalent: ",")
        settingsItem.target = self
        menu.addItem(settingsItem)
        menu.addItem(NSMenuItem.separator())
    
        let quitItem = NSMenuItem(title: "Quit Syncthing", action: #selector(quitApp), keyEquivalent: "q")
        quitItem.target = self
        menu.addItem(quitItem)

        //menu.addItem(NSMenuItem.separator())

        // Set the menu to the status item
        // Note: setting .menu automatically handles the click-to-open behavior
        statusItem.menu = menu
    }

    @objc func openWebView() {
        // If the window already exists, just bring it to front
        if let window = webWindow {
            window.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
            return
        }

        // Create a new window containing the STWebView
        let window = NSWindow(
                    contentRect: NSRect(x: 0, y: 0, width: 800, height: 600),
                    styleMask: [.titled, .closable, .miniaturizable, .resizable],
                    backing: .buffered,
                    defer: false
                )
                
       // 3. CRITICAL: Tell AppKit NOT to delete the memory automatically.
       // Swift's ARC will handle the memory instead of the legacy AppKit system.
       window.isReleasedWhenClosed = false
        
        window.delegate = self
        window.center()
        window.title = "Syncthing Web UI"
        window.contentView = NSHostingView(rootView: STWebView())

        self.webWindow = window
        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    public func windowWillClose(_ notification: Notification) {
        webWindow = nil // Clean up the reference so we can recreate it next time
        print("Closing....")
    }
    
    @objc func openSettings() {
        // Logic to show settings
        print("Settings opened")
    }
    
    @objc func openDashboard() {
        // If the window already exists, just bring it to front
        if let window = webWindow {
            window.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
            return
        }

        // Create a new window containing the STWebView
        let window = NSWindow(
                    contentRect: NSRect(x: 0, y: 0, width: 800, height: 600),
                    styleMask: [.titled, .closable, .miniaturizable, .resizable],
                    backing: .buffered,
                    defer: false
                )
                
       // 3. CRITICAL: Tell AppKit NOT to delete the memory automatically.
       // Swift's ARC will handle the memory instead of the legacy AppKit system.
       window.isReleasedWhenClosed = false
        
        window.delegate = self
        window.setFrameAutosaveName("STDashboardWindow")
        window.center()
        window.title = "Syncthing UI"
        window.contentView = NSHostingView(rootView: STDashboardView())

        self.webWindow = window
        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    @objc func quitApp() {
        NSApplication.shared.terminate(nil)
    }
}
