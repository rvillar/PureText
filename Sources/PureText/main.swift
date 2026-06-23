import AppKit

/// Boots the AppKit application and hands lifecycle control to `AppDelegate`.
MainActor.assumeIsolated {
    let application = NSApplication.shared
    let delegate = AppDelegate()

    application.setActivationPolicy(.regular)
    application.delegate = delegate
    application.run()
}
