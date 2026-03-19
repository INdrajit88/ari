import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var store: ClipboardStore
    @State private var selectedItemID: ClipboardItem.ID?

    var body: some View {
        NavigationSplitView {
            List(store.filteredItems, selection: $selectedItemID) { item in
                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 8) {
                        if item.isPinned {
                            Image(systemName: "pin.fill")
                                .foregroundStyle(.orange)
                        }

                        Text(item.preview)
                            .lineLimit(2)
                            .font(.body)

                        Spacer()

                        Text(item.createdAt, style: .time)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    Text(item.content)
                        .lineLimit(1)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 4)
                .contextMenu {
                    Button("Copy Again") {
                        store.copy(item: item)
                    }

                    Button(item.isPinned ? "Unpin" : "Pin") {
                        store.togglePin(item: item)
                    }

                    Divider()

                    Button(role: .destructive) {
                        store.delete(item: item)
                    } label: {
                        Text("Delete")
                    }
                }
            }
            .searchable(text: $store.searchText, prompt: "Search your clipboard")
            .navigationTitle("PasteMe Lite")
            .toolbar {
                ToolbarItemGroup {
                    Button {
                        store.clearUnpinned()
                    } label: {
                        Label("Clear Unpinned", systemImage: "trash")
                    }
                    .help("Remove only non-pinned items")
                }
            }
        } detail: {
            if let item = store.filteredItems.first(where: { $0.id == selectedItemID }) {
                ClipboardDetailView(item: item)
                    .environmentObject(store)
            } else {
                ContentUnavailableView(
                    "No Clipboard Item Selected",
                    systemImage: "doc.on.clipboard",
                    description: Text("Copy text anywhere on your Mac to start building history.")
                )
            }
        }
    }
}

private struct ClipboardDetailView: View {
    @EnvironmentObject private var store: ClipboardStore
    let item: ClipboardItem

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Label(item.createdAt.formatted(date: .abbreviated, time: .shortened), systemImage: "clock")
                    .foregroundStyle(.secondary)

                if item.isPinned {
                    Label("Pinned", systemImage: "pin.fill")
                        .foregroundStyle(.orange)
                }
            }

            ScrollView {
                Text(item.content)
                    .textSelection(.enabled)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            HStack {
                Button {
                    store.copy(item: item)
                } label: {
                    Label("Copy to Clipboard", systemImage: "doc.on.doc")
                }

                Button(item.isPinned ? "Unpin" : "Pin") {
                    store.togglePin(item: item)
                }

                Spacer()
            }
        }
        .padding(24)
    }
}
