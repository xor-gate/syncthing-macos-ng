import AppKit
import SwiftUI

class STPreferencesWindowController: NSWindowController {
    static let shared = STPreferencesWindowController()

    convenience init() {
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 450, height: 200),
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: false
        )
        window.title = "Preferences"
        window.center()
        window.contentView = NSHostingView(rootView: STPreferencesView())
        
        self.init(window: window)
    }

    func show() {
        self.window?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
}
