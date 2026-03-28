import Foundation
import SwiftUI

import STSwiftLibrary

public struct STDashboardView: View {
    @StateObject private var viewModel: STDashboardViewModel

    // Manual initializer to bridge the gap
    public init(client: STAPIClient) {
        // We use _viewModel to initialize the StateObject wrapper itself
        self._viewModel = StateObject(wrappedValue: STDashboardViewModel(client: client))
    }
    
    public var body: some View {
        NavigationView {
            List {
                systemStatusSection
                folderListSection
            }
            .navigationTitle("Syncthing")
            .onAppear { viewModel.startMonitoring() }
        }
    }

    private var systemStatusSection: some View {
        Section("System Status") {
            if let status = viewModel.systemStatus {
                HStack {
                    Text("Device ID")
                    Spacer()
                    Text(status.myID)
                        .foregroundColor(.secondary)
                        .font(.system(.body, design: .monospaced))
                }
            }
        }
    }

    private var folderListSection: some View {
        Section("Folders") {
            ForEach(viewModel.folders) { folder in
                // Explicitly pass the status from the dictionary
                STFolderRowView(
                    folder: folder,
                    status: viewModel.folderStatuses[folder.id]
                )
            }
        }
    }
    
    private func formatData(_ data: [String: AnyCodable]) -> String {
        data.keys.joined(separator: ", ")
    }
}

@MainActor
public class STDashboardViewModel: ObservableObject {
    @Published var systemStatus: SystemStatus?
    @Published var folders: [FolderConfiguration] = []
    @Published var folderStatuses: [String: FolderStatus] = [:] // Key: Folder ID
    
    private var client: STAPIClient
    
    public init(client: STAPIClient) {
        self.client = client
    }

    func startMonitoring() {
        Task {
            // 1. Initial Load
            self.systemStatus = (try? await client.getSystemStatus()) ?? nil
            
            self.folders = (try? await client.getFolders()) ?? []
            for folder in folders {
                await refreshFolderStatus(id: folder.id)
            }

            // 2. Listen for Events
            for try await event in client.eventStream() {
                handleEvent(event)
            }
        }
    }
    
    private func handleEvent(_ event: SyncthingEvent) {
        // When a folder changes, Syncthing emits a "FolderSummary" or "FolderCompletion"
        if event.type == EventType.folderSummary || event.type == EventType.folderCompletion {
            if let folderID = event.data?["folder"]?.value as? String {
                Task { await refreshFolderStatus(id: folderID) }
            }
        }
    }

    func refreshFolderStatus(id: String) async {
        if let status = try? await client.getFolderStatus(id: id) {
            self.folderStatuses[id] = status
        }
    }
}

#if UNDEF
struct STDashboardView_Previews: PreviewProvider {
    static var previews: some View {
        STDashboardView()
    }
}
#endif
