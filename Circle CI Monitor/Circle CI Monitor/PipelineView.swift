//
//  PipelineView.swift
//  CircleCI Monitor
//
//  Created by Don Frehulfer on 1/5/22.
//

import SwiftUI

struct PipelineView: View {
    let pipeline: Pipeline
    let state: PipelineViewData.State
    let retry: () -> Void
    
    @Environment(\.openURL)
    private var openURL
        
    var body: some View {
        VStack {
            Divider()
            
            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        avatarImage
                            .frame(width: 30, height: 30)
                            .help(pipeline.trigger.actor.login)
                        
                        branchName
                    }
                    
                    revisionLink
                }
                .labelStyle(.iconOnTrailing(spacing: 4))
                .foregroundColor(.primary)
                .lineLimit(nil)
                
                Spacer()
                
                #if os(macOS)
                retryButton
                statusCapsule
                #endif
                
                VStack {
                    projectSlug
                    pipelineNumber
                    #if os(iOS)
                    statusCapsule
                    retryButton
                    #endif
                }
            }
            .padding([.top, .bottom], 8)
            
            Divider()
        }
    }
    
    @ViewBuilder
    private var avatarImage: some View {
        if let urlString = pipeline.trigger.actor.avatarUrl,
           let url = URL(string: urlString) {
            AsyncImage(url: url) { image in
                image
                    .resizable()
                    .aspectRatio(1, contentMode: .fill)
                    .clipShape(Circle())
            } placeholder: {
                Circle()
                    .foregroundColor(.secondary)
            }
            
        } else {
            Circle()
                .foregroundColor(.secondary)
                .overlay(Image(systemName: "person.fill").foregroundColor(.primary))
        }
    }
    
    @ViewBuilder
    private var branchName: some View {
        Text(pipeline.vcs.branch ?? "No Branch")
    }
    
    @ViewBuilder
    private var revisionLink: some View {
        Button {
            openURL(pipeline.vcs.commitURL)
        } label: {
            Label {
                if let commit = pipeline.vcs.commit {
                    (Text(pipeline.vcs.revision.prefix(6))
                        .font(.subheadline.bold()) + Text(" ") +
                    Text(commit.subject)
                        .font(.subheadline))
                        .underline()
                } else {
                    Text(pipeline.vcs.revision.prefix(6))
                        .font(.subheadline.bold())
                        .underline()
                }
            } icon: {
                Image(systemName: "chevron.right")
            }
        }
        .buttonStyle(.plain)
    }
    
    @ViewBuilder
    private var projectSlug: some View {
        Text(pipeline.projectSlug.components(separatedBy: "/").last ?? "").font(.headline)
    }
    
    @ViewBuilder
    private var pipelineNumber: some View {
        Text("# \(pipeline.number)")
            .font(.subheadline)
            .foregroundColor(.secondary)
    }
    
    @ViewBuilder
    private var statusCapsule: some View {
        Label {
            Text(state.displayText)
        } icon: {
            state.icon.imageScale(.large)
        }
#if os(iOS)
        .font(.caption2)
        .padding(6)
#elseif os(macOS)
        .font(.body)
        .padding(8)
#endif
        .foregroundColor(.white)
        .background(Capsule().foregroundColor(state.capsuleColor))
    }
    
    @ViewBuilder
    private var retryButton: some View {
        if state == .failed {
            PipelineRetryButton(action: retry)
        }
    }
}

extension PipelineViewData.State {
    var displayText: String {
        switch self {
        case .waiting:
            return "Waiting"
        case .running:
            return "Running"
        case .succeeded:
            return "Succeeded"
        case .failed:
            return "Failed"
        case .canceled:
            return "Canceled"
        }
    }
    
    var capsuleColor: Color {
        switch self {
        case .waiting, .canceled:
            return .gray
        case .running:
            return .blue
        case .succeeded:
            return .green
        case .failed:
            return .red
        }
    }
    
    @ViewBuilder
    var icon: some View {
        switch self {
        case .waiting, .canceled:
            Image(systemName: "circle.dashed")
        case .running:
            SpinningView(secondsPerRotation: 1) {
                Image(systemName: "arrow.triangle.2.circlepath")
            }
        case .succeeded:
            Image(systemName: "checkmark")
        case .failed:
            Image(systemName: "xmark")
        }
    }
}

struct PipelineView_Previews: PreviewProvider {
    static var previews: some View {
        PipelineView(pipeline: Pipeline.fixture(), state: .running) { }
            .previewDisplayName("Running")
        PipelineView(pipeline: Pipeline.fixture(), state: .waiting) { }
            .previewDisplayName("Waiting")
        PipelineView(pipeline: Pipeline.fixture(), state: .succeeded) { }
            .previewDisplayName("Success")
        PipelineView(pipeline: Pipeline.fixture(), state: .failed) { }
            .previewDisplayName("Failed")
    }
}

extension LabelStyle where Self == LabelIconOnRightStyle {
    static func iconOnTrailing(alignment: VerticalAlignment = .center, spacing: CGFloat = 8) -> LabelIconOnRightStyle {
        LabelIconOnRightStyle(alignment: alignment, spacing: spacing)
    }
}

struct LabelIconOnRightStyle: LabelStyle {
    let alignment: VerticalAlignment
    let spacing: CGFloat
    
    init(alignment: VerticalAlignment, spacing: CGFloat) {
        self.alignment = alignment
        self.spacing = spacing
    }
    
    func makeBody(configuration: Configuration) -> some View {
        HStack(alignment: alignment, spacing: spacing) {
            configuration.title
            configuration.icon
        }
    }
}

private extension Pipeline.VersionControl {
    var commitURL: URL {
        return URL(string: originRepositoryUrl + "/commit/\(revision)")!
    }
}
