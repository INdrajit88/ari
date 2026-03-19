import SwiftUI

@main
struct ClipboardManagerApp: App {
    @StateObject private var store = ClipboardStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store)
                .frame(minWidth: 720, minHeight: 520)
        }
        .windowStyle(.titleBar)
        .windowToolbarStyle(.unified(showsTitle: true))
    }
}
