import Foundation
import PureTextCore

struct SessionDraftStore {
    private struct DraftSnapshot: Codable {
        let content: String
        let fileTypeRawValue: String
        let encodingRawValue: UInt
        let displayName: String
    }

    private let fileManager = FileManager.default

    func save(_ document: EditorDocument) throws {
        let snapshot = DraftSnapshot(
            content: document.content,
            fileTypeRawValue: document.fileType.rawValue,
            encodingRawValue: document.encoding.rawValue,
            displayName: document.displayName
        )

        let data = try JSONEncoder().encode(snapshot)
        let fileURL = try draftFileURL()
        try fileManager.createDirectory(
            at: fileURL.deletingLastPathComponent(),
            withIntermediateDirectories: true,
            attributes: nil
        )
        try data.write(to: fileURL, options: .atomic)
    }

    func load() -> EditorDocument? {
        do {
            let data = try Data(contentsOf: draftFileURL())
            let snapshot = try JSONDecoder().decode(DraftSnapshot.self, from: data)
            let fileType = NoteFileType(rawValue: snapshot.fileTypeRawValue) ?? .txt
            let encoding = String.Encoding(rawValue: snapshot.encodingRawValue)

            return EditorDocument(
                fileType: fileType,
                content: snapshot.content,
                encoding: encoding,
                untitledDisplayName: "Recovered \(snapshot.displayName)"
            )
        } catch {
            return nil
        }
    }

    func clear() {
        guard let fileURL = try? draftFileURL() else { return }
        try? fileManager.removeItem(at: fileURL)
    }

    private func draftFileURL() throws -> URL {
        let baseDirectory = try fileManager.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )

        return baseDirectory
            .appendingPathComponent("PureTextiOS", isDirectory: true)
            .appendingPathComponent("EditorSessionDraft.json", isDirectory: false)
    }
}
