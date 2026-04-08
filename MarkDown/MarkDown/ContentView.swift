import SwiftUI
import UniformTypeIdentifiers

struct ContentView: View {
    @EnvironmentObject private var viewModel: EditorViewModel
    @State private var showSettings = false
    @State private var showSidebar = false

    var body: some View {
        VStack(spacing: 0) {
            FormatToolbar(viewModel: viewModel)

            mainContent
                .background(Color(nsColor: viewModel.editorTheme.backgroundColor))

            StatusBar(viewModel: viewModel)
                .background(Color(nsColor: .controlBackgroundColor))
        }
        .background(Color(nsColor: .windowBackgroundColor))
        .fileImporter(
            isPresented: $viewModel.isShowingOpenPanel,
            allowedContentTypes: [UTType(filenameExtension: "md") ?? .plainText, 
                                   UTType(filenameExtension: "markdown") ?? .plainText, 
                                   .plainText],
            allowsMultipleSelection: false
        ) { result in
            switch result {
            case .success(let urls):
                if let url = urls.first {
                    viewModel.openFile(at: url)
                }
            case .failure(let error):
                viewModel.alertMessage = EditorViewModel.AlertMessage(title: "打开失败", message: error.localizedDescription)
            }
        }
        .fileExporter(
            isPresented: $viewModel.isShowingSavePanel,
            document: MarkdownTextDocument(content: viewModel.document.content),
            contentType: .plainText,
            defaultFilename: (viewModel.document.fileURL?.deletingPathExtension().lastPathComponent ?? "Untitled") + ".md",
            onCompletion: { result in
                switch result {
                case .success(let url):
                    print("✅ File exporter success: \(url.lastPathComponent)")
                    viewModel.saveDocumentTo(url: url)
                case .failure(let error):
                    print("❌ File exporter failed: \(error)")
                    if !error.localizedDescription.contains("cancel") {
                        viewModel.alertMessage = EditorViewModel.AlertMessage(title: "保存失败", message: error.localizedDescription)
                    }
                }
            }
        )
        .fileExporter(
            isPresented: $viewModel.isShowingExportPanel,
            document: HTMLDocument(content: viewModel.htmlContent),
            contentType: .html,
            defaultFilename: (viewModel.document.fileURL?.deletingPathExtension().lastPathComponent ?? "Untitled") + ".html",
            onCompletion: { result in
                switch result {
                case .success(let url):
                    print("✅ HTML exporter success: \(url.lastPathComponent)")
                    viewModel.exportHTMLTo(url: url)
                case .failure(let error):
                    print("❌ HTML exporter failed: \(error)")
                    if !error.localizedDescription.contains("cancel") {
                        viewModel.alertMessage = EditorViewModel.AlertMessage(title: "导出失败", message: error.localizedDescription)
                    }
                }
            }
        )
        .alert(item: $viewModel.alertMessage) { alert in
            Alert(title: Text(alert.title), message: Text(alert.message), dismissButton: .default(Text("确定")))
        }
        .sheet(isPresented: $showSettings) {
            SettingsView(viewModel: viewModel)
        }
        .onChange(of: viewModel.document.fileName) { _, _ in
            updateWindowTitle()
        }
        .onChange(of: viewModel.document.isModified) { _, _ in
            updateWindowEdited()
        }
    }

    @ViewBuilder
    private var mainContent: some View {
        HStack(spacing: 0) {
            if showSidebar {
                RecentFilesSidebar(viewModel: viewModel, isPresented: $showSidebar)
                    .frame(minWidth: 180, idealWidth: 200, maxWidth: 250)
                Divider()
            }

            switch viewModel.viewMode {
            case .editorOnly:
                MarkdownEditorView(
                    text: Binding(
                        get: { viewModel.document.content },
                        set: { viewModel.updateMarkdownContent($0) }
                    ),
                    theme: viewModel.editorTheme,
                    fontSize: viewModel.fontSize,
                    onTextChange: { _ in }
                )
                .onAppear { setupToolbarNotification() }

            case .previewOnly:
                MarkdownPreviewView(
                    htmlContent: viewModel.htmlContent,
                    isDarkMode: viewModel.editorTheme.isDark
                )

            case .splitView:
                MarkdownEditorView(
                    text: Binding(
                        get: { viewModel.document.content },
                        set: { viewModel.updateMarkdownContent($0) }
                    ),
                    theme: viewModel.editorTheme,
                    fontSize: viewModel.fontSize,
                    onTextChange: { _ in }
                )
                .onAppear { setupToolbarNotification() }

                Divider()

                MarkdownPreviewView(
                    htmlContent: viewModel.htmlContent,
                    isDarkMode: viewModel.editorTheme.isDark
                )
            }
        }
    }

    private func setupToolbarNotification() {
        NotificationCenter.default.addObserver(
            forName: .insertMarkdown,
            object: nil,
            queue: .main
        ) { notification in
            if let window = NSApplication.shared.keyWindow,
               let textView = window.firstResponder as? NSTextView {
                textView.handleToolbarInsert(notification)
            }
        }
    }

    private func updateWindowTitle() {
        if let window = NSApplication.shared.windows.first(where: { $0.isKeyWindow }) {
            window.title = viewModel.windowTitle
        }
    }

    private func updateWindowEdited() {
        if let window = NSApplication.shared.windows.first(where: { $0.isKeyWindow }) {
            window.isDocumentEdited = viewModel.document.isModified
        }
    }
}

// MARK: - MarkdownTextDocument

struct MarkdownTextDocument: FileDocument {
    var content: String

    static var readableContentTypes: [UTType] { [.plainText] }
    static var writableContentTypes: [UTType] { [.plainText] }

    init(content: String) { self.content = content }
    init(configuration: ReadConfiguration) throws {
        self.content = String(data: configuration.file.regularFileContents ?? Data(), encoding: .utf8) ?? ""
    }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        FileWrapper(regularFileWithContents: content.data(using: .utf8)!)
    }
}

// MARK: - HTMLDocument

struct HTMLDocument: FileDocument {
    var content: String

    static var readableContentTypes: [UTType] { [.html] }
    static var writableContentTypes: [UTType] { [.html] }

    init(content: String) { self.content = content }
    init(configuration: ReadConfiguration) throws {
        self.content = String(data: configuration.file.regularFileContents ?? Data(), encoding: .utf8) ?? ""
    }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        FileWrapper(regularFileWithContents: content.data(using: .utf8)!)
    }
}

// MARK: - StatusBar

struct StatusBar: View {
    @ObservedObject var viewModel: EditorViewModel

    private var stats: (words: Int, lines: Int, characters: Int) {
        viewModel.parser.statistics(for: viewModel.document.content)
    }

    var body: some View {
        HStack(spacing: 16) {
            Text("\(stats.lines) 行")
            Text("\(stats.words) 词")
            Text("\(stats.characters) 字符")
            Spacer()
            Text(viewModel.viewMode.displayName)
                .foregroundColor(.secondary)
            Button(action: { viewModel.toggleViewMode() }) {
                Image(systemName: viewModel.viewMode.systemImage)
                    .font(.system(size: 10))
            }
            .buttonStyle(.borderless)
            .help("切换视图模式 (⇧⌘D)")
        }
        .font(.system(size: 11))
        .foregroundColor(.secondary)
        .padding(.horizontal, 12)
        .padding(.vertical, 4)
    }
}
