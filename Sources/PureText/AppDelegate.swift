import AppKit

/// Coordinates app lifecycle events and builds the top-level macOS menus.
@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate, NSMenuDelegate {
    private let mainWindowController = MainWindowController()
    private let openRecentSubmenu = NSMenu()
    private let showSpecialCharactersMenuItem = NSMenuItem()

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

    @objc private func openRecentDocument(_ sender: Any?) {
        guard let menuItem = sender as? NSMenuItem, let url = menuItem.representedObject as? URL else {
            return
        }

        mainWindowController.openDocuments(at: [url])
        mainWindowController.presentWindow()
    }

    @objc private func saveDocument(_ sender: Any?) {
        mainWindowController.saveDocumentAction(sender)
    }

    @objc private func clearRecentDocuments(_ sender: Any?) {
        NSDocumentController.shared.clearRecentDocuments(sender)
        rebuildOpenRecentMenu()
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

    @objc private func uppercaseSelection(_ sender: Any?) {
        mainWindowController.uppercaseSelectionAction(sender)
    }

    @objc private func lowercaseSelection(_ sender: Any?) {
        mainWindowController.lowercaseSelectionAction(sender)
    }

    @objc private func properSelection(_ sender: Any?) {
        mainWindowController.properSelectionAction(sender)
    }

    @objc private func toggleSpecialCharactersVisibility(_ sender: Any?) {
        mainWindowController.toggleSpecialCharactersVisibilityAction(sender)
        synchronizeViewMenuState()
    }

    /// Builds the standard macOS menu bar for the application.
    private func buildMainMenu() {
        let mainMenu = NSMenu()
        mainMenu.addItem(buildApplicationMenu())
        mainMenu.addItem(buildFileMenu())
        mainMenu.addItem(buildEditMenu())
        mainMenu.addItem(buildViewMenu())
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
        submenu.addItem(buildOpenRecentMenu())
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

    private func buildOpenRecentMenu() -> NSMenuItem {
        openRecentSubmenu.title = L10n.openRecent
        openRecentSubmenu.delegate = self
        rebuildOpenRecentMenu()

        let item = NSMenuItem(title: L10n.openRecent, action: nil, keyEquivalent: "")
        item.submenu = openRecentSubmenu
        return item
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
        submenu.addItem(.separator())
        submenu.addItem(buildFindMenu())
        submenu.addItem(buildTransformSelectionMenu())

        editItem.submenu = submenu
        return editItem
    }

    private func buildViewMenu() -> NSMenuItem {
        let viewItem = NSMenuItem(title: L10n.viewMenu, action: nil, keyEquivalent: "")
        let submenu = NSMenu(title: L10n.viewMenu)

        showSpecialCharactersMenuItem.title = L10n.showSpecialCharacters
        showSpecialCharactersMenuItem.action = #selector(toggleSpecialCharactersVisibility(_:))
        showSpecialCharactersMenuItem.target = self
        submenu.addItem(showSpecialCharactersMenuItem)
        synchronizeViewMenuState()

        viewItem.submenu = submenu
        return viewItem
    }

    private func buildFindMenu() -> NSMenuItem {
        let item = NSMenuItem(title: L10n.findMenu, action: nil, keyEquivalent: "")
        let submenu = NSMenu(title: L10n.findMenu)

        submenu.addItem(makeTextFinderMenuItem(
            title: L10n.find,
            action: .showFindInterface,
            keyEquivalent: "f"
        ))
        submenu.addItem(makeTextFinderMenuItem(
            title: L10n.findNext,
            action: .nextMatch,
            keyEquivalent: "g"
        ))
        submenu.addItem(makeTextFinderMenuItem(
            title: L10n.findPrevious,
            action: .previousMatch,
            keyEquivalent: "g",
            modifiers: [.command, .shift]
        ))
        submenu.addItem(.separator())
        submenu.addItem(makeTextFinderMenuItem(
            title: L10n.useSelectionForFind,
            action: .setSearchString,
            keyEquivalent: "e"
        ))
        submenu.addItem(.separator())
        submenu.addItem(makeTextFinderMenuItem(
            title: L10n.replace,
            action: .showReplaceInterface,
            keyEquivalent: "f",
            modifiers: [.command, .option]
        ))

        item.submenu = submenu
        return item
    }

    private func buildTransformSelectionMenu() -> NSMenuItem {
        let item = NSMenuItem(title: L10n.transformSelectionMenu, action: nil, keyEquivalent: "")
        let submenu = NSMenu(title: L10n.transformSelectionMenu)

        submenu.addItem(withTitle: L10n.uppercaseSelection, action: #selector(uppercaseSelection(_:)), keyEquivalent: "").target = self
        submenu.addItem(withTitle: L10n.lowercaseSelection, action: #selector(lowercaseSelection(_:)), keyEquivalent: "").target = self
        submenu.addItem(withTitle: L10n.properSelection, action: #selector(properSelection(_:)), keyEquivalent: "").target = self

        item.submenu = submenu
        return item
    }

    private func makeTextFinderMenuItem(
        title: String,
        action: NSTextFinder.Action,
        keyEquivalent: String,
        modifiers: NSEvent.ModifierFlags = [.command]
    ) -> NSMenuItem {
        let item = NSMenuItem(
            title: title,
            action: #selector(NSResponder.performTextFinderAction(_:)),
            keyEquivalent: keyEquivalent
        )
        item.keyEquivalentModifierMask = modifiers
        item.tag = action.rawValue
        return item
    }

    func menuNeedsUpdate(_ menu: NSMenu) {
        guard menu == openRecentSubmenu else { return }
        rebuildOpenRecentMenu()
    }

    private func rebuildOpenRecentMenu() {
        openRecentSubmenu.removeAllItems()

        let recentURLs = NSDocumentController.shared.recentDocumentURLs
        if recentURLs.isEmpty {
            let emptyItem = NSMenuItem(title: L10n.noRecentDocuments, action: nil, keyEquivalent: "")
            emptyItem.isEnabled = false
            openRecentSubmenu.addItem(emptyItem)
            return
        }

        for url in recentURLs {
            let item = NSMenuItem(title: url.lastPathComponent, action: #selector(openRecentDocument(_:)), keyEquivalent: "")
            item.target = self
            item.representedObject = url
            item.toolTip = url.path
            openRecentSubmenu.addItem(item)
        }

        openRecentSubmenu.addItem(.separator())
        openRecentSubmenu.addItem(withTitle: L10n.clearMenu, action: #selector(clearRecentDocuments(_:)), keyEquivalent: "").target = self
    }

    private func synchronizeViewMenuState() {
        showSpecialCharactersMenuItem.state = mainWindowController.isShowingSpecialCharacters ? .on : .off
    }
}
