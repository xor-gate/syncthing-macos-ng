import AppKit
import SwiftUI

import STSwiftLibrary

public class STMenuBarController: NSObject, NSWindowDelegate {
    private var statusItem: NSStatusItem!
    private var webWindow: NSWindow?
    private var dashboardWindow: NSWindow?
    private var preferencesWindowController: STPreferencesWindowController?
    private var client: STAPIClient!

    public init(client: STAPIClient) {
        super.init()

        // 1. Create the Status Item
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "arrow.triangle.2.circlepath", 
                                 accessibilityDescription: "Syncthing")
        }
        
        self.client = client
        
        constructMenu()
    }

    func constructMenu() {
        // 2. Create the Menu
        let menu = NSMenu()

        let openDashboardItem = NSMenuItem(title: "Open", action: #selector(openDashboard), keyEquivalent: "o")
        openDashboardItem.target = self
        menu.addItem(openDashboardItem)
    
        let openItem = NSMenuItem(title: "Open Web GUI", action: #selector(openWebView), keyEquivalent: "o")
        openItem.target = self
        menu.addItem(openItem)
    
        let settingsItem = NSMenuItem(title: "Settings...", action: #selector(openPreferences), keyEquivalent: ",")
        settingsItem.target = self
        menu.addItem(settingsItem)
        menu.addItem(NSMenuItem.separator())
    
        let quitItem = NSMenuItem(title: "Quit Syncthing", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
        menu.addItem(quitItem)

        //menu.addItem(NSMenuItem.separator())
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
        window.title = "Syncthing WebUI"
        window.contentView = NSHostingView(rootView: STWebView(url: client.getBaseURL()))

        self.webWindow = window
        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    @objc public func openPreferences() {
        if preferencesWindowController == nil {
            let controller = STPreferencesWindowController(delegate: self)
            preferencesWindowController = controller
        }
        
        preferencesWindowController?.show()
    }
    
    public func windowWillClose(_ notification: Notification) {
        guard let closingWindow = notification.object as? NSWindow else { return }

        // 1. Check if it's the Preferences window
        if closingWindow == preferencesWindowController?.window {
            print("Cleaning up PreferencesWindowController")
            preferencesWindowController = nil
        }
        
        if closingWindow == webWindow {
            print("Cleaning up webWindow")
            webWindow = nil
        }

        print("Closing....")
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
        window.contentView = NSHostingView(rootView: STDashboardView(client: client))

        self.webWindow = window
        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
}
