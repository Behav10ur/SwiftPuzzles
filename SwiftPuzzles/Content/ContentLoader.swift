import UIKit

enum ContentError: Error, CustomStringConvertible {
    case fileNotFound
    case decodingFailed(DecodingError)
    case invalid([ContentIssue])

    var description: String {
        switch self {
        case .fileNotFound:
            "content.json is missing from the app bundle"
        case .decodingFailed(let error):
            "content.json cannot be decoded: \(error.readableDescription)"
        case .invalid(let issues):
            "content.json has \(issues.count) issue(s):\n"
                + issues.map { "- \($0)" }.joined(separator: "\n")
        }
    }
}

enum ContentLoader {
    static func load(from bundle: Bundle = .main) throws -> ContentCatalog {
        guard let url = bundle.url(forResource: "content", withExtension: "json") else {
            throw ContentError.fileNotFound
        }
        let data = try Data(contentsOf: url)

        let catalog: ContentCatalog
        do {
            catalog = try JSONDecoder().decode(ContentCatalog.self, from: data)
        } catch let error as DecodingError {
            throw ContentError.decodingFailed(error)
        }

        let issues = ContentValidator.issues(in: catalog) { name in
            UIImage(named: name, in: bundle, with: nil) != nil
        }
        guard issues.isEmpty else {
            throw ContentError.invalid(issues)
        }
        return catalog
    }

    /// Content ships inside the bundle, so a broken file is a developer mistake: fail loudly.
    static func loadOrCrash() -> ContentCatalog {
        do {
            return try load()
        } catch {
            fatalError("\(error)")
        }
    }
}

private extension DecodingError {
    /// "topics[2].docsURL: <reason>" instead of the default dump of coding keys.
    var readableDescription: String {
        let context: Context
        switch self {
        case .typeMismatch(_, let c), .valueNotFound(_, let c), .keyNotFound(_, let c), .dataCorrupted(let c):
            context = c
        @unknown default:
            return String(describing: self)
        }

        let path = context.codingPath.reduce("") { path, key in
            if let index = key.intValue { return path + "[\(index)]" }
            return path.isEmpty ? key.stringValue : path + "." + key.stringValue
        }
        // For malformed JSON the line and column live only in the underlying error.
        let details = (context.underlyingError as NSError?)?.userInfo[NSDebugDescriptionErrorKey] as? String
        return [path.isEmpty ? "root" : path, context.debugDescription, details]
            .compactMap { $0 }
            .joined(separator: ": ")
    }
}
