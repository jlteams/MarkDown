import SwiftUI
import Combine
import UniformTypeIdentifiers

final class EditorViewModel: ObservableObject {

    @Published var document: DocumentModel
    @Published var htmlContent: String = ""
    @Published var viewMode: ViewMode
    @Published var editorTheme: EditorTheme
    @Published var fontSize: CGFloat
    @Published var isShowingOpenPanel = false
    @Published var isShowingSavePanel = false
    @Published var isShowingExportPanel = false
    @Published var alertMessage: AlertMessage?
    @Published var recentFiles: [URL] = []

    let parser = MarkdownParser()
    let fileManager = FileManagerService()
    let recentFilesManager = RecentFilesManager()

    private var parseWorkItem: DispatchWorkItem?

    struct AlertMessage: Identifiable {
        let id = UUID()
        let title: String
        let message: String
    }

    var windowTitle: String {
        "\(document.fileName)\(document.isModified ? " ●" : "") — MarkDown"
    }

    init() {
        let themeStr = UserDefaults.standard.string(forKey: "editorTheme") ?? "system"
        let resolvedTheme = EditorTheme(rawValue: themeStr) ?? .system
        let modeStr = UserDefaults.standard.string(forKey: "viewMode") ?? "split"
        let resolvedMode = ViewMode(rawValue: modeStr) ?? .splitView
        var resolvedSize = UserDefaults.standard.double(forKey: "editorFontSize")
        if resolvedSize == 0 { resolvedSize = 14 }

        self.document = DocumentModel()
        self.htmlContent = ""
        self.viewMode = resolvedMode
        self.editorTheme = resolvedTheme
        self.fontSize = resolvedSize
        self.isShowingOpenPanel = false
        self.isShowingSavePanel = false
        self.isShowingExportPanel = false
        self.alertMessage = nil
        self.recentFiles = recentFilesManager.recentFiles
        print("🚀 EditorViewModel initialized with \(recentFiles.count) recent files")
    }

    func updateMarkdownContent(_ content: String) {
        document.updateContent(content)
        // Parse immediately for real-time preview
        htmlContent = parser.parse(content)
    }

    // MARK: - File Operations

    func newDocument() {
        document = DocumentModel()
        htmlContent = ""
    }

    func openDocument() {
        isShowingOpenPanel = true
    }

    func openFile(at url: URL) {
        print("📂 Opening file: \(url.lastPathComponent)")
        
        // Start accessing security-scoped resource BEFORE any operations
        let didStartAccessing = url.startAccessingSecurityScopedResource()
        print("🔐 Started accessing security scope: \(didStartAccessing)")
        
        defer {
            if didStartAccessing {
                url.stopAccessingSecurityScopedResource()
                print("🔐 Stopped accessing security scope")
            }
        }
        
        // Check if file exists
        guard FileManager.default.fileExists(atPath: url.path) else {
            print("❌ File does not exist: \(url.path)")
            alertMessage = AlertMessage(title: "打开失败", message: "文件不存在: \(url.lastPathComponent)")
            recentFilesManager.removeFile(url)
            recentFiles = recentFilesManager.recentFiles
            return
        }
        
        do {
            let content = try fileManager.readContent(from: url)
            document = DocumentModel(content: content, fileURL: url)
            htmlContent = parser.parse(content)
            
            // Create bookmark while we have security scope access
            recentFilesManager.addFile(url)
            recentFiles = recentFilesManager.recentFiles
            
            print("✅ File opened successfully. Recent files: \(recentFiles.count)")
        } catch {
            print("❌ Failed to open file: \(error)")
            alertMessage = AlertMessage(title: "打开失败", message: error.localizedDescription)
        }
    }

    func saveDocument() {
        print("💾 saveDocument called")
        
        guard let url = document.fileURL else {
            print("⚠️ No file URL, showing save panel")
            saveAsDocument()
            return
        }
        
        print("💾 Saving document: \(url.lastPathComponent)")
        
        // Start accessing security-scoped resource
        let didStartAccessing = url.startAccessingSecurityScopedResource()
        print("🔐 Started accessing security scope: \(didStartAccessing)")
        
        defer {
            if didStartAccessing {
                url.stopAccessingSecurityScopedResource()
                print("🔐 Stopped accessing security scope")
            }
        }
        
        do {
            try fileManager.writeContent(document.content, to: url)
            document.markAsSaved()
            
            // Create bookmark while we have security scope access
            recentFilesManager.addFile(url)
            recentFiles = recentFilesManager.recentFiles
            
            print("✅ Document saved successfully")
        } catch {
            print("❌ Failed to save document: \(error)")
            alertMessage = AlertMessage(title: "保存失败", message: error.localizedDescription)
        }
    }

