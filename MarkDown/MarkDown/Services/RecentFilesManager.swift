import Foundation

final class RecentFilesManager: @unchecked Sendable {

    private let maxFiles = 20
    private let storageKey = "recentFiles"
    private let bookmarksKey = "recentFileBookmarks"

    private(set) var recentFiles: [URL]
    private var bookmarks: [Data] = []

    init() {
        // Load bookmarks
        if let bookmarkData = UserDefaults.standard.array(forKey: bookmarksKey) as? [Data] {
            bookmarks = bookmarkData
            recentFiles = bookmarks.compactMap { bookmark in
                var isStale = false
                if let url = try? URL(resolvingBookmarkData: bookmark, options: .withSecurityScope, relativeTo: nil, bookmarkDataIsStale: &isStale) {
                    print("✅ Loaded recent file: \(url.lastPathComponent)")
                    return url
                } else {
                    print("❌ Failed to resolve bookmark")
                }
                return nil
            }
            print("📁 Loaded \(recentFiles.count) recent files")
        } else {
            recentFiles = []
            print("📁 No recent files found")
        }
    }

    func addFile(_ url: URL) {
        guard url.isFileURL else { 
            print("❌ Not a file URL: \(url)")
            return 
        }
        
        // Check if file exists
        guard FileManager.default.fileExists(atPath: url.path) else {
            print("❌ File does not exist: \(url.path)")
            return
        }
        
        // Try to create security-scoped bookmark
        do {
            // Don't need to call startAccessingSecurityScopedResource here
            // because it should be called before this method
            let bookmark = try url.bookmarkData(options: .withSecurityScope, includingResourceValuesForKeys: nil, relativeTo: nil)
            print("✅ Created bookmark for: \(url.lastPathComponent)")
            
            // Remove existing entry if present
            if let index = recentFiles.firstIndex(of: url) {
                recentFiles.remove(at: index)
                bookmarks.remove(at: index)
            }
            
            recentFiles.insert(url, at: 0)
            bookmarks.insert(bookmark, at: 0)
            
            if recentFiles.count > maxFiles {
                recentFiles = Array(recentFiles.prefix(maxFiles))
                bookmarks = Array(bookmarks.prefix(maxFiles))
            }
            
            save()
            print("📁 Recent files count: \(recentFiles.count)")
        } catch {
            print("❌ Failed to create bookmark for \(url.lastPathComponent): \(error)")
            print("⚠️ Adding file to recent list without bookmark")
            
            // Still add to recent files even without bookmark
            if let index = recentFiles.firstIndex(of: url) {
                recentFiles.remove(at: index)
            }
            recentFiles.insert(url, at: 0)
            
            if recentFiles.count > maxFiles {
                recentFiles = Array(recentFiles.prefix(maxFiles))
            }
        }
    }

    func removeFile(_ url: URL) {
        if let index = recentFiles.firstIndex(of: url) {
            recentFiles.remove(at: index)
            bookmarks.remove(at: index)
            save()
            print("🗑 Removed from recent files: \(url.lastPathComponent)")
        }
    }

    func clearAll() {
        recentFiles.removeAll()
        bookmarks.removeAll()
        save()
        print("🗑 Cleared all recent files")
    }

    private func save() {
        UserDefaults.standard.set(bookmarks, forKey: bookmarksKey)
        print("💾 Saved \(bookmarks.count) bookmarks to UserDefaults")
    }
}
