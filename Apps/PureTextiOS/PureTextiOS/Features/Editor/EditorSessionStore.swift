import Foundation
import SwiftUI
import UniformTypeIdentifiers
import PureTextCore

@MainActor
final class EditorSessionStore: ObservableObject {
    @Published private(set) var document: EditorDocument
    @Published var errorMessage: String?
    @Published var recoveredDraftNotice: String?

    private let draftStore = SessionDraftStore()
    private var hasBootstrapped = false

    init(document: EditorDocument = EditorSessionStore.makeUntitledDocument()) {
        self.document = document
        bindStateChanges(for: document)
    }

    var navigationTitle: String {
        document.displayName + (document.isEdited ? " *" : "")
    }

    var statusSummary: String {
        let fileType = document.fileType.displayName
        let saveState = document.url == nil ? "Untitled" : "Saved File"
        let editState = document.isEdited ? "Unsaved changes" : "Up to date"
        return "\(fileType) • \(saveState) • \(editState)"
    }

    var canFormatCurrentDocument: Bool {
        document.fileType.isFormattingSupported
    }

    func bootstrapIfNeeded() {
        guard !hasBootstrapped else { return }
        hasBootstrapped = true

        if let restored = draftStore.load() {
            setDocument(restored)
            recoveredDraftNotice = "Recovered the draft from the previous session."
        }
    }

    func dismissRecoveredDraftNotice() {
        recoveredDraftNotice = nil
    }

    func dismissError() {
        errorMessage = nil
    }

    func createNewDocument() {
        setDocument(Self.makeUntitledDocument())
        recoveredDraftNotice = nil
        draftStore.clear()
    }

    func updateContent(_ newContent: String) {
        document.updateContent(newContent)
    }

    func selectFileType(_ fileType: NoteFileType) {
        guard document.fileType != fileType else { return }
        document.fileType = fileType
        document.onStateChange?()
    }

    func formatCurrentDocument() {
        do {
            let formatted = try DocumentFormatter.format(document.content, as: document.fileType)
            document.updateContent(formatted)
        } catch {
            present(error)
        }
    }

    func prepareExportDocument() -> PlainTextFileDocument {
        PlainTextFileDocument(text: document.content, encoding: document.encoding)
    }

    func importDocument(from url: URL) {
        do {
            let fileType = NoteFileType.from(url: url) ?? .txt
            var encoding: String.Encoding = .utf8
            let accessGranted = url.startAccessingSecurityScopedResource()
            defer {
                if accessGranted {
                    url.stopAccessingSecurityScopedResource()
                }
            }

            let content = try String(contentsOf: url, usedEncoding: &encoding)
            let document = EditorDocument(
                url: url,
                fileType: fileType,
                content: content,
                encoding: encoding
            )
            setDocument(document)
            recoveredDraftNotice = nil
            draftStore.clear()
        } catch {
            present(error)
        }
    }

    @discardableResult
    func saveToCurrentLocation() -> Bool {
        guard let url = document.url else {
            errorMessage = "This document does not have a saved location yet."
            return false
        }

        return persistDocument(to: url)
    }

    func exportDocument(to url: URL) {
        _ = persistDocument(to: normalizedExportURL(from: url))
    }

    func persistSessionDraftIfNeeded() {
        guard shouldPersistDraft else {
            draftStore.clear()
            return
        }

        do {
            try draftStore.save(document)
        } catch {
            present(error)
        }
    }

    private var shouldPersistDraft: Bool {
        document.isEdited || (document.url == nil && !document.content.isEmpty)
    }

    private func present(_ error: Error) {
        errorMessage = error.localizedDescription
    }

    private func persistDocument(to url: URL) -> Bool {
        do {
            let normalizedURL = normalizedExportURL(from: url)
            let accessGranted = normalizedURL.startAccessingSecurityScopedResource()
            defer {
                if accessGranted {
                    normalizedURL.stopAccessingSecurityScopedResource()
                }
            }

            try document.content.write(to: normalizedURL, atomically: true, encoding: document.encoding)
            let fileType = NoteFileType.from(url: normalizedURL) ?? document.fileType
            document.markSaved(url: normalizedURL, fileType: fileType, encoding: document.encoding)
            draftStore.clear()
            recoveredDraftNotice = nil
            return true
        } catch {
            present(error)
            return false
        }
    }

    private func normalizedExportURL(from url: URL) -> URL {
        guard url.pathExtension.isEmpty else { return url }
        return url.appendingPathExtension(document.fileType.defaultExtension)
    }

    private func setDocument(_ document: EditorDocument) {
        bindStateChanges(for: document)
        self.document = document
        objectWillChange.send()
    }

    private func bindStateChanges(for document: EditorDocument) {
        document.onStateChange = { [weak self] in
            self?.objectWillChange.send()
        }
    }

    private static func makeUntitledDocument() -> EditorDocument {
        EditorDocument(
            fileType: .txt,
            content: "",
            encoding: .utf8,
            untitledDisplayName: "Untitled"
        )
    }
}
