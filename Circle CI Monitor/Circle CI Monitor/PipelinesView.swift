//
//  ContentView.swift
//  CircleCI Monitor
//
//  Created by Don Frehulfer on 1/5/22.
//

import SwiftUI

private let refreshTimer = Timer.publish(every: 10, tolerance: 2, on: .main, in: .default, options: nil).autoconnect()

struct PipelinesView: View {
    
    @State
    private var pipelines: [PipelineViewData] = []
        
    @State
    private var isReloading: Bool = false
    
    @State
    private var rotationAngle: CGFloat = 0
    
    @State
    private var errorMessage: String? = nil
    
    @AppStorage(wrappedValue: false, "OnlyMyPipelines")
    private var onlyMine: Bool
    
    @Environment(\.api)
    private var api
    
    var body: some View {
        Group {
            if pipelines.isEmpty && isReloading {
                ZStack {
                    Rectangle().foregroundColor(.clear)
                    ProgressView()
                }
            } else if let error = errorMessage {
                ZStack {
                    Rectangle().foregroundColor(.clear)
                    VStack {
                        Spacer()
                        
                        GroupBox {
                            VStack {
                                Label("Error Parsing Pipelines", systemImage: "exclamationmark.triangle.fill")
                                    .font(.headline)
                                    .imageScale(.large)
                                
                                Text(error)
                                    .font(.body)
                            }
                            .padding()
                        }
                        .frame(maxWidth: 500)
                        
                        Spacer()
                    }
                }
            } else {
                ScrollView {
                    VStack {
                        ForEach(pipelines, id: \.id) { pipelineViewData in
                            Section {
                                VStack {
                                    ForEach(pipelineViewData.workflows, id: \.id) { workflow in
                                        WorkflowView(workflow: workflow,
                                                     workflowJobs: pipelineViewData.jobsForWorkflows[workflow.id] ?? [])
                                    }
                                }
                            } header: {
                                PipelineView(pipeline: pipelineViewData.pipeline, state: pipelineViewData.pipelineState) {
                                    Task {
                                        try await api.retryFromFailed(forWorkflow: pipelineViewData.workflows.first!.id)
                                        await reload()
                                    }
                                }
                            }
                        }
                    }
                    .padding([.leading, .trailing], 8)
                }
                .background(Color(nsColor: .controlBackgroundColor))
            }
        }
        .toolbar {
            ToolbarItemGroup {
                Button {
                    Task {
                        await reload()
                    }
                } label: {
                    if isReloading {
                        SpinningView(secondsPerRotation: 1) {
                            Image(systemName: "arrow.triangle.2.circlepath")
                        }
                    } else {
                        Image(systemName: "arrow.triangle.2.circlepath")
                    }
                }
                .disabled(isReloading)
                
                Picker(selection: $onlyMine) {
                    Text("Only Mine")
                        .bold()
                        .tag(true)
                        .help("Show only my pipelines")
                    
                    Text("All")
                        .tag(false)
                        .help("Show all pipelines")
                } label: {
                    Text("Test")
                }
                .pickerStyle(.segmented)
                .foregroundColor(.blue)
            }
        }
        .task {
            await reload()
        }
        .onChange(of: onlyMine, perform: { _ in
            Task {
                await reload()
            }
        })
        .onReceive(refreshTimer) { _ in
            Task {
                await reload()
            }
        }
    }
    
    private func reload() async {
        isReloading = true
        errorMessage = nil
        defer { isReloading = false }
        
        do {
            pipelines = try await api.getPipelineViewData(onlyMine: onlyMine)
        } catch {
            errorMessage = "\(error)"
            print("ERROR: \(error)")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        PipelinesView()
            .frame(minWidth: 380)
    }
}
