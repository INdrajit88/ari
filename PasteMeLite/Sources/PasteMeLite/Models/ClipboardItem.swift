import Foundation

struct ClipboardItem: Identifiable, Hashable {
    let id: UUID
    let content: String
    let createdAt: Date
    var isPinned: Bool

    init(
        id: UUID = UUID(),
        content: String,
        createdAt: Date = Date(),
        isPinned: Bool = false
    ) {
        self.id = id
        self.content = content
        self.createdAt = createdAt
        self.isPinned = isPinned
    }

    var preview: String {
        content
            .replacingOccurrences(of: "\n", with: " ")
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
