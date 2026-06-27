import SwiftUI

@main
struct PureTextiOSApp: App {
    @Environment(\.scenePhase) private var scenePhase
    @StateObject private var session = EditorSessionStore()

    var body: some Scene {
        WindowGroup {
            EditorScreen()
                .environmentObject(session)
                .onAppear {
                    session.bootstrapIfNeeded()
                }
        }
        .onChange(of: scenePhase) { newPhase in
            switch newPhase {
            case .inactive, .background:
                session.persistSessionDraftIfNeeded()
            case .active:
                break
            @unknown default:
                break
            }
        }
    }
}
