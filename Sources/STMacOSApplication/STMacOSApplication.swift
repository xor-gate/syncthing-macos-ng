import SwiftUI
import AppKit

import STSwiftLibrary

@main
struct STMacOSApplication: App {
    @NSApplicationDelegateAdaptor(STMacOSApplicationDelegate.self) var appDelegate
    
    var body: some Scene {
        // Use an empty Settings scene to avoid a default window opening
        Settings { EmptyView() }
    }
}

class STMacOSApplicationDelegate: NSObject, NSApplicationDelegate, NSWindowDelegate {
    var onboardingWindow: NSWindow?
    var menuBarController: STMenuBarController?
    var updateController: STUpdateController?
    //var configuration = STConfigurationStorage()

    public override init() {
        super.init()
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        menuBarController = STMenuBarController()
        updateController = STUpdateController()

        //if configuration.apiKey.isEmpty {
            showOnboardingWindow()
        //} else {
        //    menuBarController?.openDashboard()
        //}
    }
    
    func showOnboardingWindow() {
            // 1. Create the SwiftUI view
            let onboardingView = STOnboardingView()

            // 2. Create a Hosting Controller to wrap the SwiftUI view
            let hostingController = NSHostingController(rootView: onboardingView.frame(width: 600, height: 600))

            // 3. Create the NSWindow
            let window = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 600, height: 600),
                styleMask: [.titled, .closable, .fullSizeContentView],
                backing: .buffered,
                defer: false
            )
            
            window.delegate = self
            window.center()
            window.contentViewController = hostingController
            window.isReleasedWhenClosed = false // Important for memory management
            window.title = "Welcome to Syncthing"
            
            // 4. Show the window
            self.onboardingWindow = window
            window.makeKeyAndOrderFront(nil)
            
            // 5. Bring app to front (ensure the window isn't hidden behind Xcode)
            NSApp.activate(ignoringOtherApps: true)
        }
}
