import Foundation

enum ViewMode: String, CaseIterable, Identifiable {
    case editorOnly = "editor"
    case previewOnly = "preview"
    case splitView = "split"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .editorOnly: return "编辑"
        case .previewOnly: return "预览"
        case .splitView: return "分栏"
        }
    }

    var systemImage: String {
        switch self {
        case .editorOnly: return "doc.text"
        case .previewOnly: return "eye"
        case .splitView: return "rectangle.split.2x1"
        }
    }

    var next: ViewMode {
        switch self {
        case .editorOnly: return .splitView
        case .splitView: return .previewOnly
        case .previewOnly: return .editorOnly
        }
    }
}
