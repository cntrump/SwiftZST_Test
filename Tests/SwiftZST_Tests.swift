import XCTest
import Foundation
import libzstd

enum SwiftZST_Tests_Error: Error {
    case invalidData
}

final class SwiftZST_Tests: XCTestCase {

    func testZSTD_Compress_and_Decompress() throws {
        var data = Data()

        for _ in 0..<1000 {
            data.append("0123456789".data(using: .utf8)!)
        }

        let output = try ZSTD.compress(data: data)
        let original = try ZSTD.decompress(data: output)

        XCTAssertEqual(original, data)
    }
}
