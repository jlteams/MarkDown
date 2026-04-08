import Foundation
import cmark_gfm

// Declare the C function for registering GFM extensions
@_silgen_name("cmark_gfm_core_extensions_ensure_registered")
public func cmark_gfm_core_extensions_ensure_registered()

final class MarkdownParser: Sendable {

    // Ensure extensions are registered once
    private static var extensionsRegistered = false
    private static let registrationLock = NSLock()
    
    private static func ensureExtensionsRegistered() {
        registrationLock.lock()
        defer { registrationLock.unlock() }
        
        if !extensionsRegistered {
            cmark_gfm_core_extensions_ensure_registered()
            extensionsRegistered = true
        }
    }

    func parse(_ markdown: String) -> String {
        // Ensure extensions are registered
        Self.ensureExtensionsRegistered()
        
        // Use HARDBREAKS to preserve single newlines
        let options = CMARK_OPT_DEFAULT | CMARK_OPT_HARDBREAKS
        let parser = cmark_parser_new(options)

        // Attach GFM extensions to parser
        let extensions: [String] = ["table", "strikethrough", "tasklist", "autolink"]
        for extName in extensions {
            if let ext = cmark_find_syntax_extension(extName) {
                cmark_parser_attach_syntax_extension(parser, ext)
            }
        }

        // Feed and parse
        markdown.withCString { cString in
            cmark_parser_feed(parser, cString, strlen(cString))
        }

        guard let node = cmark_parser_finish(parser) else {
            cmark_parser_free(parser)
            return ""
        }

        // Get extensions list from parser and render HTML
        let extList = cmark_parser_get_syntax_extensions(parser)
        let html = cmark_render_html(node, options, extList)

        let result = html.map { String(cString: $0) } ?? ""

        // Cleanup
        if let html { free(html) }
        cmark_node_free(node)
        cmark_parser_free(parser)

        return result
    }

    func extractHeadings(from markdown: String) -> [(level: Int, text: String)] {
        var headings: [(level: Int, text: String)] = []
        let lines = markdown.components(separatedBy: .newlines)
        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            if trimmed.hasPrefix("#") {
                var level = 0
                for char in trimmed {
                    if char == "#" { level += 1 } else { break }
                }
                guard (1...6).contains(level) else { continue }
                let text = trimmed.dropFirst(level).trimmingCharacters(in: .whitespaces)
                if !text.isEmpty {
                    headings.append((level, String(text)))
                }
            }
        }
        return headings
    }

    func statistics(for markdown: String) -> (words: Int, lines: Int, characters: Int) {
        let lines = markdown.components(separatedBy: .newlines)
        let lineCount = lines.count
        let charCount = markdown.count
        let wordCount = markdown.split(whereSeparator: { $0.isWhitespace || $0.isNewline }).count
        return (wordCount, lineCount, charCount)
    }
}
