import Foundation
import UniformTypeIdentifiers

/// Enumerates the file extensions that PureText can open, save, and optionally format.
public enum NoteFileType: String, CaseIterable, Sendable {
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
    public static func from(url: URL) -> NoteFileType? {
        NoteFileType(rawValue: url.pathExtension.lowercased())
    }

    /// A short display label used in errors and diagnostics.
    public var displayName: String {
        rawValue.uppercased()
    }

    /// The default extension suggested for newly saved files of this type.
    public var defaultExtension: String {
        rawValue
    }

    /// Indicates whether the editor offers a formatting command for the file type.
    public var isFormattingSupported: Bool {
        switch self {
        case .json, .ljson, .xml, .html, .pom:
            return true
        case .txt, .md, .csv, .yml, .bru:
            return false
        }
    }

    /// The Uniform Type Identifier used by file pickers and document registration.
    public var utType: UTType? {
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

    /// All supported content types exposed to open and save flows.
    public static var supportedContentTypes: [UTType] {
        allCases.compactMap(\.utType)
    }
}
