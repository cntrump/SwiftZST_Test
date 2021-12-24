import Foundation
import libzstd

public let ZSTDErrorDomain = "ZSTDErrorDomain"

public struct ZSTD {

    public static func compress(data: Data, level: Int = cLevelDefault) throws -> Data {
        guard !data.isEmpty else { return data }

        let srcSize = data.count
        let dstCapacity = ZSTD_compressBound(srcSize)
        var out = Data(count: dstCapacity)

        let result = ZSTD_compress(out.withUnsafeMutableBytes { $0.baseAddress }, dstCapacity,
                                       data.withUnsafeBytes { $0.baseAddress }, srcSize, Int32(level))

        guard !isError(result) else {
            throw NSError(domain: ZSTDErrorDomain, code: result, userInfo: [
                NSLocalizedDescriptionKey: getErrorName(for: result)!
            ])
        }

        return out.dropLast(dstCapacity - result)
    }

    public static func decompress(data: Data) throws -> Data {
        guard !data.isEmpty else { return data }

        let srcSize = data.count
        let dstCapacity = ZSTD_getFrameContentSize(data.withUnsafeBytes { $0.baseAddress }, srcSize)

        guard dstCapacity > 0, !isError(Int(dstCapacity)) else {
            throw NSError(domain: ZSTDErrorDomain, code: Int(dstCapacity), userInfo: [
                NSLocalizedDescriptionKey: getErrorName(for: Int(dstCapacity))!
            ])
        }

        var out = Data(count: Int(dstCapacity))

        let result = ZSTD_decompress(out.withUnsafeMutableBytes { $0.baseAddress }, Int(dstCapacity),
                                         data.withUnsafeBytes { $0.baseAddress }, srcSize)

        guard !isError(result) else {
            throw NSError(domain: ZSTDErrorDomain, code: result, userInfo: [
                NSLocalizedDescriptionKey: getErrorName(for: result)!
            ])
        }

        return out
    }
}

extension ZSTD {

    public static var versionNumber: Int { Int(ZSTD_versionNumber()) }

    public static var versionString: String { String(cString: ZSTD_versionString()) }
}

extension ZSTD {

    public static func isError(_ code: Int) -> Bool {
        return ZSTD_isError(code) != 0
    }

    public static func getErrorName(for code: Int) -> String? {
        guard ZSTD_isError(code) == 1 else {
            return nil
        }

        return String(cString: ZSTD_getErrorName(code))
    }
}

extension ZSTD {

    public static var magicNumber: Int { Int(ZSTD_MAGICNUMBER) }
    public static var magicDictionary: Int { Int(ZSTD_MAGIC_DICTIONARY) }
    public static var magicSkippableStart: Int { Int(ZSTD_MAGIC_SKIPPABLE_START) }
    public static var magicSkippableMask: Int { Int(ZSTD_MAGIC_SKIPPABLE_MASK) }

    public static var blockSizeLogMax: Int { Int(ZSTD_BLOCKSIZELOG_MAX) }
    public static var blockSizeMax: Int { Int(ZSTD_BLOCKSIZE_MAX) }

    public static var cLevelMin: Int { Int(ZSTD_minCLevel()) }
    public static var cLevelMax: Int { Int(ZSTD_maxCLevel()) }
    public static var cLevelDefault: Int { Int(ZSTD_defaultCLevel()) }
}
