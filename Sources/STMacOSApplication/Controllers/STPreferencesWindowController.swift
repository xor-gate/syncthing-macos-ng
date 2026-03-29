import AppKit
import SwiftUI

class STPreferencesWindowController: NSWindowController {
    init(delegate: NSWindowDelegate) {
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 450, height: 300),
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: false
        )
        window.title = "Preferences"
        window.isReleasedWhenClosed = false
        window.center()
        window.contentView = NSHostingView(rootView: STPreferencesView())
        
        super.init(window: window)
        
        // Set the window delegate to SELF
        window.delegate = delegate
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func show() {
        self.window?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
}
