import Foundation
import SwiftUI

struct JobTestMetadataView: View {
    let metadata: [JobTestMetadata]
    
    @State private var detailsItem: JobTestMetadata? = nil
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            ForEach(metadata) { metadataItem in
                JobTestFailureView(metadataItem: metadataItem)
            }
        }
        .font(.subheadline)
    }
}
