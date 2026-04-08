import Foundation

struct DocumentModel {
    var content: String
    var fileURL: URL?
    var isModified: Bool = false
    var lastSavedContent: String = ""

    var fileName: String {
        fileURL?.lastPathComponent ?? "Untitled"
    }

    init(content: String = "", fileURL: URL? = nil) {
        self.content = content
        self.fileURL = fileURL
        self.lastSavedContent = content
    }

    mutating func updateContent(_ newContent: String) {
        if newContent != content {
            content = newContent
            isModified = newContent != lastSavedContent
        }
    }

    mutating func markAsSaved() {
        lastSavedContent = content
        isModified = false
    }
}
