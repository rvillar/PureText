import AppKit
import PureTextCore

/// Owns the main application window, custom tab strip, and document lifecycle actions.
@MainActor
final class MainWindowController: NSObject, NSWindowDelegate, NSToolbarDelegate {
    enum SelectionTextTransform {
        case uppercase
        case lowercase
        case proper
    }

    private static let minimumWindowSize = NSSize(width: 920, height: 620)
    private static let defaultWindowSize = NSSize(width: 1040, height: 720)
    private static let tabStripHeight: CGFloat = 30

    let window: NSWindow

    private let rootView = NSView()
    private let tabScrollView = NSScrollView()
    private let tabStackView = NSStackView()
    private let contentContainerView = NSView()

    private var tabControllers: [EditorTabViewController] = []
    private var selectedTabIndex: Int?
    private var nextUntitledNumber = 1

    override init() {
        self.window = NSWindow(
            contentRect: NSRect(origin: .zero, size: Self.defaultWindowSize),
            styleMask: [.titled, .closable, .miniaturizable, .resizable],
            backing: .buffered,
            defer: false
        )

        super.init()

        configureWindow()
        configureContent()
        configureToolbar()
    }

    /// The currently open documents in tab order.
    var documents: [EditorDocument] {
        tabControllers.map(\.document)
    }

    /// Indicates whether at least one editor tab is open.
    var hasOpenDocuments: Bool {
        !tabControllers.isEmpty
    }

    /// Indicates whether any open document has unsaved changes.
    var hasEditedDocuments: Bool {
        documents.contains(where: \.isEdited)
    }

    /// Creates a new untitled tab and selects it.
    func createUntitledDocument() {
        let document = EditorDocument(untitledDisplayName: makeNextUntitledName())
        addDocument(document, select: true)
    }

    /// Presents the main window and keeps it visible on a valid screen.
    func presentWindow() {
        ensureWindowFrameIsVisible()
        window.makeKeyAndOrderFront(nil)
        window.orderFrontRegardless()
        NSApp.activate(ignoringOtherApps: true)
        currentTabController?.focusEditor()
    }

    /// Removes the bootstrapped empty tab when the app is opened directly with files.
    func discardInitialEmptyDocumentIfNeeded() {
        guard tabControllers.count == 1 else { return }
        let document = tabControllers[0].document
        guard document.url == nil, !document.isEdited, document.content.isEmpty else { return }
        closeDocument(at: 0, shouldCreateReplacementWhenEmpty: false)
    }

    /// Opens a collection of files and creates one tab per file.
    func openDocuments(at urls: [URL]) {
        for url in urls {
            do {
                try openDocument(at: url)
            } catch {
                presentErrorAlert(
                    title: L10n.couldNotOpenFile,
                    error: error
                )
            }
        }
    }

    /// Saves the currently selected tab using its existing file URL when available.
    func saveCurrentDocument() -> Bool {
        guard let tab = currentTabController else { return true }
        return save(document: tab.document)
    }

    /// Saves the currently selected tab to a user-selected destination.
    func saveCurrentDocumentAs() -> Bool {
        guard let tab = currentTabController else { return true }
        return saveAs(document: tab.document)
    }

    /// Opens the native macOS print flow for the currently selected tab.
    func printCurrentDocument(_ sender: Any?) {
        guard let tab = currentTabController else { return }
        tab.printContent(sender)
    }

    /// Closes the current tab after prompting for unsaved changes if needed.
    func closeCurrentDocument() {
        guard
            let index = currentTabIndex(),
            let tab = currentTabController
        else {
            return
        }

        guard confirmSaveIfNeeded(for: tab.document) else { return }
        closeDocument(at: index)
    }

    /// Applies file type-aware formatting to the current document when supported.
    func formatCurrentDocument() {
        guard let tab = currentTabController else { return }

        do {
            let formatted = try DocumentFormatter.format(tab.document.content, as: tab.document.fileType)
            tab.replaceContent(formatted)
        } catch {
            presentErrorAlert(
                title: L10n.couldNotFormatContent,
                error: error
            )
        }
    }

