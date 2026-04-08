import SwiftUI

struct FormatToolbar: View {
    @ObservedObject var viewModel: EditorViewModel

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 2) {
                // 为左侧行号区域留出 60px 空间
                Color.clear
                    .frame(width: 52)
                
                toolbarButton(icon: "textformat.size", tooltip: "标题") { postNotification(wrapper: "heading") }
                toolbarDivider()
                toolbarButton(icon: "bold", tooltip: "加粗 ⌘B") { postNotification(wrapper: "**") }
                toolbarButton(icon: "italic", tooltip: "斜体 ⌘I") { postNotification(wrapper: "*") }
                toolbarButton(icon: "strikethrough", tooltip: "删除线") { postNotification(wrapper: "~~") }
                toolbarDivider()
                toolbarButton(icon: "link", tooltip: "链接 ⌘K") { postNotification(wrapper: "[]()") }
                toolbarButton(icon: "doc.text.magnifyingglass", tooltip: "行内代码 ⌘E") { postNotification(wrapper: "`") }
                toolbarDivider()
                toolbarButton(icon: "list.bullet", tooltip: "无序列表") { postNotification(wrapper: "bullet") }
                toolbarButton(icon: "list.number", tooltip: "有序列表") { postNotification(wrapper: "numbered") }
                toolbarButton(icon: "checklist", tooltip: "任务列表") { postNotification(wrapper: "task") }
                toolbarDivider()
                toolbarButton(icon: "quote.bubble", tooltip: "引用") { postNotification(wrapper: "quote") }
                toolbarButton(icon: "text.insert", tooltip: "代码块") { postNotification(wrapper: "codeblock") }
                toolbarButton(icon: "line.3.horizontal.decrease", tooltip: "分割线") { postNotification(wrapper: "hr") }
                Spacer()
            }
            .padding(.trailing, 8)
            .padding(.vertical, 4)
        }
        .frame(height: 36)
        .background(Color(nsColor: .controlBackgroundColor))
        .overlay(
            Divider(),
            alignment: .bottom
        )
    }

    private func toolbarButton(icon: String, tooltip: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 12))
                .frame(width: 28, height: 28)
                .contentShape(Rectangle())
        }
        .buttonStyle(.borderless)
        .help(tooltip)
    }

    private func toolbarDivider() -> some View {
        Divider()
            .frame(height: 20)
    }

    private func postNotification(wrapper: String) {
        NotificationCenter.default.post(name: .insertMarkdown, object: wrapper)
    }
}
