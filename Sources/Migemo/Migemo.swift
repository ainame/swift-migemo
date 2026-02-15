import CMigemoC
import Foundation

public enum MigemoError: Error, Sendable, Equatable {
    case dictionaryNotFound(path: String)
    case dictionaryLoadFailed(path: String)
    case emptyQuery
    case queryFailed
    case invalidPatternEncoding
}

public enum DictionarySource: Sendable {
    case bundled
    case directory(URL)
}

public struct MigemoOptions: Sendable {
    public var dictionary: DictionarySource

    public init(dictionary: DictionarySource = .bundled) {
        self.dictionary = dictionary
    }
}

public final class Migemo {
    private let handle: OpaquePointer

    public convenience init(options: MigemoOptions = .init()) throws {
        try self.init(dictionaryPath: Self.dictionaryPath(for: options.dictionary))
    }

    public init(dictionaryPath: String) throws {
        guard FileManager.default.fileExists(atPath: dictionaryPath) else {
            throw MigemoError.dictionaryNotFound(path: dictionaryPath)
        }
        guard let handle = migemo_open(dictionaryPath) else {
            throw MigemoError.dictionaryLoadFailed(path: dictionaryPath)
        }
        guard migemo_is_enable(handle) != 0 else {
            migemo_close(handle)
            throw MigemoError.dictionaryLoadFailed(path: dictionaryPath)
        }
        self.handle = handle
    }

    deinit {
        migemo_close(handle)
    }

    public func regexPattern(for query: String) throws -> String {
        guard !query.isEmpty else {
            throw MigemoError.emptyQuery
        }

        var queryBytes = Array(query.utf8)
        queryBytes.append(0)

        return try queryBytes.withUnsafeBufferPointer { buffer in
            guard let queryPointer = buffer.baseAddress else {
                throw MigemoError.queryFailed
            }
            guard let result = migemo_query(handle, queryPointer) else {
                throw MigemoError.queryFailed
            }
            defer {
                migemo_release(handle, result)
            }

            let cString = UnsafeRawPointer(result).assumingMemoryBound(to: CChar.self)
            guard let pattern = String(validatingCString: cString) else {
                throw MigemoError.invalidPatternEncoding
            }
            return pattern
        }
    }

    @available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9.0, *)
    public func regex(for query: String) throws -> Regex<AnyRegexOutput> {
        try Regex(try regexPattern(for: query))
    }

    private static func dictionaryPath(for source: DictionarySource) throws -> String {
        switch source {
        case .bundled:
            guard let url = Bundle.module.url(
                forResource: "migemo-dict",
                withExtension: nil
            ) else {
                throw MigemoError.dictionaryNotFound(path: "Bundle.module/migemo-dict")
            }
            return url.path
        case .directory(let directoryURL):
            return directoryURL.appendingPathComponent("migemo-dict").path
        }
    }
}
