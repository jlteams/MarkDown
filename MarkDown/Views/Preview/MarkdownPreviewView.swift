import AppKit
import SwiftUI
import WebKit

struct MarkdownPreviewView: NSViewRepresentable {
    let htmlContent: String
    var isDarkMode: Bool

    func makeNSView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.userContentController = WKUserContentController()
        let preferences = WKWebpagePreferences()
        preferences.allowsContentJavaScript = false
        config.defaultWebpagePreferences = preferences

        let webView = WKWebView(frame: .zero, configuration: config)
        webView.navigationDelegate = context.coordinator
        
        // Load initial content
        let fullHTML = PreviewHTMLTemplate.generateHTML(
            body: htmlContent,
            isDarkMode: isDarkMode
        )
        webView.loadHTMLString(fullHTML, baseURL: nil)
        
        return webView
    }

    func updateNSView(_ webView: WKWebView, context: Context) {
        // Only reload if content or theme actually changed
        guard context.coordinator.lastHTMLContent != htmlContent ||
              context.coordinator.lastIsDarkMode != isDarkMode else {
            return
        }
        
        context.coordinator.lastHTMLContent = htmlContent
        context.coordinator.lastIsDarkMode = isDarkMode
        
        let fullHTML = PreviewHTMLTemplate.generateHTML(
            body: htmlContent,
            isDarkMode: isDarkMode
        )
        webView.loadHTMLString(fullHTML, baseURL: nil)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    final class Coordinator: NSObject, WKNavigationDelegate {
        var lastHTMLContent: String = ""
        var lastIsDarkMode: Bool = false
    }

    /// Scroll the preview proportionally to match the editor's scroll position.
    func scrollWebView(_ webView: WKWebView, proportion: CGFloat) {
        webView.evaluateJavaScript("document.body.scrollHeight") { [weak webView] totalHeight, _ in
            guard let total = totalHeight as? CGFloat, total > 0 else { return }
            let targetY = proportion * total
            webView?.evaluateJavaScript("window.scrollTo(0, \(targetY))")
        }
    }
}

enum PreviewHTMLTemplate {

    static func generateHTML(body: String, isDarkMode: Bool) -> String {
        let css = isDarkMode ? darkCSS : lightCSS
        return """
        <!DOCTYPE html>
        <html>
        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <style>
                \(css)
            </style>
        </head>
        <body>
            \(body)
        </body>
        </html>
        """
    }

    // MARK: - Light Theme CSS

    private static let lightCSS = """
    body {
        font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Helvetica, Arial, sans-serif;
        font-size: 15px;
        line-height: 1.7;
        color: #1d1d1f;
        max-width: 800px;
        margin: 0 auto;
        padding: 32px 40px;
        background-color: #ffffff;
        -webkit-font-smoothing: antialiased;
    }

    h1, h2, h3, h4, h5, h6 {
        margin-top: 1.5em;
        margin-bottom: 0.5em;
        font-weight: 600;
        line-height: 1.3;
        color: #111;
    }

    h1 { font-size: 2em; }
    h2 { font-size: 1.5em; }
    h3 { font-size: 1.25em; }
    h4 { font-size: 1em; }
    h5 { font-size: 0.875em; }
    h6 { font-size: 0.85em; color: #6a737d; }

    a { color: #0366d6; text-decoration: none; }
    a:hover { text-decoration: underline; }

    code {
        font-family: "SF Mono", Monaco, Menlo, Consolas, monospace;
        font-size: 0.9em;
        background-color: rgba(27, 31, 35, 0.05);
        border-radius: 3px;
        padding: 0.2em 0.4em;
    }

    pre {
        background-color: #f6f8fa;
        border-radius: 6px;
        padding: 16px;
        overflow-x: auto;
        margin: 1em 0;
        border: 1px solid #e1e4e8;
    }

    pre code {
        background-color: transparent;
        padding: 0;
        font-size: 0.85em;
        line-height: 1.5;
    }

    blockquote {
        margin: 1em 0;
        padding: 0.5em 1em;
        color: #6a737d;
        border-left: 4px solid #dfe2e5;
        background-color: #f8f9fa;
        border-radius: 0 4px 4px 0;
    }

    blockquote p { margin: 0; }

    table {
        border-collapse: collapse;
        width: 100%;
        margin: 1em 0;
    }

    th, td {
        padding: 8px 12px;
        border: 1px solid #dfe2e5;
        text-align: left;
    }

    th {
        font-weight: 600;
        background-color: #f6f8fa;
    }

    tr:nth-child(even) { background-color: #f6f8fa; }

    img { max-width: 100%; height: auto; border-radius: 4px; }

    hr {
        border: none;
        height: 1px;
        background-color: #e1e4e8;
        margin: 2em 0;
    }

    ul, ol { padding-left: 2em; margin: 0.5em 0; }
    li { margin: 0.25em 0; }

    input[type="checkbox"] { margin-right: 6px; }

    del { color: #6a737d; text-decoration: line-through; }

    strong { font-weight: 600; }
    """

    // MARK: - Dark Theme CSS

    private static let darkCSS = """
    body {
        font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Helvetica, Arial, sans-serif;
        font-size: 15px;
        line-height: 1.7;
        color: #c9d1d9;
        max-width: 800px;
        margin: 0 auto;
        padding: 32px 40px;
        background-color: #1e1e1e;
        -webkit-font-smoothing: antialiased;
    }

    h1, h2, h3, h4, h5, h6 {
        margin-top: 1.5em;
        margin-bottom: 0.5em;
        font-weight: 600;
        line-height: 1.3;
        color: #e6edf3;
    }

    h1 { font-size: 2em; }
    h2 { font-size: 1.5em; }
    h3 { font-size: 1.25em; }
    h4 { font-size: 1em; }
    h5 { font-size: 0.875em; }
    h6 { font-size: 0.85em; color: #8b949e; }

    a { color: #58a6ff; text-decoration: none; }
    a:hover { text-decoration: underline; }

    code {
        font-family: "SF Mono", Monaco, Menlo, Consolas, monospace;
        font-size: 0.9em;
        background-color: rgba(110, 118, 129, 0.3);
        border-radius: 3px;
        padding: 0.2em 0.4em;
    }

    pre {
        background-color: #161b22;
        border-radius: 6px;
        padding: 16px;
        overflow-x: auto;
        margin: 1em 0;
        border: 1px solid #30363d;
    }

    pre code {
        background-color: transparent;
        padding: 0;
        font-size: 0.85em;
        line-height: 1.5;
    }

    blockquote {
        margin: 1em 0;
        padding: 0.5em 1em;
        color: #8b949e;
        border-left: 4px solid #30363d;
        background-color: #161b22;
        border-radius: 0 4px 4px 0;
    }

    blockquote p { margin: 0; }

    table {
        border-collapse: collapse;
        width: 100%;
        margin: 1em 0;
    }

    th, td {
        padding: 8px 12px;
        border: 1px solid #30363d;
        text-align: left;
    }

    th {
        font-weight: 600;
        background-color: #161b22;
    }

    tr:nth-child(even) { background-color: #161b22; }

    img { max-width: 100%; height: auto; border-radius: 4px; }

    hr {
        border: none;
        height: 1px;
        background-color: #30363d;
        margin: 2em 0;
    }

    ul, ol { padding-left: 2em; margin: 0.5em 0; }
    li { margin: 0.25em 0; }

    input[type="checkbox"] { margin-right: 6px; }

    del { color: #8b949e; text-decoration: line-through; }

    strong { font-weight: 600; }
    """
}
