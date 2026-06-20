import Foundation

/// Stores the editable state for a single open file or untitled tab.
final class EditorDocument {
    /// Stable identifier used to differentiate open tabs in memory.
    let id = UUID()
    /// The on-disk location of the document when it has been opened or saved.
    var url: URL?
    /// The semantic file type used for file dialogs and formatting support.
    var fileType: NoteFileType
    /// The string encoding used for reading and writing the file contents.
    var encoding: String.Encoding
    private let untitledDisplayName: String?

    /// The editable text currently shown in the editor.
    private(set) var content: String
    private var savedContent: String

    /// Callback invoked when the edited state or file metadata changes.
    var onStateChange: (() -> Void)?

    /// Creates a document model for a saved file or a new untitled tab.
    init(
        url: URL? = nil,
        fileType: NoteFileType = .txt,
        content: String = "",
        encoding: String.Encoding = .utf8,
        untitledDisplayName: String? = nil
    ) {
        self.url = url
        self.fileType = fileType
        self.content = content
        self.savedContent = content
        self.encoding = encoding
        self.untitledDisplayName = untitledDisplayName
    }

    /// The name shown in the tab bar and window title.
    var displayName: String {
        url?.lastPathComponent ?? untitledDisplayName ?? "Untitle"
    }

    /// The default file name suggested when saving an untitled document.
    var suggestedFilename: String {
        url?.lastPathComponent ?? "\(displayName).\(fileType.defaultExtension)"
    }

    /// Indicates whether the in-memory content differs from the last saved content.
    var isEdited: Bool {
        content != savedContent
    }

    /// Updates the current content and notifies listeners when the value changes.
    func updateContent(_ newContent: String) {
        guard content != newContent else { return }
        content = newContent
        onStateChange?()
    }

    /// Marks the document as saved and updates the persisted file metadata.
    func markSaved(
        url: URL? = nil,
        fileType: NoteFileType? = nil,
        encoding: String.Encoding? = nil
    ) {
        if let url {
            self.url = url
        }

        if let fileType {
            self.fileType = fileType
        }

        if let encoding {
            self.encoding = encoding
        }

        savedContent = content
        onStateChange?()
    }
}
