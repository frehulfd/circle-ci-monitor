//
//  WorkflowView.swift
//  CircleCI Monitor
//
//  Created by Don Frehulfer on 1/5/22.
//

import SwiftUI

let dateFormatter = { () -> DateFormatter in
    let formatter = DateFormatter()
    formatter.doesRelativeDateFormatting = true
    formatter.dateStyle = .short
    formatter.timeStyle = .short
    return formatter
}()

struct WorkflowView: View {
    let workflow: Workflow
    let workflowJobs: [WorkflowJob]
    
    @Environment(\.openURL)
    private var openURL
    
    @State
    private var isExpanded = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Button {
                    withAnimation(.easeInOut(duration: 0.15)) {
                        isExpanded.toggle()
                    }
                } label: {
                    HStack(alignment: .firstTextBaseline) {
                        Image(systemName: "arrowtriangle.forward.fill")
                            .rotationEffect(.degrees(isExpanded ? 90 : 0))
                        Text("Workflow: \(workflow.name)")
                            .font(.headline)
                    }
                }
                .buttonStyle(.plain)

                Button {
                    openURL(workflow.url)
                } label: {
                    Image(systemName: "link").foregroundStyle(.tint)
                }
                .buttonStyle(.plain)
                
                Spacer()
                
                Text(workflow.createdAt.formatted(.relative(presentation: .numeric, unitsStyle: .narrow)))
                    .font(.headline)
                    .foregroundColor(.secondary)
            }
            .padding([.top, .bottom], 8)
            
            if isExpanded {
                ForEach(workflowJobs, id: \.id) { job in
                    WorkflowJobView(workflow: workflow,
                                    workflowJob: job)
                    .padding([.bottom], 2)
                    .padding(.leading, 20)
                }
            }
        }
    }
}

struct WorkflowView_Previews: PreviewProvider {
    static var previews: some View {
        WorkflowView(workflow: .fixture(), workflowJobs: [
            .fixture(startedAt: .now.addingTimeInterval(-100), name: "Test part", status: .running)
        ])
    }
}
