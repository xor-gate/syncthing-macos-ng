import Foundation
import Sparkle

public class STUpdateController: NSObject, ObservableObject {
    private let updaterController: SPUStandardUpdaterController
    
    @Published var canCheckForUpdates = false

    public override init() {
        // SPUStandardUpdaterController provides the default Sparkle UI
        // (the "New version available" window)
        self.updaterController = SPUStandardUpdaterController(startingUpdater: true, updaterDelegate: nil, userDriverDelegate: nil)
        super.init()
        
        // Bind the updater's state to our UI if needed
        self.updaterController.updater.publisher(for: \.canCheckForUpdates)
            .assign(to: &$canCheckForUpdates)
    }

    public func checkForUpdates() {
        updaterController.checkForUpdates(nil)
    }
}
