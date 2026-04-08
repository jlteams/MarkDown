# MarkDown Editor

一个简洁、高效的 macOS Markdown 编辑器，支持实时预览、多主题切换和丰富的格式化工具。

![Platform](https://img.shields.io/badge/platform-macOS-blue)
![Swift](https://img.shields.io/badge/Swift-5.9-orange)
![License](https://img.shields.io/badge/license-MIT-green)

## 功能特性

### 📝 编辑功能
- **实时预览** - 边写边看，支持三种视图模式
  - 仅编辑模式
  - 仅预览模式
  - 分屏模式（默认）
- **语法高亮** - 支持 Markdown 语法高亮显示
- **行号显示** - 清晰的行号标记
- **自动换行** - 文字自动换行，适应窗口大小
- **撤销优化** - 以换行符和空格为界的智能撤销

### 🎨 格式化工具
工具栏提供快速格式化按钮：
- **标题** - 快速插入标题
- **加粗** `⌘B` - 加粗文字
- **斜体** `⌘I` - 斜体文字
- **删除线** - 删除线效果
- **链接** `⌘K` - 插入链接
- **行内代码** `⌘E` - 行内代码
- **无序列表** - 创建无序列表（支持多行）
- **有序列表** - 创建有序列表（支持多行）
- **任务列表** - 创建任务列表（支持多行）
- **引用** - 插入引用块
- **代码块** - 插入代码块
- **分割线** - 插入分割线

### 🌙 主题支持
- **浅色模式** - 清爽的浅色主题
- **深色模式** - 护眼的深色主题
- **跟随系统** - 自动跟随系统主题

### 💾 文件管理
- **新建文档** `⌘N` - 创建新文档
- **打开文件** `⌘O` - 打开 Markdown 文件
- **保存** `⌘S` - 保存文档
- **另存为** `⇧⌘S` - 另存为新位置
- **最近文件** - 快速访问最近打开的文件
- **导出 HTML** `⇧⌘E` - 导出为 HTML 文件

### 📊 状态栏
实时显示文档统计信息：
- 行数
- 词数
- 字符数

### ⚙️ 设置
- **主题切换** - 选择编辑器主题
- **字体大小** - 自定义字体大小（10-24pt）
- **视图模式** - 设置默认视图模式
- **清除最近文件** - 清空最近文件记录

## 系统要求

- macOS 14.0 或更高版本
- Xcode 15.0 或更高版本（开发需要）

## 安装与使用

### 从源码构建

1. **克隆仓库**
   ```bash
   git clone https://github.com/jlteams/MarkDown.git
   cd MarkDown
   ```

2. **打开项目**
   ```bash
   cd MarkDown
   open MarkDown.xcodeproj
   ```

3. **构建运行**
   - 在 Xcode 中按 `⌘R` 运行项目
   - 或选择 Product → Run

### 使用方法

1. **创建新文档**
   - 启动应用后自动创建新文档
   - 或使用 `⌘N` 创建新文档

2. **编辑内容**
   - 在左侧编辑区输入 Markdown 文本
   - 右侧实时预览渲染效果

3. **格式化文本**
   - 选中文本后点击工具栏按钮
   - 或使用快捷键快速格式化

4. **保存文档**
   - 使用 `⌘S` 保存文档
   - 首次保存会弹出保存面板

## 快捷键

| 功能 | 快捷键 |
|------|--------|
| 新建 | `⌘N` |
| 打开 | `⌘O` |
| 保存 | `⌘S` |
| 另存为 | `⇧⌘S` |
| 导出 HTML | `⇧⌘E` |
| 加粗 | `⌘B` |
| 斜体 | `⌘I` |
| 链接 | `⌘K` |
| 行内代码 | `⌘E` |
| 切换视图 | `⇧⌘D` |
| 设置 | `⌘,` |

## 技术栈

- **语言**: Swift 5.9
- **框架**: SwiftUI, AppKit
- **Markdown 解析**: cmark-gfm (GitHub Flavored Markdown)
- **预览渲染**: WKWebView
- **数据持久化**: UserDefaults, CoreData

## 项目结构

```
MarkDown/
├── MarkDown/
│   ├── MarkDown/
│   │   ├── Models/
│   │   │   ├── DocumentModel.swift      # 文档模型
│   │   │   ├── EditorTheme.swift        # 编辑器主题
│   │   │   └── ViewMode.swift           # 视图模式
│   │   ├── Views/
│   │   │   ├── Editor/
│   │   │   │   ├── MarkdownEditorView.swift  # 编辑器视图
│   │   │   │   └── LineNumberView.swift      # 行号视图
│   │   │   ├── Preview/
│   │   │   │   └── MarkdownPreviewView.swift # 预览视图
│   │   │   ├── Toolbar/
│   │   │   │   └── FormatToolbar.swift       # 格式化工具栏
│   │   │   ├── Settings/
│   │   │   │   └── SettingsView.swift        # 设置界面
│   │   │   └── Sidebar/
│   │   │       └── RecentFilesSidebar.swift  # 最近文件侧边栏
│   │   ├── ViewModels/
│   │   │   └── EditorViewModel.swift         # 编辑器视图模型
│   │   ├── Services/
│   │   │   ├── MarkdownParser.swift          # Markdown 解析器
│   │   │   ├── FileManagerService.swift      # 文件管理服务
│   │   │   └── RecentFilesManager.swift      # 最近文件管理
│   │   ├── Extensions/
│   │   │   ├── NSTextView+Markdown.swift     # NSTextView 扩展
│   │   │   ├── String+Markdown.swift         # String 扩展
│   │   │   └── NSAppearance+Theme.swift      # 主题扩展
│   │   ├── ContentView.swift                 # 主内容视图
│   │   └── MarkDownApp.swift                 # 应用入口
│   ├── MarkDown.xcodeproj
│   ├── MarkDownTests
│   └── MarkDownUITests
└── README.md
```

## 架构设计

### MVVM + Coordinator
- **Model**: 数据模型（DocumentModel）
- **View**: SwiftUI 视图
- **ViewModel**: 业务逻辑（EditorViewModel）
- **Services**: 服务层（解析器、文件管理）

### 核心组件

1. **MarkdownParser**
   - 使用 cmark-gfm 解析 Markdown
   - 支持 GitHub Flavored Markdown
   - 支持表格、任务列表、删除线等扩展语法

2. **MarkdownEditorView**
   - 基于 NSTextView 的原生编辑器
   - 支持语法高亮、行号显示
   - 自定义撤销行为

3. **MarkdownPreviewView**
   - 基于 WKWebView 的 HTML 预览
   - 支持深色/浅色主题
   - 实时渲染 Markdown

## 开发说明

### 环境配置

1. **安装 Xcode**
   - 从 App Store 安装 Xcode 15+
   - 安装 Command Line Tools

2. **依赖管理**
   - 项目使用 Swift Package Manager
   - cmark-gfm 通过 SPM 集成

### 沙盒权限

应用启用了 App Sandbox，需要的权限：
- `com.apple.security.files.user-selected.read-write` - 读写用户选择的文件
- `com.apple.security.network.client` - 网络访问（预览功能）

### 调试模式

运行项目时，控制台会输出详细日志：
- 📂 文件操作日志
- 💾 保存操作日志
- 🔐 安全范围权限日志
- ✅ 成功操作日志
- ❌ 错误日志

## 已知问题

- [ ] WebView 在沙盒环境下有连接警告（不影响功能）
- [ ] 某些系统服务访问受限（Sandbox 限制）

## 未来计划

- [ ] 图片粘贴和拖拽支持
- [ ] 表格编辑器
- [ ] 目录大纲视图
- [ ] 文件搜索功能
- [ ] 多标签页支持
- [ ] iCloud 同步
- [ ] 导出 PDF
- [ ] 自定义主题编辑器
- [ ] 插件系统

## 贡献指南

欢迎贡献代码！请遵循以下步骤：

1. Fork 本仓库
2. 创建特性分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 创建 Pull Request

## 许可证

本项目采用 MIT 许可证 - 详见 [LICENSE](LICENSE) 文件

## 致谢

- [cmark-gfm](https://github.com/github/cmark-gfm) - GitHub 的 Markdown 解析器
- [Apple Developer Documentation](https://developer.apple.com/documentation/) - Apple 开发文档

## 联系方式

如有问题或建议，欢迎：
- 提交 Issue

---

**Made with ❤️ for macOS**
