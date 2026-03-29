import SwiftUI
import AppKit

import STSwiftLibrary

public struct STMacOSApplication: App {
    @NSApplicationDelegateAdaptor(STMacOSApplicationDelegate.self) public var appDelegate
    
    public init() {}
    
    public var body: some Scene {
        // Use an empty Settings scene to avoid a default window opening
        Settings { EmptyView() }
    }
}

public class STMacOSApplicationDelegate: NSObject, NSApplicationDelegate, NSWindowDelegate, STDaemonProcessDelegate {
    var onboardingWindow: NSWindow?
    var menuBarController: STMenuBarController?
    var updateController: STUpdateController?
    var cfg: STConfigurationStorage?
    var client: STAPIClient?
    var daemonProcess: STDaemonProcess?

    public override init() {
        super.init()
    }

    public func applicationDidFinishLaunching(_ notification: Notification) {
        updateController = STUpdateController()
        cfg = STConfigurationStorage()
        let result = cfg?.XML.parse()
        if !result! {
            NSLog("Error parsing ST config.xml")
        }

        STLoginItem.addAppAsLoginItem()
        
        if let resourcePath = Bundle.main.resourcePath {
            let executable = (resourcePath as NSString).appendingPathComponent("syncthing/syncthing")
            daemonProcess = STDaemonProcess(path: executable, arguments: "", delegate: self)
            daemonProcess?.launch()
        }
        
        let apiURL = cfg?.XML.gui.apiURL
        let apiKey = cfg?.XML.gui.apiKey
        
        client = STAPIClient(url: apiURL!, apiKey: apiKey!)
        
        menuBarController = STMenuBarController(client: client!)
        
        if cfg?.XML.gui.apiKey.isEmpty != nil {
            showOnboardingWindow()
        } else {
            menuBarController?.openDashboard()
        }
    }
    
    public func applicationWillTerminate(_ notification: Notification) {
        if daemonProcess != nil {
            daemonProcess?.terminate()
        }
    }
    
    public func process(_: STDaemonProcess, isRunning: Bool) {
        NSLog("STDaemonProcess status: \(isRunning)")
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
