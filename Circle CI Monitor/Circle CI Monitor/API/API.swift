//
//  API.swift
//  CircleCI Monitor
//
//  Created by Don Frehulfer on 1/5/22.
//

import Foundation
import SwiftUI

struct APIEnvironmentKey: EnvironmentKey {
    static let defaultValue: API = API(key: "", projectSlug: "")
}

extension EnvironmentValues {
    var api: API {
        get { self[APIEnvironmentKey.self] }
        set { self[APIEnvironmentKey.self] = newValue }
    }
}

struct PipelineViewData {
    enum State {
        case waiting
        case running
        case succeeded
        case failed
        case canceled
    }

    let id: String
    
    let pipeline: Pipeline
    let workflows: [Workflow]
    let jobsForWorkflows: [String: [WorkflowJob]]
    
    var pipelineState: State {
        let jobs = jobsForWorkflows[workflows.first?.id ?? ""] ?? []
        
        if let _ = jobs.first(where: { $0.status == .running }) {
            return .running
        } else if let _ = jobs.first(where: { $0.status == .failed }) {
            return .failed
        } else if jobs.allSatisfy({ $0.status == .success }) {
            return .succeeded
        } else if nil == jobs.first(where: { $0.status == .canceled }) {
            return .waiting
        } else {
            return .canceled
        }
    }
    
    init(pipeline: Pipeline) {
        self.init(pipeline: pipeline, workflows: [], jobs: [:])
    }
    
    init(pipeline: Pipeline, workflows: [Workflow], jobs: [String: [WorkflowJob]]) {
        self.id = pipeline.id
        self.pipeline = pipeline
        self.workflows = workflows
        self.jobsForWorkflows = jobs
    }
}

struct API {
    private static let pipelinesJSONDecoder: JSONDecoder = { () -> JSONDecoder in
        let decoder = JSONDecoder()
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions.insert(.withFractionalSeconds)
        decoder.dateDecodingStrategy = .custom({ decoder in
            let container = try decoder.singleValueContainer()
            let string = try container.decode(String.self)

            if let date = dateFormatter.date(from: string) {
                return date
            }

            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Date expected to be in ISO8601 format")
        })
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()
    private static let otherJSONDecoder = { () -> JSONDecoder in
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder

    }()
    
    private let urlSession: URLSession
    private let slug: String
    
    init(key: String, projectSlug: String) {
        let config = URLSessionConfiguration.default
        config.httpAdditionalHeaders = ["Circle-Token": key]
        
        urlSession = .init(configuration: config)
        slug = projectSlug
    }
    
    func getPipelineViewData(onlyMine: Bool) async throws -> [PipelineViewData] {
        let pipelines = try await getPipelines(onlyMine: onlyMine)
        var viewData: [PipelineViewData] = []
        
        for pipeline in pipelines.items {
            
            guard !Task.isCancelled else { throw CancellationError() }
            
            let workflows = try await getWorkflows(forPipeline: pipeline.id)
            var jobsByWorkflowId: [String: [WorkflowJob]] = [:]
            
            for workflow in workflows.items {
                guard !Task.isCancelled else { throw CancellationError() }
                
                let jobs = try await getWorkflowJobs(forWorkflow: workflow.id)
                
                jobsByWorkflowId[workflow.id] = jobs.items
            }
            
            viewData.append(.init(pipeline: pipeline, workflows: workflows.items, jobs: jobsByWorkflowId))
        }
        
        return viewData
    }
    
    func getPipelines(onlyMine: Bool) async throws -> Pipelines {
        let data = try await urlSession.data(from: .pipelines(for: slug, onlyMine: onlyMine), delegate: nil)
        
        return try Self.pipelinesJSONDecoder.decode(Pipelines.self, from: data.0)
    }
    
    func getWorkflows(forPipeline id: String) async throws -> PipelineWorkflows {
        let data = try await urlSession.data(from: .workflows(forPipeline: id), delegate: nil)
        
        return try Self.otherJSONDecoder.decode(PipelineWorkflows.self, from: data.0)
    }
    
    func getWorkflowJobs(forWorkflow id: String) async throws -> WorkflowJobs {
        let data = try await urlSession.data(from: .workflowJobs(forWorkflow: id), delegate: nil)
        
        return try Self.otherJSONDecoder.decode(WorkflowJobs.self, from: data.0)
    }
    
    func getWorkflowJobTestMetadata(forJobNumber number: Int) async throws -> [JobTestMetadata] {
        let data = try await urlSession.data(from: .workflowJobTestMetadata(forSlug: slug, jobNumber: number))
        
        let response = try Self.otherJSONDecoder.decode(JobTestMetadataResponse.self, from: data.0)
        
        return response.items
    }
    
    func retryFromFailed(forWorkflow id: String) async throws {
        _ = try await urlSession.data(for: .retryWorkflowFromFailed(id: id))
    }
}

extension URLRequest {
    static func retryWorkflowFromFailed(id: String) -> URLRequest {
        let url = URL(string: "https://circleci.com/api/v2/workflow/\(id)/rerun")!
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.httpBody = """
{
    "from_failed": true
}
""".data(using: .utf8)!
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        return urlRequest
    }
}
