import SwiftUI

// AppDelegate to handle file opening from Finder
class AppDelegate: NSObject, NSApplicationDelegate {
    var viewModel: EditorViewModel?
    private var pendingURL: URL?
    var isProcessingFile = false  // Changed to internal access
    
    func applicationWillFinishLaunching(_ notification: Notification) {
        print("🚀 App will finish launching")
    }
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        print("🚀 App did finish launching")
        // If no file was opened during launch, this means app was launched normally
        // Do nothing - keep the empty document
    }
    
    func application(_ application: NSApplication, open urls: [URL]) {
        print("📂 AppDelegate.application(open:) called with: \(urls.map { $0.lastPathComponent })")
        print("📂 Status - viewModel: \(viewModel == nil ? "nil" : "ready"), pendingURL: \(pendingURL?.lastPathComponent ?? "nil"), isProcessing: \(isProcessingFile)")
        
        guard !isProcessingFile, let url = urls.first else {
            print("📂 Skipping - already processing or no URL")
            return
        }
        
        if let viewModel = viewModel {
            // ViewModel is ready, open file immediately
            print("📂 Opening file immediately via AppDelegate")
            openFileSafely(url: url, viewModel: viewModel)
        } else {
            // ViewModel not ready yet, save URL for later
            print("📂 ViewModel not ready, saving pending URL")
            pendingURL = url
        }
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
    
    func openPendingFile() {
        print("📂 openPendingFile() called - pendingURL: \(pendingURL?.lastPathComponent ?? "nil"), isProcessing: \(isProcessingFile)")
        
        guard !isProcessingFile, let url = pendingURL, let viewModel = viewModel else {
            print("📂 Skipping openPendingFile - isProcessing: \(isProcessingFile), pendingURL: \(pendingURL?.lastPathComponent ?? "nil")")
            return
        }
        
        print("📂 Opening pending file")
        openFileSafely(url: url, viewModel: viewModel)
        pendingURL = nil
    }
    
    func openFileSafely(url: URL, viewModel: EditorViewModel) {
        guard !isProcessingFile else {
            print("⚠️ Already processing a file, skipping")
            return
        }
        
        isProcessingFile = true
        print("🔒 Setting isProcessingFile = true")
        
        // Small delay to ensure UI is ready
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            viewModel.openFile(at: url)
            self?.isProcessingFile = false
            print("🔓 Setting isProcessingFile = false")
        }
    }
}

@main
struct MarkDownApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var viewModel = EditorViewModel()
    @State private var showSettings = false
    @State private var hasConfiguredWindow = false

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(viewModel)
                .onAppear {
                    print("🏗️ ContentView onAppear")
                    // Pass viewModel to app delegate FIRST
                    appDelegate.viewModel = viewModel
                    
                    // Configure window only once
                    if !hasConfiguredWindow {
                        configureWindow()
                        hasConfiguredWindow = true
                    }
                    
                    // Check if there's a pending file to open
                    // Delay slightly to ensure window is ready
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                        appDelegate.openPendingFile()
                    }
                }
                .onOpenURL { url in
                    print("📂 ContentView onOpenURL: \(url.lastPathComponent)")
                    // Only handle if not already processing
                    if !appDelegate.isProcessingFile {
                        appDelegate.openFileSafely(url: url, viewModel: viewModel)
                    } else {
                        print("⚠️ Skipping onOpenURL - already processing")
                    }
                }
        }
        .windowStyle(.titleBar)
        .defaultSize(width: 1000, height: 700)
        .windowToolbarStyle(.unified(showsTitle: true))
        .handlesExternalEvents(matching: [])
        .commands {
            // Handle "Open With" from Finder
            CommandGroup(replacing: .newItem) {
                Button("新建") { 
                    print("📄 New document menu clicked")
                    viewModel.newDocument() 
                }
                    .keyboardShortcut("n", modifiers: .command)
                Button("打开...") { 
                    print("📄 Open document menu clicked")
                    viewModel.openDocument() 
                }
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
                window.minSize = NSSize(width: 600, height: 400)
            }
        }
    }
}
