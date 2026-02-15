import Testing
@testable import Migemo
import Foundation

@Test func bundledDictionaryExpand() throws {
    let migemo = try Migemo()
    let pattern = try migemo.expand("kensaku")
    #expect(!pattern.isEmpty)
    #expect(pattern.contains("検索"))
}

@Test func emptyQueryThrows() throws {
    let migemo = try Migemo()
    #expect(throws: MigemoError.emptyQuery) {
        _ = try migemo.expand("")
    }
}

@Test func compileRegexFromExpansion() throws {
    let migemo = try Migemo()
    if #available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9.0, *) {
        _ = try migemo.regex(for: "kensaku")
    }
}

@Test func realExampleNihonContainsKanjiCandidate() throws {
    let migemo = try Migemo()
    let pattern = try migemo.expand("nihon")
    #expect(pattern.contains("日本"))
}

@Test func regexMatchesJapaneseText() throws {
    let migemo = try Migemo()
    if #available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9.0, *) {
        let regex = try migemo.regex(for: "kensaku")
        let text = "これは日本語検索のテストです"
        #expect(text.firstMatch(of: regex) != nil)
    }
}

@Test func customDictionaryDirectoryWorks() throws {
    let fileManager = FileManager.default
    let tempRoot = fileManager.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    let tempDictDir = tempRoot.appendingPathComponent("dict")
    try fileManager.createDirectory(at: tempDictDir, withIntermediateDirectories: true)
    defer { try? fileManager.removeItem(at: tempRoot) }

    let sourceDictDir = dictionaryDirectoryInRepository()
    for fileName in [
        "migemo-dict",
        "roma2hira.dat",
        "hira2kata.dat",
        "han2zen.dat",
        "zen2han.dat",
    ] {
        try fileManager.copyItem(
            at: sourceDictDir.appendingPathComponent(fileName),
            to: tempDictDir.appendingPathComponent(fileName)
        )
    }

    let migemo = try Migemo(options: .init(dictionary: .directory(tempDictDir)))
    let pattern = try migemo.expand("kensaku")
    #expect(pattern.contains("検索"))
}

@Test func missingCustomDictionaryFileThrows() throws {
    let missingDir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    let expectedPath = missingDir.appendingPathComponent("migemo-dict").path
    #expect(throws: MigemoError.dictionaryNotFound(path: expectedPath)) {
        _ = try Migemo(options: .init(dictionary: .directory(missingDir)))
    }
}

@Test func explicitDictionaryPathWorks() throws {
    let dictPath = dictionaryDirectoryInRepository()
        .appendingPathComponent("migemo-dict")
        .path
    let migemo = try Migemo(dictionaryPath: dictPath)
    let pattern = try migemo.expand("tokyo")
    #expect(pattern.contains("東京"))
}

private func dictionaryDirectoryInRepository(filePath: StaticString = #filePath) -> URL {
    URL(fileURLWithPath: "\(filePath)")
        .deletingLastPathComponent()
        .deletingLastPathComponent()
        .deletingLastPathComponent()
        .appendingPathComponent("Sources")
        .appendingPathComponent("Migemo")
        .appendingPathComponent("Resources")
        .appendingPathComponent("dict")
}
