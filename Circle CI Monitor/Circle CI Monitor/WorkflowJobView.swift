//
//  WorkflowJobView.swift
//  CircleCI Monitor
//
//  Created by Don Frehulfer on 1/5/22.
//

import SwiftUI

private let dateDifferenceFormatter = { () -> DateComponentsFormatter in
    let formatter = DateComponentsFormatter()
    formatter.allowedUnits = [.minute, .second]
    formatter.unitsStyle = .brief
    formatter.zeroFormattingBehavior = [.dropLeading]
    return formatter
}()

struct WorkflowJobView: View {
    let workflow: Workflow
    let workflowJob: WorkflowJob
    
    @Environment(\.openURL)
    private var openURL
    
    @Environment(\.api)
    private var api
    
    @State private var isExpanded: Bool = false
    @State private var isLoading: Bool = false
    @State private var metadata: [JobTestMetadata] = []
    @State private var hasNoFailures: Bool = false
    
    @State private var errorMessage: String? = nil
    
    var body: some View {
        TimelineView(.periodic(from: Date(), by: 1)) { _ in
            VStack(alignment: .leading, spacing: 4) {
                HStack(alignment: .center, spacing: 8) {
                    WorkflowJobStatusImageView(status: workflowJob.status)
                    
                    Button {
                        if metadata.isEmpty && !hasNoFailures {
                            loadMetadata()
                        } else {
                            withAnimation {
                                isExpanded.toggle()
                            }
                        }
                    } label: {
                        Label {
                            Text(workflowJob.name)
                        } icon: {
                            if isLoading {
                                ProgressView().controlSize(.mini)
                            } else {
                                Image(systemName: "chevron.right")
                                    .rotationEffect(.degrees(isExpanded ? 90 : 0))
                            }
                        }
                        .labelStyle(.iconOnTrailing())
                        .font(.subheadline)
                    }
                    .buttonStyle(.plain)
                    
                    Spacer()
                    
                    Group {
                        if let time = timeDifferenceString() {
                            Text(time)
                        } else if workflowJob.status == .canceled {
                            Text("Canceled")
                        }
                    }
                    .font(.subheadline.monospacedDigit())
                }
                
                if (!metadata.isEmpty || hasNoFailures) && isExpanded {
                    Group {
                        if !metadata.isEmpty {
                            JobTestMetadataView(metadata: metadata)
                        }
                        
                        if hasNoFailures {
                            Text("No failures in job! 🎉").font(.subheadline)
                        }
                    }
                    .transition(.opacity)
                }
            }
        }
        .alert("Error Loading Tests Metadata", isPresented: .init(get: {
            errorMessage != nil
        }, set: { isShown in
            if !isShown {
                errorMessage = nil
            }
        })) {
            Text("OK")
        } message: {
            Text(errorMessage ?? "Failed to load")
        }

    }
    
    func timeDifferenceString() -> String? {
        guard let startTime = workflowJob.startedAt else { return nil }
        
        let endTime = workflowJob.stoppedAt ?? Date()
        
        let time = endTime.timeIntervalSince(startTime)
        
        return dateDifferenceFormatter.string(from: time)
    }
    
    func loadMetadata() {
        Task {
            guard let number = workflowJob.jobNumber else {
                return
            }
            isLoading = true
            do {
                let result = try await api.getWorkflowJobTestMetadata(forJobNumber: number)
                
                metadata = result.filter({ $0.result == "failure" })
                hasNoFailures = metadata.isEmpty
                withAnimation {
                    isExpanded = true
                }
            } catch {
                errorMessage = error.localizedDescription
            }
            isLoading = false
        }

    }
}

struct WorkflowJobView_Previews: PreviewProvider {
    static var previews: some View {
        WorkflowJobView(
            workflow: .fixture(),
            workflowJob: .fixture(
            startedAt: Date().addingTimeInterval(-30),
            name: "Unit Tests",
            status: .running))
    }
}

private extension WorkflowJob.Status {
    var statusColor: Color {
        switch self {
        case .success:
            return .green
        case .failed:
            return .red
        case .blocked, .queued, .notRunning:
            return .secondary
        case .canceled:
            return .gray
        case .running:
            return .blue
        }
    }
}

private struct WorkflowJobStatusImageView: View {
    let status: WorkflowJob.Status
    
    var body: some View {
        Group {
            switch status {
            case .running:
                SpinningView(secondsPerRotation: 1) {
                    Image(systemName: "arrow.triangle.2.circlepath.circle.fill")
                }
            case .notRunning:
                Image(systemName: "pause.circle.fill")
            case .success:
                Image(systemName: "checkmark.circle.fill")
            case .failed:
                Image(systemName: "x.circle.fill")
            case .blocked, .queued:
                Image(systemName: "circle.dashed")
            case .canceled:
                Image(systemName: "x.circle.fill")
            }
        }
        .foregroundColor(status.statusColor)
        .imageScale(.large)
    }
}
