import AppKit

extension Notification.Name {
    static let insertMarkdown = Notification.Name("insertMarkdown")
}

// MARK: - Toolbar Insert Handler

extension NSTextView {

    func handleToolbarInsert(_ notification: Notification) {
        guard let wrapper = notification.object as? String else { return }

        let selectedRange = self.selectedRange()
        let selectedText = (self.string as NSString).substring(with: selectedRange)

        let replacement: String
        var cursorOffset = 0

        switch wrapper {
        case "heading":
            replacement = "## \(selectedText)"
            cursorOffset = selectedText.isEmpty ? 3 : replacement.count

        case "bullet":
            if selectedText.isEmpty {
                replacement = "- "
                cursorOffset = 2
            } else {
                let lines = selectedText.components(separatedBy: .newlines)
                replacement = lines.map { "- \($0)" }.joined(separator: "\n")
                cursorOffset = replacement.count
            }

        case "numbered":
            if selectedText.isEmpty {
                replacement = "1. "
                cursorOffset = 3
            } else {
                let lines = selectedText.components(separatedBy: .newlines)
                replacement = lines.enumerated().map { "\($0.offset + 1). \($0.element)" }.joined(separator: "\n")
                cursorOffset = replacement.count
            }

        case "task":
            if selectedText.isEmpty {
                replacement = "- [ ] "
                cursorOffset = 6
            } else {
                let lines = selectedText.components(separatedBy: .newlines)
                replacement = lines.map { "- [ ] \($0)" }.joined(separator: "\n")
                cursorOffset = replacement.count
            }

        case "quote":
            if selectedText.isEmpty {
                replacement = "> "
                cursorOffset = 2
            } else {
                let lines = selectedText.components(separatedBy: .newlines)
                replacement = lines.map { "> \($0)" }.joined(separator: "\n")
                cursorOffset = replacement.count
            }

        case "codeblock":
            if selectedRange.length == 0 {
                replacement = "```\n\n```"
                cursorOffset = 4
            } else {
                replacement = "```\n\(selectedText)\n```"
                cursorOffset = replacement.count
            }

        case "hr":
            replacement = "\n---\n"
            cursorOffset = replacement.count

        case "**":
            replacement = "**\(selectedText)**"
            cursorOffset = selectedText.isEmpty ? 2 : replacement.count

        case "*":
            replacement = "*\(selectedText)*"
            cursorOffset = selectedText.isEmpty ? 1 : replacement.count

        case "~~":
            replacement = "~~\(selectedText)~~"
            cursorOffset = selectedText.isEmpty ? 2 : replacement.count

        case "[]()":
            replacement = "[\(selectedText)]()"
            cursorOffset = selectedText.isEmpty ? 1 : replacement.count - 1

        case "`":
            replacement = "`\(selectedText)`"
            cursorOffset = selectedText.isEmpty ? 1 : replacement.count

        default:
            return
        }

        self.textStorage?.beginEditing()
        replaceCharacters(in: selectedRange, with: replacement)

        let newRange = NSRange(
            location: selectedRange.location + cursorOffset,
            length: 0
        )
        setSelectedRange(newRange)
        self.textStorage?.endEditing()
        self.window?.makeFirstResponder(self)
    }
}
