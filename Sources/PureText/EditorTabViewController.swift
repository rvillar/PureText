import AppKit

/// Hosts the plain-text editor view for a single open tab.
final class EditorTabViewController: NSViewController, NSTextViewDelegate {
    /// The document model currently edited by this tab.
    let document: EditorDocument

    private let scrollView = NSScrollView()
    private let textView = NSTextView()
    private var isApplyingProgrammaticChange = false

    /// Creates an editor controller bound to a document model.
    init(document: EditorDocument) {
        self.document = document
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }

    /// Loads the plain-text editor view hierarchy.
    override func loadView() {
        view = NSView()
        configureTextView()
        configureLayout()
        refreshContent()
        refreshTabState()
    }

    /// Refreshes the editor text from the current document content.
    func refreshContent() {
        guard isViewLoaded else { return }
        textView.string = document.content
    }

    /// Replaces the editor text without re-triggering the text-change observer loop.
    func replaceContent(_ newContent: String) {
        isApplyingProgrammaticChange = true
        textView.string = newContent
        isApplyingProgrammaticChange = false
        document.updateContent(newContent)
    }

    /// Synchronizes the tab title and edited indicator with the document state.
    func refreshTabState() {
        title = tabTitle
        view.window?.isDocumentEdited = document.isEdited
        view.window?.title = document.displayName
    }

    /// The title rendered in the custom tab strip.
    var tabTitle: String {
        document.displayName + (document.isEdited ? " •" : "")
    }

    /// Propagates user edits back to the document model.
    func textDidChange(_ notification: Notification) {
        guard !isApplyingProgrammaticChange else { return }
        document.updateContent(textView.string)
    }

    private func configureTextView() {
        textView.delegate = self
        textView.isRichText = false
        textView.importsGraphics = false
        textView.allowsUndo = true
        textView.isAutomaticQuoteSubstitutionEnabled = false
        textView.isAutomaticDashSubstitutionEnabled = false
        textView.isAutomaticTextReplacementEnabled = false
        textView.usesFindPanel = true
        textView.isVerticallyResizable = true
        textView.isHorizontallyResizable = false
        textView.autoresizingMask = [.width]
        textView.minSize = NSSize(width: 0, height: 0)
        textView.maxSize = NSSize(
            width: CGFloat.greatestFiniteMagnitude,
            height: CGFloat.greatestFiniteMagnitude
        )
        textView.textContainerInset = NSSize(width: 16, height: 16)
        textView.textContainer?.lineFragmentPadding = 0
        textView.textContainer?.widthTracksTextView = true
        textView.font = NSFont.monospacedSystemFont(ofSize: 13, weight: .regular)
        textView.backgroundColor = .textBackgroundColor
        textView.textColor = .textColor
        textView.insertionPointColor = .textColor

        scrollView.borderType = .noBorder
        scrollView.drawsBackground = true
        scrollView.backgroundColor = .textBackgroundColor
        scrollView.hasVerticalScroller = true
        scrollView.hasHorizontalScroller = false
        scrollView.autohidesScrollers = true
        scrollView.documentView = textView
    }

    private func configureLayout() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)

        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
}
