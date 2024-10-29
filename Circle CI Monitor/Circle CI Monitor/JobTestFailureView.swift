import Foundation
import SwiftUI

struct JobTestFailureView: View {
    let metadataItem: JobTestMetadata
    
    @State private var showPopover = false
    
    var body: some View {
        Button {
            showPopover = true
        } label: {
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Image(systemName: "exclamationmark.triangle")
                    .foregroundStyle(.red)
                    .imageScale(.large)
                    .font(.body)
                
                Text("\(metadataItem.classname)::\(metadataItem.name)")
            }
            .popover(isPresented: $showPopover) {
                NavigationStack {
                    popoverView(for: metadataItem)
                        .underline(false)
                        .toolbar {
                            ToolbarItem(placement: .primaryAction) {
                                Button("Done", systemImage: "xmark") {
                                    showPopover = false
                                }
                            }
                        }
                    #if !os(macOS)
                        .navigationTitle("Test Failure")
                    #endif
                    
                }
            }
            
            Spacer()
            Text(dateDifferenceFormatter.string(from: TimeInterval(metadataItem.runTime))!)
        }
        .underline()
        .buttonStyle(.plain)
        .foregroundStyle(.primary)
    }
    
    @ViewBuilder
    func popoverView(for metadata: JobTestMetadata) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                popoverLineItem(for: "Class", content: metadata.classname)
                if let file = metadata.file {
                    popoverLineItem(for: "File", content: file)
                }
                popoverLineItem(for: "Source", content: metadata.source)
                popoverLineItem(for: "Name", content: metadata.name)
                popoverLineItem(for: "Result", content: metadata.result)
                popoverLineItem(for: "Message", content: metadata.message)
                popoverLineItem(for: "Run Time", content: dateDifferenceFormatter.string(from: TimeInterval(metadata.runTime))!)
            }
            .padding(12)
            .frame(maxWidth: 800)
        }
    }
    
    @ViewBuilder
    func popoverLineItem(for name: String, content: String) -> some View {
        GroupBox {
            VStack(alignment: .leading) {
                Text(name).font(.caption)
                Text(content).font(.body).textSelection(.enabled).lineLimit(nil)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

private let dateDifferenceFormatter = { () -> DateComponentsFormatter in
    let formatter = DateComponentsFormatter()
    formatter.allowedUnits = [.minute, .second]
    formatter.unitsStyle = .brief
    formatter.zeroFormattingBehavior = [.dropLeading]
    return formatter
}()
