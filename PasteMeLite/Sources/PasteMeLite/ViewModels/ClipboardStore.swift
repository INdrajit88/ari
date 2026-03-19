import AppKit
import Combine
import Foundation

@MainActor
final class ClipboardStore: ObservableObject {
    @Published private(set) var items: [ClipboardItem] = []
    @Published var searchText = ""

    private let pasteboard = NSPasteboard.general
    private var changeCount: Int
    private var cancellables = Set<AnyCancellable>()

    private let maxItems = 100

    init() {
        changeCount = pasteboard.changeCount

        Timer.publish(every: 0.7, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.capturePasteboardIfNeeded()
            }
            .store(in: &cancellables)
    }

    var filteredItems: [ClipboardItem] {
        let sorted = items.sorted { lhs, rhs in
            if lhs.isPinned != rhs.isPinned {
                return lhs.isPinned && !rhs.isPinned
            }
            return lhs.createdAt > rhs.createdAt
        }

        guard !searchText.isEmpty else {
            return sorted
        }

        return sorted.filter {
            $0.content.localizedCaseInsensitiveContains(searchText)
        }
    }

    func copy(item: ClipboardItem) {
        pasteboard.clearContents()
        pasteboard.setString(item.content, forType: .string)
        changeCount = pasteboard.changeCount
    }

    func togglePin(item: ClipboardItem) {
        guard let idx = items.firstIndex(where: { $0.id == item.id }) else { return }
        items[idx].isPinned.toggle()
    }

    func delete(item: ClipboardItem) {
        items.removeAll { $0.id == item.id }
    }

    func clearUnpinned() {
        items.removeAll { !$0.isPinned }
    }

    private func capturePasteboardIfNeeded() {
        guard pasteboard.changeCount != changeCount else { return }
        changeCount = pasteboard.changeCount

        guard let raw = pasteboard.string(forType: .string) else { return }
        let normalized = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !normalized.isEmpty else { return }

        if let existingIndex = items.firstIndex(where: { $0.content == normalized }) {
            let existing = items.remove(at: existingIndex)
            items.insert(
                ClipboardItem(
                    id: existing.id,
                    content: existing.content,
                    createdAt: Date(),
                    isPinned: existing.isPinned
                ),
                at: 0
            )
            return
        }

        items.insert(ClipboardItem(content: normalized), at: 0)

        if items.count > maxItems,
           let dropIndex = items.lastIndex(where: { !$0.isPinned }) {
            items.remove(at: dropIndex)
        }
    }
}
