import SwiftUI

@main
struct MarkDownApp: App {
    @StateObject private var viewModel = EditorViewModel()
    @State private var showSettings = false

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(viewModel)
                .onAppear {
                    configureWindow()
                }
        }
        .windowStyle(.titleBar)
        .defaultSize(width: 1000, height: 700)
        .windowToolbarStyle(.unified(showsTitle: true))
        .commands {
            // Replace system File menu items
            CommandGroup(replacing: .newItem) {
                Button("新建") { viewModel.newDocument() }
                    .keyboardShortcut("n", modifiers: .command)
                Button("打开...") { viewModel.openDocument() }
                    .keyboardShortcut("o", modifiers: .command)
                
                // Recent files section
                if viewModel.recentFiles.isEmpty {
                    // Show placeholder if no recent files
                    Text("没有最近文件")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                        .disabled(true)
                } else {
                    Divider()
                    
                    ForEach(viewModel.recentFiles.prefix(10), id: \.self) { url in
                        Button(url.lastPathComponent) {
                            viewModel.openFile(at: url)
                        }
                    }
                    
                    Divider()
                    
                    Button("清除最近文件") {
                        viewModel.recentFilesManager.clearAll()
                        viewModel.recentFiles = []
                    }
                }
            }
            CommandGroup(replacing: .saveItem) {
                Button("保存") { viewModel.saveDocument() }
                    .keyboardShortcut("s", modifiers: .command)
                Button("另存为...") { viewModel.saveAsDocument() }
                    .keyboardShortcut("s", modifiers: [.command, .shift])
            }
            CommandGroup(after: .importExport) {
                Button("导出 HTML...") { viewModel.exportHTML() }
                    .keyboardShortcut("e", modifiers: [.command, .shift])
            }
            CommandGroup(after: .toolbar) {
                Button(viewModel.viewMode.displayName) { viewModel.toggleViewMode() }
                    .keyboardShortcut("d", modifiers: [.command, .shift])
                Button("设置...") { showSettings = true }
                    .keyboardShortcut(",", modifiers: .command)
            }
            CommandGroup(replacing: .help) {
                Button("关于 MarkDown") {
                    NSApp.orderFrontStandardAboutPanel(nil)
                }
            }
        }

        Settings {
            SettingsView(viewModel: viewModel)
        }
    }

    private func configureWindow() {
        DispatchQueue.main.async {
            if let window = NSApplication.shared.windows.first {
                window.title = "Untitled — MarkDown"
                window.minSize = NSSize(width: 600, height: 400)
            }
        }
    }
}
