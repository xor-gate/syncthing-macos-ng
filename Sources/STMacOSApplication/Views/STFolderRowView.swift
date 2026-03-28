import Foundation
import SwiftUI

struct STFolderRowView: View {
    let folder: FolderConfiguration
    let status: FolderStatus? // Passed in from Parent

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(folder.label.isEmpty ? folder.id : folder.label)
                    .font(.headline)
                Spacer()
                if let state = status?.state {
                    Text(state.rawValue.uppercased())
                        .font(.caption2).bold()
                        .padding(4).background(Color.blue.opacity(0.1))
                }
            }
            
            if let status = status {
                ProgressView(value: status.progressPercent)
                    .scaleEffect(x: 1, y: 0.5, anchor: .center)
                
                Text("\(Int(status.progressPercent))% synchronized")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
    }
}
