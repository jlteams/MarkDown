import SwiftUI

struct RecentFilesSidebar: View {
    @ObservedObject var viewModel: EditorViewModel
    @Binding var isPresented: Bool

    var body: some View {
        VStack(spacing: 0) {
            if !viewModel.recentFilesManager.recentFiles.isEmpty {
                List(viewModel.recentFilesManager.recentFiles, id: \.self) { url in
                    Button(action: {
                        viewModel.openFile(at: url)
                        isPresented = false
                    }) {
                        HStack {
                            Image(systemName: "doc.text")
                                .foregroundColor(.secondary)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(url.lastPathComponent)
                                    .font(.body)
                                    .lineLimit(1)
                                Text(url.deletingLastPathComponent().lastPathComponent)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .lineLimit(1)
                            }
                            Spacer()
                        }
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .contextMenu {
                        Button("在 Finder 中显示") {
                            NSWorkspace.shared.activateFileViewerSelecting([url])
                        }
                        Divider()
                        Button("从列表移除", role: .destructive) {
                            viewModel.recentFilesManager.removeFile(url)
                        }
                    }
                }
            } else {
                VStack(spacing: 8) {
                    Image(systemName: "clock")
                        .font(.system(size: 24))
                        .foregroundColor(.secondary)
                    Text("暂无最近打开的文件")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .background(Color(nsColor: .controlBackgroundColor))
    }
}
