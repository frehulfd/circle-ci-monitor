//
//  Pipelines.swift
//  CircleCI Monitor
//
//  Created by Don Frehulfer on 1/5/22.
//

import Foundation

extension URL {
    static func pipelines(for slug: String, onlyMine: Bool) -> URL {
        URL(string: "https://circleci.com/api/v2/project/\(slug)/pipeline\(onlyMine ? "/mine" : "")")!
    }
}

struct Pipelines: Codable {
    let nextPageToken: String?
    let items: [Pipeline]
}

struct Pipeline: Codable {
    enum State: String, Codable {
        case created = "created"
        case errored = "errored"
        case setupPending = "setup-pending"
        case setup = "setup"
        case pending = "pending"
    }
    
    struct Trigger: Codable {
        enum TriggerType: String, Codable {
            case explicit = "explicit"
            case api = "api"
            case webhook = "webhook"
            case scheduledPipeline = "scheduled_pipeline"
            case unknown = ""
        }
        
        struct Actor: Codable {
            let login: String
            let avatarUrl: String?
        }
        
        let receivedAt: Date
        let type: TriggerType
        let actor: Actor
    }
    
    struct VersionControl: Codable {
        struct Commit: Codable {
            let body: String
            let subject: String
        }
        
        let originRepositoryUrl: String
        let targetRepositoryUrl: String
        let revision: String
        let providerName: String?
        let commit: Commit?
        let branch: String?
    }
    
    let id: String
    let errors: [String]
    let projectSlug: String
    let updatedAt: Date
    let number: Int
    let state: State
    let createdAt: Date
    let trigger: Trigger
    let vcs: VersionControl
    
    static func fixture() -> Pipeline {
        .init(id: UUID().uuidString,
              errors: [],
              projectSlug: "gh/stitchfix/iOSApp",
              updatedAt: Date(),
              number: 12345,
              state: .created,
              createdAt: Date().addingTimeInterval(-100),
              trigger: .init(receivedAt: Date().addingTimeInterval(-111),
                             type: .webhook,
                             actor: .init(login: "frehulfd", avatarUrl: nil)),
              vcs: .init(originRepositoryUrl: "https://github.com/stitchfix/iOSApp",
                         targetRepositoryUrl: "https://github.com/stitchfix/iOSApp",
                         revision: "9bc8e90d907a9e10abcbdaae757dd8d826d33a08",
                         providerName: "GitHub",
                         commit: .init(body: "", subject: "this is a commit title"),
                         branch: "spike/kept-items-ilf"))
    }
}

