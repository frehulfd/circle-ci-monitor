//
//  WorkflowJobs.swift
//  CircleCI Monitor
//
//  Created by Don Frehulfer on 1/5/22.
//

import Foundation

extension URL {
    static func workflowJobs(forWorkflow id: String) -> URL {
        URL(string: "https://circleci.com/api/v2/workflow/\(id)/job")!
    }
}

struct WorkflowJobs: Codable {
    let nextPageToken: String?
    let items: [WorkflowJob]
}

struct WorkflowJob: Codable {
    enum Status: String, Codable {
        case success = "success"
        case failed = "failed"
        case blocked = "blocked"
        case canceled = "canceled"
        case running = "running"
        case notRunning = "not_running"
        case queued = "queued"
    }
    let dependencies: [String]
    let jobNumber: Int?
    let id: String
    let startedAt: Date?
    let stoppedAt: Date?
    let name: String
    let projectSlug: String
    let status: Status
    let type: String
    
    func url(fromWorkflow workflow: Workflow) -> URL {
        guard let jobNumber else { return workflow.url }
        
        return workflow
            .url
            .appendingPathComponent("jobs")
            .appendingPathComponent("\(jobNumber)")
    }
    
    static func fixture(dependencies: [String] = [],
                        jobNumber: Int? = nil,
                        id: String = "",
                        startedAt: Date? = nil,
                        stoppedAt: Date? = nil,
                        name: String = "",
                        projectSlug: String = "",
                        status: Status = .queued,
                        type: String = "") -> WorkflowJob {
        .init(dependencies: dependencies,
              jobNumber: jobNumber,
              id: id,
              startedAt: startedAt,
              stoppedAt: stoppedAt,
              name: name,
              projectSlug: projectSlug,
              status: status,
              type: type)
    }
}
