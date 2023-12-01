import Foundation

extension URL {
    static func workflowJobTestMetadata(forSlug slug: String, jobNumber: Int) -> URL {
        .init(string: "https://circleci.com/api/v2/project/\(slug)/\(jobNumber)/tests")!
    }
}

struct JobTestMetadataResponse: Codable {
    let items: [JobTestMetadata]
    let nextPageToken: String?
}

struct JobTestMetadata: Codable, Equatable, Identifiable {
    let message: String
    let source: String
    let runTime: Double
    let file: String?
    let result: String
    let name: String
    let classname: String
    
    var id: String {
        [message, source, runTime.description, file ?? "", result, name, classname].joined()
    }
}
