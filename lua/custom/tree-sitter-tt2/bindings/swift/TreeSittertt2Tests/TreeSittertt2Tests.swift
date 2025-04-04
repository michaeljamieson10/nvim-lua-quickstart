import XCTest
import SwiftTreeSitter
import TreeSitterTt2

final class TreeSitterTt2Tests: XCTestCase {
    func testCanLoadGrammar() throws {
        let parser = Parser()
        let language = Language(language: tree_sitter_tt2())
        XCTAssertNoThrow(try parser.setLanguage(language),
                         "Error loading tt grammar")
    }
}
