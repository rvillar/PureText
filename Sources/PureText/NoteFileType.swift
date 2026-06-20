import Foundation
import UniformTypeIdentifiers

/// Enumerates the file extensions that PureText can open, save, and optionally format.
enum NoteFileType: String, CaseIterable {
    case txt
    case md
    case csv
    case yml
    case bru
    case pom
    case json
    case ljson
    case xml
    case html

    /// Resolves a file type from a URL extension.
    static func from(url: URL) -> NoteFileType? {
        NoteFileType(rawValue: url.pathExtension.lowercased())
    }

    /// A short display label used in errors and diagnostics.
    var displayName: String {
        rawValue.uppercased()
    }

    /// The default extension suggested for newly saved files of this type.
    var defaultExtension: String {
        rawValue
    }

    /// Indicates whether the editor offers a formatting command for the file type.
    var isFormattingSupported: Bool {
        switch self {
        case .json, .ljson, .xml, .html, .pom:
            return true
        case .txt, .md, .csv, .yml, .bru:
            return false
        }
    }

    /// The Uniform Type Identifier used by Finder dialogs and document registration.
    var utType: UTType? {
        switch self {
        case .txt:
            return .plainText
        case .md:
            return UTType(filenameExtension: "md", conformingTo: .plainText)
        case .csv:
            return UTType(filenameExtension: "csv") ?? .commaSeparatedText
        case .yml:
            return UTType("com.fnt.puretext.yml")
        case .bru:
            return UTType("com.fnt.puretext.bru")
        case .pom:
            return UTType("com.fnt.puretext.pom")
        case .json:
            return .json
        case .ljson:
            return UTType("com.fnt.puretext.ljson")
        case .xml:
            return .xml
        case .html:
            return .html
        }
    }

    /// All supported content types exposed to open and save panels.
    static var supportedContentTypes: [UTType] {
        allCases.compactMap(\.utType)
    }
}
