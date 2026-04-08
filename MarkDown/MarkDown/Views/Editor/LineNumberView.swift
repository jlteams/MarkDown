import AppKit

final class LineNumberRulerView: NSRulerView {

    var theme: EditorTheme = .system
    var font: NSFont = .monospacedSystemFont(ofSize: 14, weight: .regular) {
        didSet { ruleThickness = calculateThickness() }
    }

    private let padding: CGFloat = 8

    private var _scrollView: NSScrollView?

    init(scrollView: NSScrollView) {
        self._scrollView = scrollView
        super.init(scrollView: scrollView, orientation: .verticalRuler)
        clientView = scrollView.documentView as? NSTextView
        ruleThickness = calculateThickness()
        layer?.backgroundColor = theme.gutterColor.cgColor
    }

    required init(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func drawHashMarksAndLabels(in rect: NSRect) {
        guard let textView = scrollView?.documentView as? NSTextView,
              let layoutManager = textView.layoutManager,
              let textContainer = textView.textContainer else { return }

        NSColor.clear.set()
        bounds.fill()

        let bgColor = theme.gutterColor
        bgColor.setFill()
        bounds.fill()

        let text = textView.string as NSString
        let visibleRect = scrollView?.contentView.visibleRect ?? .zero

        let glyphRange = layoutManager.glyphRange(forBoundingRect: visibleRect, in: textContainer)
        let characterRange = layoutManager.characterRange(forGlyphRange: glyphRange, actualGlyphRange: nil)

        let attrs: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: theme.gutterTextColor
        ]

        var lineNumber = 1
        var index = 0

        while index < characterRange.location {
            if text.character(at: index) == Character("\n").asciiValue! {
                lineNumber += 1
            }
            index += 1
        }

        let origin = (scrollView?.documentView as? NSTextView)?.textContainerOrigin ?? .zero
        var charIndex = characterRange.location
        while charIndex < NSMaxRange(characterRange) {
            let lineRect = layoutManager.lineFragmentRect(forGlyphAt: charIndex, effectiveRange: nil)
            let y = lineRect.origin.y - visibleRect.origin.y + origin.y

            let attributedString = NSAttributedString(string: "\(lineNumber)", attributes: attrs)
            let size = attributedString.size()
            let x = (ruleThickness - size.width - padding) / 2

            attributedString.draw(at: NSPoint(x: x, y: y))

            while charIndex < text.length && text.character(at: charIndex) != Character("\n").asciiValue! {
                charIndex += 1
            }
            if charIndex < text.length { charIndex += 1 }
            lineNumber += 1
        }
    }

    private func calculateThickness() -> CGFloat {
        guard let textView = scrollView?.documentView as? NSTextView else { return 40 }
        let lineCount = max(textView.string.lineCount, 1)
        let digits = "\(lineCount)".count
        let stringWidth = ("8" as NSString).size(withAttributes: [.font: font]).width
        return stringWidth * CGFloat(digits) + padding * 2
    }

    func refresh() {
        ruleThickness = calculateThickness()
        needsDisplay = true
    }
}
