import SwiftUI

struct SettingsView: View {
    @ObservedObject var viewModel: EditorViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("设置")
                    .font(.headline)
                Spacer()
                Button("完成") { dismiss() }
                    .keyboardShortcut(.cancelAction)
            }
            .padding()

            Divider()

            // Settings content
            Form {
                Section("编辑器主题") {
                    Picker("主题", selection: $viewModel.editorTheme) {
                        ForEach(EditorTheme.allCases) { theme in
                            Text(theme.displayName).tag(theme)
                        }
                    }
                    .pickerStyle(.segmented)
                    .onChange(of: viewModel.editorTheme) { _, newValue in
                        viewModel.setTheme(newValue)
                    }
                }

                Section("编辑器") {
                    HStack {
                        Text("字体大小")
                        Spacer()
                        Stepper("", value: $viewModel.fontSize, in: 10...24, step: 1)
                            .labelsHidden()
                        Text("\(Int(viewModel.fontSize)) pt")
                            .monospacedDigit()
                            .frame(width: 50)
                    }
                    .onChange(of: viewModel.fontSize) { _, newValue in
                        viewModel.setFontSize(newValue)
                    }
                }

                Section("默认视图模式") {
                    Picker("视图模式", selection: $viewModel.viewMode) {
                        ForEach(ViewMode.allCases) { mode in
                            Label(mode.displayName, systemImage: mode.systemImage).tag(mode)
                        }
                    }
                    .onChange(of: viewModel.viewMode) { _, newValue in
                        viewModel.setViewMode(newValue)
                    }
                }

                Section("文件") {
                    Button("清除最近文件") {
                        viewModel.recentFilesManager.clearAll()
                    }
                }
            }
            .formStyle(.grouped)
            .scrollContentBackground(.hidden)
        }
        .frame(width: 350, height: 380)
    }
}
