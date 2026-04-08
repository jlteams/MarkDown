import AppKit
import SwiftUI

// Custom NSTextView that breaks undo coalescing on word boundaries
final class UndoAwareTextView: NSTextView {
    private var lastCharWasBoundary = false

    override func shouldChangeText(in affectedCharRange: NSRange, replacementString: String?) -> Bool {
        // If previous character was a boundary and current is not, break undo coalescing
        if let newString = replacementString, !newString.isEmpty {
            let currentIsBoundary = newString.contains(where: { $0 == "\n" || $0 == " " })

            if lastCharWasBoundary && !currentIsBoundary {
                breakUndoCoalescing()
            }

            // Remember for next input
            lastCharWasBoundary = currentIsBoundary
        }

        return super.shouldChangeText(in: affectedCharRange, replacementString: replacementString)
    }

    override func keyDown(with event: NSEvent) {
        // Handle Cmd+Z - cancel IME composition first
        if event.modifierFlags.contains(.command) && event.keyCode == 6 { // 'Z' key
            if hasMarkedText() {
                inputContext?.discardMarkedText()
                return
            }
        }
        super.keyDown(with: event)
    }
}

struct MarkdownEditorView: NSViewRepresentable {
    @Binding var text: String
    var theme: EditorTheme
    var fontSize: CGFloat
    var onTextChange: (String) -> Void

    final class Coordinator: NSObject, NSTextStorageDelegate {
        var parent: MarkdownEditorView
        var isUpdatingFromBinding = false

        init(_ parent: MarkdownEditorView) {
            self.parent = parent
        }

        func textStorage(_ textStorage: NSTextStorage, didProcessEditing editedMask: NSTextStorageEditActions, range editedRange: NSRange, changeInLength delta: Int) {
            guard !isUpdatingFromBinding, editedMask.contains(.editedCharacters) else { return }
            let newText = textStorage.string
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.parent.text = newText
            }
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeNSView(context: Context) -> NSScrollView {
        print("🔨 MarkdownEditorView makeNSView - initial text length: \(text.count)")
        let scrollView = NSScrollView()
        scrollView.hasVerticalScroller = true
        scrollView.hasHorizontalScroller = false
        scrollView.autohidesScrollers = true
        scrollView.borderType = .noBorder

        let textView = UndoAwareTextView()
        textView.font = NSFont.monospacedSystemFont(ofSize: fontSize, weight: .regular)
        textView.textColor = theme.textColor
        textView.backgroundColor = theme.backgroundColor
        textView.insertionPointColor = theme.cursorColor
        textView.selectedTextAttributes = [.backgroundColor: theme.selectionColor]
        textView.allowsUndo = true
        textView.isRichText = false
        textView.usesFindBar = true
        textView.isAutomaticQuoteSubstitutionEnabled = false
        textView.isAutomaticDashSubstitutionEnabled = false
        textView.isAutomaticTextReplacementEnabled = false
        textView.isContinuousSpellCheckingEnabled = false
        textView.isAutomaticSpellingCorrectionEnabled = false
        textView.textContainerInset = NSSize(width: 16, height: 16)
        textView.isVerticallyResizable = true
        textView.isHorizontallyResizable = false
        textView.textContainer?.widthTracksTextView = true

        // Set text storage delegate
        textView.textStorage?.delegate = context.coordinator

        let lineNumView = LineNumberRulerView(scrollView: scrollView)
        lineNumView.theme = theme
        lineNumView.font = NSFont.monospacedSystemFont(ofSize: fontSize, weight: .regular)
        scrollView.verticalRulerView = lineNumView
        scrollView.rulersVisible = true
        scrollView.documentView = textView

        textView.string = text
        print("🔨 TextView initialized with text length: \(textView.string.count)")

        return scrollView
    }

    func updateNSView(_ scrollView: NSScrollView, context: Context) {
        guard let textView = scrollView.documentView as? NSTextView else { return }

        // Update coordinator's parent reference
        context.coordinator.parent = self

        // Only sync text if it changed externally
        if textView.string != text {
            print("🔄 Updating textView - current: \(textView.string.count), new: \(text.count)")
            context.coordinator.isUpdatingFromBinding = true
            textView.undoManager?.disableUndoRegistration()
            defer {
                textView.undoManager?.enableUndoRegistration()
                context.coordinator.isUpdatingFromBinding = false
            }

            // Replace text
            let fullRange = NSRange(location: 0, length: (textView.string as NSString).length)
            textView.textStorage?.replaceCharacters(in: fullRange, with: text)
            print("✅ TextView updated to length: \(textView.string.count)")
        }

        textView.font = NSFont.monospacedSystemFont(ofSize: fontSize, weight: .regular)
        textView.textColor = theme.textColor
        textView.backgroundColor = theme.backgroundColor
        textView.insertionPointColor = theme.cursorColor
        textView.selectedTextAttributes = [.backgroundColor: theme.selectionColor]
        textView.textContainerInset = NSSize(width: 16, height: 16)

        if let lineNumView = scrollView.verticalRulerView as? LineNumberRulerView {
            lineNumView.theme = theme
            lineNumView.font = NSFont.monospacedSystemFont(ofSize: fontSize, weight: .regular)
            lineNumView.needsDisplay = true
        }
    }
}
