import Foundation

final class FileManagerService: @unchecked Sendable {
    
    // Chinese encodings
    private static let gbkEncoding = String.Encoding(rawValue: CFStringConvertEncodingToNSStringEncoding(CFStringEncoding(CFStringEncodings.GB_18030_2000.rawValue)))
    private static let gb2312Encoding = String.Encoding(rawValue: CFStringConvertEncodingToNSStringEncoding(CFStringEncoding(CFStringEncodings.GB_2312_80.rawValue)))
    private static let gb18030Encoding = String.Encoding(rawValue: CFStringConvertEncodingToNSStringEncoding(CFStringEncoding(CFStringEncodings.GB_18030_2000.rawValue)))

    enum FileError: LocalizedError {
        case readFailed(URL, Error? = nil)
        case writeFailed(URL, Error? = nil)
        case encodingFailed

        var errorDescription: String? {
            switch self {
            case .readFailed(let url, let underlyingError):
                let baseMessage = "无法读取文件: \(url.lastPathComponent)"
                if let error = underlyingError {
                    return "\(baseMessage)\n错误: \(error.localizedDescription)"
                }
                return baseMessage
            case .writeFailed(let url, let underlyingError):
                let baseMessage = "无法写入文件: \(url.lastPathComponent)"
                if let error = underlyingError {
                    return "\(baseMessage)\n错误: \(error.localizedDescription)"
                }
                return baseMessage
            case .encodingFailed: return "文件编码错误"
            }
        }
    }

    func readContent(from url: URL) throws -> String {
        // Note: Security scope access should be handled by the caller
        // Try multiple encodings
        let encodings: [String.Encoding] = [
            .utf8,
            .utf16,
            Self.gbkEncoding,
            Self.gb2312Encoding,
            Self.gb18030Encoding,
            .ascii,
            .isoLatin1
        ]
        
        for encoding in encodings {
            if let content = try? String(contentsOf: url, encoding: encoding) {
                return content
            }
        }
        
        // If all encodings fail, try with detection
        do {
            let data = try Data(contentsOf: url)
            if let content = String(data: data, encoding: .utf8) {
                return content
            }
            // Last resort: try to detect encoding
            let detectedEncoding = NSString.stringEncoding(for: data, encodingOptions: nil, convertedString: nil, usedLossyConversion: nil)
            if let content = String(data: data, encoding: String.Encoding(rawValue: detectedEncoding)) {
                return content
            }
        } catch {
            throw FileError.readFailed(url, error)
        }
        
        throw FileError.readFailed(url)
    }

    func writeContent(_ content: String, to url: URL) throws {
        // Note: Security scope access should be handled by the caller
        do {
            try content.write(to: url, atomically: true, encoding: .utf8)
        } catch {
            throw FileError.writeFailed(url, error)
        }
    }

    func exportHTML(_ html: String, baseURL: URL) throws -> URL {
        // Note: Security scope access should be handled by the caller
        let fileName = baseURL.deletingPathExtension().lastPathComponent
        let exportURL = baseURL.deletingLastPathComponent().appendingPathComponent("\(fileName).html")
        try html.write(to: exportURL, atomically: true, encoding: .utf8)
        return exportURL
    }
}
