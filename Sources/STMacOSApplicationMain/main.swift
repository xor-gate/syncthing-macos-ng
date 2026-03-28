import Cocoa
import SwiftUI

import STMacOSApplication

// 1. Create the Application instance
let app = NSApplication.shared

// 2. Create and assign the Delegate
let delegate = STMacOSApplicationDelegate()
app.delegate = delegate

// 3. Run the App
// Note: This starts the AppKit event loop. SwiftUI's App struct
// isn't used as the entry point here; your Delegate handles the windows.
_ = NSApplicationMain(CommandLine.argc, CommandLine.unsafeArgv)