    func saveAsDocument() {
        print("💾 saveAsDocument called")
        print("📊 Document content length: \(document.content.count)")
        
        let savePanel = NSSavePanel()
        savePanel.allowedContentTypes = [UTType(filenameExtension: "md") ?? .plainText]
        savePanel.nameFieldStringValue = (document.fileURL?.deletingPathExtension().lastPathComponent ?? "Untitled") + ".md"
        savePanel.message = "选择保存位置"
        
        savePanel.begin { response in
            if response == .OK, let url = savePanel.url {
                print("✅ User selected save location: \(url.lastPathComponent)")
                self.saveDocumentTo(url: url)
            } else {
                print("⚠️ Save cancelled by user")
            }
        }
    }

    func saveDocumentTo(url: URL) {
        print("💾 saveDocumentTo called with URL: \(url.lastPathComponent)")
        
        // Start accessing security-scoped resource
        let didStartAccessing = url.startAccessingSecurityScopedResource()
        print("🔐 Started accessing security scope: \(didStartAccessing)")
        
        defer {
            if didStartAccessing {
                url.stopAccessingSecurityScopedResource()
                print("🔐 Stopped accessing security scope")
            }
        }
        
        do {
            try fileManager.writeContent(document.content, to: url)
            document.fileURL = url
            document.markAsSaved()
            
            // Create bookmark while we have security scope access
            recentFilesManager.addFile(url)
            recentFiles = recentFilesManager.recentFiles
            
            print("✅ Document saved successfully to: \(url.path)")
        } catch {
            print("❌ Failed to save document: \(error)")
            alertMessage = AlertMessage(title: "保存失败", message: error.localizedDescription)
        }
    }

    func exportHTML() {
        print("📄 exportHTML called")
        
        let savePanel = NSSavePanel()
        savePanel.allowedContentTypes = [.html]
        savePanel.nameFieldStringValue = (document.fileURL?.deletingPathExtension().lastPathComponent ?? "Untitled") + ".html"
        savePanel.message = "选择导出位置"
        
        savePanel.begin { response in
            if response == .OK, let url = savePanel.url {
                print("✅ User selected export location: \(url.lastPathComponent)")
                self.exportHTMLTo(url: url)
            } else {
                print("⚠️ Export cancelled by user")
            }
        }
    }
    
    func exportHTMLTo(url: URL) {
        print("📄 exportHTMLTo called with URL: \(url.lastPathComponent)")
        
        // Start accessing security-scoped resource
        let didStartAccessing = url.startAccessingSecurityScopedResource()
        print("🔐 Started accessing security scope: \(didStartAccessing)")
        
        defer {
            if didStartAccessing {
                url.stopAccessingSecurityScopedResource()
                print("🔐 Stopped accessing security scope")
            }
        }
        
        do {
            try fileManager.writeContent(htmlContent, to: url)
            print("✅ HTML exported successfully to: \(url.path)")
        } catch {
            print("❌ Failed to export HTML: \(error)")
            alertMessage = AlertMessage(title: "导出失败", message: error.localizedDescription)
        }
    }

    // MARK: - View & Theme

    func toggleViewMode() {
        viewMode = viewMode.next
        UserDefaults.standard.set(viewMode.rawValue, forKey: "viewMode")
    }

    func setViewMode(_ mode: ViewMode) {
        viewMode = mode
        UserDefaults.standard.set(mode.rawValue, forKey: "viewMode")
    }

    func setTheme(_ theme: EditorTheme) {
        editorTheme = theme
        UserDefaults.standard.set(theme.rawValue, forKey: "editorTheme")
    }

    func setFontSize(_ size: CGFloat) {
        fontSize = size
        UserDefaults.standard.set(size, forKey: "editorFontSize")
    }
}
