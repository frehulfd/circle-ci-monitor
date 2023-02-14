//
//  Workflows.swift
//  CircleCI Monitor
//
//  Created by Don Frehulfer on 1/5/22.
//

import Foundation

extension URL {
    static func workflows(forPipeline id: String) -> URL {
        URL(string: "https://circleci.com/api/v2/pipeline/\(id)/workflow")!
    }
}

struct PipelineWorkflows: Codable {
    let nextPageToken: String?
    let items: [Workflow]
}

struct Workflow: Codable {
    enum Status: String, Codable {
        case success = "success"
        case running = "running"
        case notRun = "not_run"
        case failed = "failed"
        case error = "error"
        case failing = "failing"
        case onHold = "on_hold"
        case canceled = "canceled"
        case unauthorized = "unauthorized"
    }

    let pipelineId: String
    let id: String
    let name: String
    let projectSlug: String
    let status: Status
    let startedBy: String
    let pipelineNumber: Int
    let createdAt: Date
    let stoppedAt: Date?
    
    var url: URL {
        URL(string: "https://app.circleci.com/pipelines/\(projectSlug)/\(pipelineNumber)/workflows/\(id)")!
    }
    
    static func fixture() -> Workflow {
        .init(pipelineId: UUID().uuidString,
              id: UUID().uuidString,
              name: "workflow name",
              projectSlug: "slug",
              status: .running,
              startedBy: UUID().uuidString,
              pipelineNumber: 12345,
              createdAt: Date().addingTimeInterval(-100),
              stoppedAt: nil)
    }
}
