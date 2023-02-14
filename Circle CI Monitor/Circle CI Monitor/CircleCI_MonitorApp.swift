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
        
    var body: some Scene {
        WindowGroup {
            Group {
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
                            Text("API key missing!")
                        )
                } else {
                    PipelinesView()
                        .environment(\.api, .init(key: apiKey, projectSlug: slug))
                }
            }
            .frame(minWidth: 800, minHeight: 400)
        }
        
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
    }
}
