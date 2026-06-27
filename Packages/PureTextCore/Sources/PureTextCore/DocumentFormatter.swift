import Foundation

/// Errors returned by the content formatter when a file cannot be reformatted safely.
public enum DocumentFormatterError: LocalizedError, Sendable {
    case formattingUnavailable(NoteFileType)
    case invalidTextEncoding
    case invalidLineJSON(line: Int, underlying: String)

    public var errorDescription: String? {
        switch self {
        case .formattingUnavailable(let fileType):
            return PureTextCoreL10n.formattingUnavailable(for: fileType.displayName)
        case .invalidTextEncoding:
            return PureTextCoreL10n.invalidUTF8Content
        case .invalidLineJSON(let line, let underlying):
            return PureTextCoreL10n.invalidLineJSON(line: line, detail: underlying)
        }
    }
}

/// Formats supported plain-text content types while preserving a text-only editing model.
public enum DocumentFormatter {
    /// Formats text according to the file type-specific rules.
    public static func format(_ text: String, as fileType: NoteFileType) throws -> String {
        switch fileType {
        case .json:
            return try prettyPrintedJSON(text)
        case .ljson:
            return try prettyPrintedLineJSON(text)
        case .xml:
            return try prettyPrintedXML(text)
        case .html, .pom:
            return try prettyPrintedHTML(text)
        case .txt, .md, .csv, .yml, .bru:
            throw DocumentFormatterError.formattingUnavailable(fileType)
        }
    }

    private static func prettyPrintedJSON(_ text: String) throws -> String {
        guard let data = text.data(using: .utf8) else {
            throw DocumentFormatterError.invalidTextEncoding
        }

        let object = try JSONSerialization.jsonObject(with: data)
        let formatted = try JSONSerialization.data(
            withJSONObject: object,
            options: [.prettyPrinted, .sortedKeys]
        )
        return String(decoding: formatted, as: UTF8.self)
    }

    private static func prettyPrintedLineJSON(_ text: String) throws -> String {
        if let formatted = try? prettyPrintedJSON(text) {
            return formatted
        }

        let lines = text.split(whereSeparator: \.isNewline)
        let formattedLines = try lines.enumerated().map { index, line in
            do {
                return try prettyPrintedJSON(String(line))
            } catch {
                throw DocumentFormatterError.invalidLineJSON(
                    line: index + 1,
                    underlying: error.localizedDescription
                )
            }
        }

        return formattedLines.joined(separator: "\n")
    }

    private static func prettyPrintedXML(_ text: String) throws -> String {
        try prettyPrintedMarkup(text, mode: .xml)
    }

    private static func prettyPrintedHTML(_ text: String) throws -> String {
        try prettyPrintedMarkup(text, mode: .html)
    }

    private static func prettyPrintedMarkup(_ text: String, mode: MarkupMode) throws -> String {
        let normalized = text.replacingOccurrences(of: "\r\n", with: "\n")
        let tokens = tokenizeMarkup(normalized)
        var lines: [String] = []
        var indentation = 0

        for token in tokens {
            let trimmedToken = token.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmedToken.isEmpty else { continue }

            if isClosingTag(trimmedToken) {
                indentation = max(indentation - 1, 0)
            }

            if trimmedToken.hasPrefix("<") {
                lines.append(indented(trimmedToken, level: indentation))

                if shouldIncreaseIndentation(for: trimmedToken, mode: mode) {
                    indentation += 1
                }
            } else {
                let textLines = trimmedToken
                    .split(separator: "\n")
                    .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                    .filter { !$0.isEmpty }

                for textLine in textLines {
                    lines.append(indented(textLine, level: indentation))
                }
            }
        }

        return lines.joined(separator: "\n")
    }

    private static func tokenizeMarkup(_ text: String) -> [String] {
        var tokens: [String] = []
        var buffer = ""
        var insideTag = false

        for character in text {
            if character == "<" {
                let trimmedBuffer = buffer.trimmingCharacters(in: .whitespacesAndNewlines)
                if !trimmedBuffer.isEmpty {
                    tokens.append(trimmedBuffer)
                }

                buffer = "<"
                insideTag = true
                continue
            }

            if character == ">", insideTag {
                buffer.append(character)
                tokens.append(buffer)
                buffer = ""
                insideTag = false
                continue
            }

            buffer.append(character)
        }

        let trimmedBuffer = buffer.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmedBuffer.isEmpty {
            tokens.append(trimmedBuffer)
        }

        return tokens
    }

    private static func shouldIncreaseIndentation(for token: String, mode: MarkupMode) -> Bool {
        guard token.hasPrefix("<") else { return false }
        guard !isClosingTag(token) else { return false }
        guard !token.hasPrefix("<?"), !token.hasPrefix("<!") else { return false }
        guard !token.hasSuffix("/>") else { return false }

        if mode == .html {
            let tagName = htmlTagName(from: token)
            if htmlVoidTags.contains(tagName) {
                return false
            }
        }

        return true
    }

    private static func htmlTagName(from token: String) -> String {
        let inner = token
            .trimmingCharacters(in: CharacterSet(charactersIn: "<>/"))
            .split(whereSeparator: \.isWhitespace)
            .first ?? ""
        return inner.lowercased()
    }

    private static func isClosingTag(_ token: String) -> Bool {
        token.hasPrefix("</")
    }

    private static func indented(_ text: String, level: Int) -> String {
        String(repeating: "    ", count: level) + text
    }
}

private enum MarkupMode {
    case xml
    case html
}

private let htmlVoidTags: Set<String> = [
    "area", "base", "br", "col", "embed", "hr", "img", "input",
    "link", "meta", "param", "source", "track", "wbr",
]
