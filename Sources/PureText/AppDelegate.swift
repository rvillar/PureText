import AppKit

/// Coordinates app lifecycle events and builds the top-level macOS menus.
final class AppDelegate: NSObject, NSApplicationDelegate {
    private let mainWindowController = MainWindowController()

    /// Creates the initial document tab and presents the main window.
    func applicationDidFinishLaunching(_ notification: Notification) {
        buildMainMenu()
        if !mainWindowController.hasOpenDocuments {
            mainWindowController.createUntitledDocument()
        }
        mainWindowController.presentWindow()
        NSApp.activate(ignoringOtherApps: true)
    }

    /// Closes the application when the last window is closed.
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        true
    }

    /// Gives the main window a chance to confirm unsaved changes before quitting.
    func applicationShouldTerminate(_ sender: NSApplication) -> NSApplication.TerminateReply {
        mainWindowController.confirmCloseForApplicationTermination() ? .terminateNow : .terminateCancel
    }

    /// Opens files delivered by Finder, Dock drop, or the Launch Services document flow.
    func application(_ sender: NSApplication, openFiles filenames: [String]) {
        if !filenames.isEmpty {
            mainWindowController.discardInitialEmptyDocumentIfNeeded()
        }
        let urls = filenames.map { URL(fileURLWithPath: $0) }
        mainWindowController.openDocuments(at: urls)
        mainWindowController.presentWindow()
        sender.reply(toOpenOrPrint: .success)
    }

    /// Reopens the main window and recreates an untitled tab if needed.
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        mainWindowController.presentWindow()

        if !mainWindowController.hasOpenDocuments {
            mainWindowController.createUntitledDocument()
        }

        return true
    }

    @objc private func newDocument(_ sender: Any?) {
        mainWindowController.newDocumentAction(sender)
    }

    @objc private func openDocument(_ sender: Any?) {
        mainWindowController.openDocumentAction(sender)
    }

    @objc private func saveDocument(_ sender: Any?) {
        mainWindowController.saveDocumentAction(sender)
    }

    @objc private func saveDocumentAs(_ sender: Any?) {
        mainWindowController.saveDocumentAsAction(sender)
    }

    @objc private func closeDocument(_ sender: Any?) {
        mainWindowController.closeDocumentAction(sender)
    }

    @objc private func formatDocument(_ sender: Any?) {
        mainWindowController.formatDocumentAction(sender)
    }

    /// Builds the standard macOS menu bar for the application.
    private func buildMainMenu() {
        let mainMenu = NSMenu()
        mainMenu.addItem(buildApplicationMenu())
        mainMenu.addItem(buildFileMenu())
        mainMenu.addItem(buildEditMenu())
        NSApp.mainMenu = mainMenu
    }

    private func buildApplicationMenu() -> NSMenuItem {
        let appItem = NSMenuItem()
        let submenu = NSMenu()

        submenu.addItem(withTitle: L10n.aboutApp, action: #selector(NSApplication.orderFrontStandardAboutPanel(_:)), keyEquivalent: "")
        submenu.addItem(.separator())
        submenu.addItem(withTitle: L10n.quitApp, action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
        appItem.submenu = submenu
        return appItem
    }

    private func buildFileMenu() -> NSMenuItem {
        let fileItem = NSMenuItem(title: L10n.fileMenu, action: nil, keyEquivalent: "")
        let submenu = NSMenu(title: L10n.fileMenu)

        submenu.addItem(withTitle: L10n.newTab, action: #selector(newDocument(_:)), keyEquivalent: "n").target = self
        submenu.addItem(withTitle: L10n.open, action: #selector(openDocument(_:)), keyEquivalent: "o").target = self
        submenu.addItem(.separator())
        submenu.addItem(withTitle: L10n.save, action: #selector(saveDocument(_:)), keyEquivalent: "s").target = self
        submenu.addItem(withTitle: L10n.saveAs, action: #selector(saveDocumentAs(_:)), keyEquivalent: "S").target = self
        submenu.addItem(.separator())
        submenu.addItem(withTitle: L10n.formatContent, action: #selector(formatDocument(_:)), keyEquivalent: "F").target = self
        submenu.addItem(.separator())
        submenu.addItem(withTitle: L10n.closeTab, action: #selector(closeDocument(_:)), keyEquivalent: "w").target = self

        fileItem.submenu = submenu
        return fileItem
    }

    private func buildEditMenu() -> NSMenuItem {
        let editItem = NSMenuItem(title: L10n.editMenu, action: nil, keyEquivalent: "")
        let submenu = NSMenu(title: L10n.editMenu)

        submenu.addItem(withTitle: L10n.undo, action: Selector(("undo:")), keyEquivalent: "z")
        submenu.addItem(withTitle: L10n.redo, action: Selector(("redo:")), keyEquivalent: "Z")
        submenu.addItem(.separator())
        submenu.addItem(withTitle: L10n.cut, action: #selector(NSText.cut(_:)), keyEquivalent: "x")
        submenu.addItem(withTitle: L10n.copy, action: #selector(NSText.copy(_:)), keyEquivalent: "c")
        submenu.addItem(withTitle: L10n.paste, action: #selector(NSText.paste(_:)), keyEquivalent: "v")
        submenu.addItem(withTitle: L10n.selectAll, action: #selector(NSText.selectAll(_:)), keyEquivalent: "a")

        editItem.submenu = submenu
        return editItem
    }
}
