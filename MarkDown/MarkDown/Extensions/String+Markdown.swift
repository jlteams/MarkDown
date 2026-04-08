import Foundation

extension String {
    /// 获取指定范围的行号（基于整个字符串）
    func lineNumber(for offset: Int) -> Int {
        let substring = self[self.startIndex..<self.index(self.startIndex, offsetBy: max(0, offset))]
        return substring.components(separatedBy: .newlines).count
    }

    /// 获取指定位置的缩进字符串
    func leadingWhitespace(at offset: Int) -> String {
        guard offset <= count else { return "" }
        let idx = index(startIndex, offsetBy: offset)
        var lineStart = idx
        while lineStart > startIndex {
            let prev = index(before: lineStart)
            if self[prev] == "\n" {
                break
            }
            lineStart = prev
        }
        var indentEnd = lineStart
        while indentEnd < endIndex && self[indentEnd].isWhitespace && self[indentEnd] != "\n" {
            indentEnd = index(after: indentEnd)
        }
        return String(self[lineStart..<indentEnd])
    }

    /// 在指定位置获取当前行的起始偏移
    func lineStartOffset(at offset: Int) -> Int {
        let str = self[self.startIndex..<self.index(self.startIndex, offsetBy: min(offset, count))]
        if let lastNewline = str.lastIndex(of: "\n") {
            return str.distance(from: startIndex, to: lastNewline) + 1
        }
        return 0
    }

    /// 在指定位置获取当前行的结束偏移
    func lineEndOffset(at offset: Int) -> Int {
        guard offset < count else { return count }
        let idx = index(startIndex, offsetBy: offset)
        var lineEnd = idx
        while lineEnd < endIndex && self[lineEnd] != "\n" {
            lineEnd = index(after: lineEnd)
        }
        return distance(from: startIndex, to: lineEnd)
    }

    /// 统计总行数
    var lineCount: Int {
        var count = 0
        var index = startIndex
        while index < endIndex {
            if self[index] == "\n" { count += 1 }
            index = self.index(after: index)
        }
        return count + 1
    }
}
