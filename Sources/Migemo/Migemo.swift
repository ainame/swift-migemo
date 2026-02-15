import CMigemoC
import Foundation

public enum MigemoError: Error, Sendable {
    case dictionaryNotFound(path: String)
    case dictionaryLoadFailed(path: String)
    case emptyQuery
    case queryFailed
    case invalidPatternEncoding
}

public final class Migemo {
    private let handle: OpaquePointer

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

    public func expand(_ query: String) throws -> String {
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
    public func compileRegex(_ query: String) throws -> Regex<AnyRegexOutput> {
        try Regex(try expand(query))
    }
}
