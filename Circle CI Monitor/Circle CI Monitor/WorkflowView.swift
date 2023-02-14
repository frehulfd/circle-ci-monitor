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
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Button {
                    openURL(workflow.url)
                } label: {
                    Label {
                        Text("Workflow: \(workflow.name)")
                            .font(.headline)
                    } icon: {
                        Image(systemName: "chevron.right")
                    }
                    .labelStyle(.iconOnTrailing())
                }
                .buttonStyle(.plain)
                
                Spacer()
                
                Text(workflow.createdAt.formatted(.relative(presentation: .numeric, unitsStyle: .narrow)))
                    .font(.headline)
                    .foregroundColor(.secondary)
            }
            .padding([.top, .bottom], 8)
            
            ForEach(workflowJobs, id: \.id) { job in
                WorkflowJobView(workflow: workflow,
                                workflowJob: job)
                    .padding([.bottom], 2)
            }
        }
    }
}

struct WorkflowView_Previews: PreviewProvider {
    static var previews: some View {
        WorkflowView(workflow: .fixture(), workflowJobs: [])
    }
}
