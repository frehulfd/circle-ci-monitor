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
        
    private var isReloading: Bool {
        reloadCount > 0
    }
    
    @State
    private var rotationAngle: CGFloat = 0
    
    @State
    private var errorMessage: String? = nil
    
    @AppStorage(wrappedValue: false, "OnlyMyPipelines")
    private var onlyMine: Bool
    
    @Environment(\.api)
    private var api
    
    @State
    private var reloadValue: Int = 0
    
    @State
    private var reloadCount = 0
    
    var body: some View {
        Group {
            if pipelines.isEmpty && isReloading {
                ZStack {
                    Rectangle().foregroundColor(.clear)
                    ProgressView()
                }
            } else if let error = errorMessage {
                errorView(error)
            } else {
                pipelinesView
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
        .task(id: reloadValue) {
            await reload()
        }
        .onChange(of: onlyMine, initial: onlyMine) {
            reloadValue += 1
        }
        .onReceive(refreshTimer) { _ in
            reloadValue += 1
        }
    }
    
    private func reload() async {
        print("Starting Reload")
        reloadCount += 1
        errorMessage = nil
        defer {
            reloadCount -= 1
            print("Ended reload")
        }
        
        do {
            pipelines = try await api.getPipelineViewData(onlyMine: onlyMine)
        } catch is CancellationError {
            print("Cancelled")
        } catch let urlError as URLError where urlError.code == .cancelled {
            print("URL Cancelled")
        } catch {
            errorMessage = "\(error)"
            print("ERROR: \(error)")
        }
    }
    
    @ViewBuilder
    private func errorView(_ message: String) -> some View {
        ZStack {
            Rectangle().foregroundColor(.clear)
            VStack {
                Spacer()
                
                GroupBox {
                    VStack {
                        Label("Error Parsing Pipelines", systemImage: "exclamationmark.triangle.fill")
                            .font(.headline)
                            .imageScale(.large)
                        
                        Text(message).font(.body)
                    }
                    .padding()
                }
                .frame(maxWidth: 500)
                
                Spacer()
            }
        }
    }
    
    @ViewBuilder
    private var pipelinesView: some View {
        ScrollView {
            LazyVStack {
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
                                reloadValue += 1
                            }
                        }
                    }
                }
            }
            .padding([.leading, .trailing], 8)
        }
        #if os(macOS)
        .background(Color(nsColor: .controlBackgroundColor))
        #endif
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        PipelinesView()
            .frame(minWidth: 380)
    }
}
