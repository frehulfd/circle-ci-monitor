import Foundation
import SwiftUI

struct JobTestMetadataView: View {
    let metadata: [JobTestMetadata]
    
    @State private var detailsItem: JobTestMetadata? = nil
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            ForEach(metadata) { metadataItem in
                Button {
                    detailsItem = metadataItem
                } label: {
                    HStack(alignment: .firstTextBaseline, spacing: 8) {
                        Image(systemName: "exclamationmark.triangle")
                            .foregroundStyle(.red)
                            .imageScale(.large)
                            .font(.body)
                        
                        Text("\(metadataItem.classname)::\(metadataItem.name)")
                    }
                    .popover(isPresented: .init(get: {
                        detailsItem == metadataItem
                    }, set: { isPresented in
                        if !isPresented && detailsItem == metadataItem {
                            detailsItem = nil
                        }
                    }), content: {
                        popoverView(for: metadataItem)
                            .underline(false)
                    })
                    
                    Spacer()
                    Text(dateDifferenceFormatter.string(from: TimeInterval(metadataItem.runTime))!)
                }
                .underline()
                .buttonStyle(.plain)
                .foregroundStyle(.primary)
            }
        }
        .font(.subheadline)
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
