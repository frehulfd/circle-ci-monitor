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
    
    var body: some View {
        TimelineView(.periodic(from: Date(), by: 1)) { _ in
            HStack(alignment: .center, spacing: 8) {
                HStack(alignment: .center, spacing: 8) {
                    Group {
                        switch workflowJob.status {
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
                    .foregroundColor(workflowJob.statusColor)
                    .imageScale(.large)
                    
                    Button {
                        openURL(workflowJob.url(fromWorkflow: workflow))
                    } label: {
                        Label {
                            Text(workflowJob.name)
                        } icon: {
                            Image(systemName: "chevron.right")
                        }
                        .labelStyle(.iconOnTrailing())
                        .font(.subheadline)
                    }
                    .buttonStyle(.plain)
                    
                }
                
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
        }
    }
    
    func timeDifferenceString() -> String? {
        guard let startTime = workflowJob.startedAt else { return nil }
        
        let endTime = workflowJob.stoppedAt ?? Date()
        
        let time = endTime.timeIntervalSince(startTime)
        
        return dateDifferenceFormatter.string(from: time)
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

private extension WorkflowJob {
    var statusColor: Color {
        switch status {
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
