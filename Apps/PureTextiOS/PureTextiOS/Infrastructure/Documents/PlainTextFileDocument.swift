import Foundation
import SwiftUI
import UniformTypeIdentifiers
import PureTextCore

struct PlainTextFileDocument: FileDocument {
    static var readableContentTypes: [UTType] {
        NoteFileType.supportedContentTypes
    }

    let text: String
    let encoding: String.Encoding

    init(text: String, encoding: String.Encoding = .utf8) {
        self.text = text
        self.encoding = encoding
    }

    init(configuration: ReadConfiguration) throws {
        let data = configuration.file.regularFileContents ?? Data()
        self.text = String(decoding: data, as: UTF8.self)
        self.encoding = .utf8
    }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        guard let data = text.data(using: encoding) ?? text.data(using: .utf8) else {
            throw CocoaError(.fileWriteInapplicableStringEncoding)
        }

        return .init(regularFileWithContents: data)
    }
}