    /// Returns whether the application can terminate without losing unsaved work.
    func confirmCloseForApplicationTermination() -> Bool {
        for document in documents where document.isEdited {
            guard confirmSaveIfNeeded(for: document) else {
                return false
            }
        }

        return true
    }

    func windowWillClose(_ notification: Notification) {
        NSApp.terminate(nil)
    }

    @objc func newDocumentAction(_ sender: Any?) {
        createUntitledDocument()
    }

    @objc func openDocumentAction(_ sender: Any?) {
        let panel = NSOpenPanel()
        panel.canChooseDirectories = false
        panel.canChooseFiles = true
        panel.allowsMultipleSelection = true
        panel.allowedContentTypes = NoteFileType.supportedContentTypes

        guard panel.runModal() == .OK else { return }
        openDocuments(at: panel.urls)
        presentWindow()
    }

    @objc func saveDocumentAction(_ sender: Any?) {
        _ = saveCurrentDocument()
    }

    @objc func saveDocumentAsAction(_ sender: Any?) {
        _ = saveCurrentDocumentAs()
    }

    @objc func printDocumentAction(_ sender: Any?) {
        printCurrentDocument(sender)
    }

    @objc func closeDocumentAction(_ sender: Any?) {
        closeCurrentDocument()
    }

    @objc func formatDocumentAction(_ sender: Any?) {
        formatCurrentDocument()
    }

    @objc func uppercaseSelectionAction(_ sender: Any?) {
        transformSelectedText(.uppercase)
    }

    @objc func lowercaseSelectionAction(_ sender: Any?) {
        transformSelectedText(.lowercase)
    }

    @objc func properSelectionAction(_ sender: Any?) {
        transformSelectedText(.proper)
    }

    /// Configures the app window shell and restores its last saved frame when possible.
    private func configureWindow() {
        window.title = L10n.appName
        window.titlebarAppearsTransparent = false
        window.titleVisibility = .hidden
        window.toolbarStyle = .unifiedCompact
        window.tabbingMode = .disallowed
        window.minSize = Self.minimumWindowSize
        window.setFrameAutosaveName("PureTextMainWindow")
        window.isReleasedWhenClosed = false
        window.delegate = self
    }

    private func ensureWindowFrameIsVisible() {
        var frame = window.frame
        frame.size.width = max(frame.size.width, Self.minimumWindowSize.width)
        frame.size.height = max(frame.size.height, Self.minimumWindowSize.height)

        let visibleScreens = NSScreen.screens
        let isVisibleOnAnyScreen = visibleScreens.contains { screen in
            screen.visibleFrame.intersects(frame)
        }

        if !isVisibleOnAnyScreen {
            if let screen = NSScreen.main ?? visibleScreens.first {
                let visibleFrame = screen.visibleFrame
                frame.size.width = min(max(frame.size.width, Self.minimumWindowSize.width), visibleFrame.width)
                frame.size.height = min(max(frame.size.height, Self.minimumWindowSize.height), visibleFrame.height)
                frame.origin.x = visibleFrame.midX - (frame.width / 2)
                frame.origin.y = visibleFrame.midY - (frame.height / 2)
            } else {
                frame.size = Self.defaultWindowSize
            }
        }

        window.setFrame(frame, display: false)
    }

