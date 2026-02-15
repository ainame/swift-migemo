import Testing
@testable import Migemo

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
        _ = try migemo.compileRegex("kensaku")
    }
}
