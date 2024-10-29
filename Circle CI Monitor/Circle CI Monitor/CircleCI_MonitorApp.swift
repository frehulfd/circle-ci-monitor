//
//  CircleCI_MonitorApp.swift
//  CircleCI Monitor
//
//  Created by Don Frehulfer on 1/5/22.
//

import SwiftUI

@main
struct CircleCI_MonitorApp: App {
    @AppStorage(wrappedValue: "", "APIKey")
    private var apiKey: String
    
    @AppStorage(wrappedValue: "gh/stitchfix/iOSApp", "ProjectSlug")
    private var slug: String
        
    @State
    private var showSettings = false
    var body: some Scene {
        WindowGroup {
            #if os(iOS)
            NavigationStack {
                mainView
                    .toolbar {
                        ToolbarItem(placement: .topBarLeading) {
                            Button("Settings", systemImage: "gear") {
                                showSettings = true
                            }
                        }
                    }
            }
            .sheet(isPresented: $showSettings) {
                NavigationStack {
                    Form {
                        Section("API Key") {
                            Text("To create an API Key log in to CircleCI click your avatar, click \"Personal API Token\", and then create a token.")
                                .font(.subheadline)
                            TextField("API Key", text: $apiKey)
                        }
                        
                        Section("Your project slug") {
                            TextField("Project Slug", text: $slug)
                        }
                    }
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
                            Button("Done") {
                                showSettings = false
                            }
                        }
                    }
                }
            }
            #elseif os(macOS)
            mainView.frame(minWidth: 800, minHeight: 400)
            #endif
        }
        
        #if os(macOS)
        Settings {
            Form {
                Text("To create an API Key log in to CircleCI click your avatar, click \"Personal API Token\", and then create a token.")
                    .font(.subheadline)
                TextField("API Key", text: $apiKey)
                
                Text("Your project slug")
                TextField("Project Slug", text: $slug)
            }
            .padding()
        }
        #endif
    }
    
    @ViewBuilder
    private var mainView: some View {
        if apiKey == "" {
            Rectangle()
                .foregroundColor(.clear)
                .overlay(
                    Text("API key missing!")
                )
        } else if slug == "" {
            Rectangle()
                .foregroundColor(.clear)
                .overlay(
                    Text("Project slug missing!")
                )
        } else {
            PipelinesView()
                .environment(\.api, .init(key: apiKey, projectSlug: slug))
        }
    }
}