    /// Builds the custom tab strip and editor content container.
    private func configureContent() {
        rootView.translatesAutoresizingMaskIntoConstraints = false
        rootView.wantsLayer = true
        rootView.layer?.backgroundColor = NSColor.controlBackgroundColor.cgColor
        window.contentView = rootView

        tabScrollView.drawsBackground = true
        tabScrollView.backgroundColor = NSColor.controlBackgroundColor
        tabScrollView.borderType = .noBorder
        tabScrollView.hasHorizontalScroller = false
        tabScrollView.hasVerticalScroller = false
        tabScrollView.autohidesScrollers = true
        tabScrollView.translatesAutoresizingMaskIntoConstraints = false

        tabStackView.orientation = .horizontal
        tabStackView.alignment = .centerY
        tabStackView.spacing = 4
        tabStackView.edgeInsets = NSEdgeInsets(top: 2, left: 8, bottom: 2, right: 8)
        tabStackView.translatesAutoresizingMaskIntoConstraints = false

        let tabStripContentView = NSView()
        tabStripContentView.translatesAutoresizingMaskIntoConstraints = false
        tabStripContentView.wantsLayer = true
        tabStripContentView.layer?.backgroundColor = NSColor.controlBackgroundColor.cgColor
        tabStripContentView.addSubview(tabStackView)
        tabScrollView.documentView = tabStripContentView

        contentContainerView.translatesAutoresizingMaskIntoConstraints = false
        contentContainerView.wantsLayer = true
        contentContainerView.layer?.backgroundColor = NSColor.textBackgroundColor.cgColor

        rootView.addSubview(tabScrollView)
        rootView.addSubview(contentContainerView)

        NSLayoutConstraint.activate([
            tabScrollView.leadingAnchor.constraint(equalTo: rootView.leadingAnchor),
            tabScrollView.trailingAnchor.constraint(equalTo: rootView.trailingAnchor),
            tabScrollView.topAnchor.constraint(equalTo: rootView.topAnchor),
            tabScrollView.heightAnchor.constraint(equalToConstant: Self.tabStripHeight),

            contentContainerView.leadingAnchor.constraint(equalTo: rootView.leadingAnchor),
            contentContainerView.trailingAnchor.constraint(equalTo: rootView.trailingAnchor),
            contentContainerView.topAnchor.constraint(equalTo: tabScrollView.bottomAnchor),
            contentContainerView.bottomAnchor.constraint(equalTo: rootView.bottomAnchor),

            tabStackView.leadingAnchor.constraint(equalTo: tabStripContentView.leadingAnchor),
            tabStackView.trailingAnchor.constraint(equalTo: tabStripContentView.trailingAnchor),
            tabStackView.topAnchor.constraint(equalTo: tabStripContentView.topAnchor),
            tabStackView.bottomAnchor.constraint(equalTo: tabStripContentView.bottomAnchor),
            tabStackView.heightAnchor.constraint(equalTo: tabStripContentView.heightAnchor),
        ])
    }

    /// Creates the compact toolbar used for common document actions.
    private func configureToolbar() {
        let toolbar = NSToolbar(identifier: "PureTextToolbar")
        toolbar.displayMode = .iconOnly
        toolbar.sizeMode = .small
        toolbar.delegate = self
        toolbar.allowsUserCustomization = false
        window.toolbar = toolbar
    }

    private func makeNextUntitledName() -> String {
        defer { nextUntitledNumber += 1 }
        return "Untitle\(nextUntitledNumber)"
    }

    private func openDocument(at url: URL) throws {
        let normalizedURL = url.standardizedFileURL

        if let index = indexOfDocument(url: normalizedURL) {
            selectTab(at: index)
            return
        }

        guard let fileType = NoteFileType.from(url: normalizedURL) else {
            throw NSError(
                domain: "PureText",
                code: 1001,
                userInfo: [NSLocalizedDescriptionKey: L10n.unsupportedFileType]
            )
        }

        var encoding: String.Encoding = .utf8
        let content = try String(contentsOf: normalizedURL, usedEncoding: &encoding)
        let document = EditorDocument(
            url: normalizedURL,
            fileType: fileType,
            content: content,
            encoding: encoding
        )

        addDocument(document, select: true)
        noteRecentDocument(normalizedURL)
    }

    private func addDocument(_ document: EditorDocument, select: Bool) {
        let tab = EditorTabViewController(document: document)
        document.onStateChange = { [weak self, weak tab] in
            tab?.refreshTabState()
            self?.refreshTabBar()
            self?.synchronizeWindowState()
        }

        tabControllers.append(tab)
        refreshTabBar()

        if select {
            selectTab(at: tabControllers.count - 1)
        } else {
            synchronizeWindowState()
        }
    }

    private func currentTabIndex() -> Int? {
        guard let selectedTabIndex, tabControllers.indices.contains(selectedTabIndex) else {
            return nil
        }
        return selectedTabIndex
    }

    private var currentTabController: EditorTabViewController? {
        guard let index = currentTabIndex() else { return nil }
        return tabControllers[index]
    }

    private func indexOfDocument(url: URL) -> Int? {
        tabControllers.enumerated().first { _, tab in
            tab.document.url?.standardizedFileURL == url
        }?.offset
    }

    private func confirmSaveIfNeeded(for document: EditorDocument) -> Bool {
        guard document.isEdited else { return true }

        let alert = NSAlert()
        alert.alertStyle = .warning
        alert.messageText = L10n.saveChangesPrompt(for: document.displayName)
        alert.informativeText = L10n.unsavedChangesWarning
        alert.addButton(withTitle: L10n.save)
        alert.addButton(withTitle: L10n.dontSave)
        alert.addButton(withTitle: L10n.cancel)

        switch alert.runModal() {
        case .alertFirstButtonReturn:
            return save(document: document)
        case .alertSecondButtonReturn:
            return true
        default:
            return false
        }
    }

    private func save(document: EditorDocument) -> Bool {
        if let url = document.url {
            return persist(document: document, to: url)
        }

        return saveAs(document: document)
    }

    private func saveAs(document: EditorDocument) -> Bool {
        let panel = NSSavePanel()
        panel.canCreateDirectories = true
        panel.nameFieldStringValue = document.suggestedFilename

        if let utType = document.fileType.utType {
            panel.allowedContentTypes = [utType]
        } else {
            panel.allowedContentTypes = NoteFileType.supportedContentTypes
        }

        guard panel.runModal() == .OK, var url = panel.url else {
            return false
        }

        if url.pathExtension.isEmpty {
            url.appendPathExtension(document.fileType.defaultExtension)
        }

        return persist(document: document, to: url)
    }

    private func persist(document: EditorDocument, to url: URL) -> Bool {
        do {
            try document.content.write(to: url, atomically: true, encoding: document.encoding)
            let fileType = NoteFileType.from(url: url) ?? document.fileType
            document.markSaved(url: url, fileType: fileType, encoding: document.encoding)
            noteRecentDocument(url.standardizedFileURL)
            synchronizeWindowState()
            return true
        } catch {
            presentErrorAlert(
                title: L10n.couldNotSaveFile,
                error: error
            )
            return false
        }
    }

    private func selectTab(at index: Int) {
        guard tabControllers.indices.contains(index) else { return }

        clearCurrentContentView()
        selectedTabIndex = index

        let tab = tabControllers[index]
        let tabView = tab.view
        tabView.translatesAutoresizingMaskIntoConstraints = false
        contentContainerView.addSubview(tabView)

        NSLayoutConstraint.activate([
            tabView.leadingAnchor.constraint(equalTo: contentContainerView.leadingAnchor),
            tabView.trailingAnchor.constraint(equalTo: contentContainerView.trailingAnchor),
            tabView.topAnchor.constraint(equalTo: contentContainerView.topAnchor),
            tabView.bottomAnchor.constraint(equalTo: contentContainerView.bottomAnchor),
        ])

        refreshTabBar()
        synchronizeWindowState()
        tab.focusEditor()
    }

    private func clearCurrentContentView() {
        for subview in contentContainerView.subviews {
            subview.removeFromSuperview()
        }
    }

    private func closeDocument(at index: Int, shouldCreateReplacementWhenEmpty: Bool = true) {
        guard tabControllers.indices.contains(index) else { return }

        let closingSelectedTab = selectedTabIndex == index
        let closingTab = tabControllers.remove(at: index)
        closingTab.document.onStateChange = nil

        if closingSelectedTab {
            clearCurrentContentView()
            selectedTabIndex = nil
        } else if let selectedTabIndex, selectedTabIndex > index {
            self.selectedTabIndex = selectedTabIndex - 1
        }

        if tabControllers.isEmpty {
            refreshTabBar()
            synchronizeWindowState()

            if shouldCreateReplacementWhenEmpty {
                createUntitledDocument()
            }
            return
        }

        let nextIndex: Int
        if closingSelectedTab {
            nextIndex = min(index, tabControllers.count - 1)
        } else {
            nextIndex = self.selectedTabIndex ?? 0
        }

        refreshTabBar()
        selectTab(at: nextIndex)
    }

    private func refreshTabBar() {
        for view in tabStackView.arrangedSubviews {
            tabStackView.removeArrangedSubview(view)
            view.removeFromSuperview()
        }

        for (index, tab) in tabControllers.enumerated() {
            let itemView = TabStripItemView()
            itemView.title = tab.tabTitle
            itemView.isSelected = selectedTabIndex == index
            itemView.onSelect = { [weak self] in
                self?.selectTab(at: index)
            }
            itemView.onClose = { [weak self] in
                self?.closeDocumentFromTabBar(at: index)
            }
            tabStackView.addArrangedSubview(itemView)
        }
    }

    private func closeDocumentFromTabBar(at index: Int) {
        guard tabControllers.indices.contains(index) else { return }
        let document = tabControllers[index].document
        guard confirmSaveIfNeeded(for: document) else { return }
        closeDocument(at: index)
    }

    private func synchronizeWindowState() {
        for tab in tabControllers {
            tab.refreshTabState()
        }

        if let currentTabController {
            window.title = currentTabController.document.displayName
            window.isDocumentEdited = currentTabController.document.isEdited
        } else {
            window.title = L10n.appName
            window.isDocumentEdited = false
        }
    }

    private func transformSelectedText(_ transform: SelectionTextTransform) {
        guard let currentTabController else { return }

        currentTabController.focusEditor()

        switch transform {
        case .uppercase:
            currentTabController.transformSelectedText(.uppercase)
        case .lowercase:
            currentTabController.transformSelectedText(.lowercase)
        case .proper:
            currentTabController.transformSelectedText(.proper)
        }
    }

    private func noteRecentDocument(_ url: URL) {
        NSDocumentController.shared.noteNewRecentDocumentURL(url)
    }

    private func presentErrorAlert(title: String, error: Error) {
        let alert = NSAlert()
        alert.alertStyle = .critical
        alert.messageText = title
        alert.informativeText = error.localizedDescription
        alert.runModal()
    }

    func toolbarAllowedItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        [
            .newDocument,
            .openDocument,
            .saveDocument,
            .flexibleSpace,
            .formatDocument,
        ]
    }

    func toolbarDefaultItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        toolbarAllowedItemIdentifiers(toolbar)
    }

    func toolbar(
        _ toolbar: NSToolbar,
        itemForItemIdentifier itemIdentifier: NSToolbarItem.Identifier,
        willBeInsertedIntoToolbar flag: Bool
    ) -> NSToolbarItem? {
        let item = NSToolbarItem(itemIdentifier: itemIdentifier)
        item.target = self

        switch itemIdentifier {
        case .newDocument:
            item.label = L10n.newTabToolbar
            item.image = NSImage(systemSymbolName: "plus.square.on.square", accessibilityDescription: item.label)
            item.action = #selector(newDocumentAction(_:))
        case .openDocument:
            item.label = L10n.openToolbar
            item.image = NSImage(systemSymbolName: "folder", accessibilityDescription: item.label)
            item.action = #selector(openDocumentAction(_:))
        case .saveDocument:
            item.label = L10n.saveToolbar
            item.image = NSImage(systemSymbolName: "square.and.arrow.down", accessibilityDescription: item.label)
            item.action = #selector(saveDocumentAction(_:))
        case .formatDocument:
            item.label = L10n.formatToolbar
            item.image = NSImage(systemSymbolName: "text.alignleft", accessibilityDescription: item.label)
            item.action = #selector(formatDocumentAction(_:))
        default:
            return nil
        }

        return item
    }
}

private extension NSToolbarItem.Identifier {
    static let newDocument = NSToolbarItem.Identifier("PureTextToolbar.NewDocument")
    static let openDocument = NSToolbarItem.Identifier("PureTextToolbar.OpenDocument")
    static let saveDocument = NSToolbarItem.Identifier("PureTextToolbar.SaveDocument")
    static let formatDocument = NSToolbarItem.Identifier("PureTextToolbar.FormatDocument")
}
