import Foundation

enum PureTextCoreLanguage {
    case englishUS
    case portugueseBrazil

    static var current: PureTextCoreLanguage {
        let preferred = Locale.preferredLanguages.first?.lowercased() ?? "en"
        return preferred.hasPrefix("pt") ? .portugueseBrazil : .englishUS
    }
}

enum PureTextCoreL10n {
    static func formattingUnavailable(for fileType: String) -> String {
        localized(
            english: "Formatting is not available for \(fileType) files.",
            portuguese: "A formatação não está disponível para arquivos \(fileType)."
        )
    }

    static var invalidUTF8Content: String {
        localized(
            english: "The content could not be converted to UTF-8.",
            portuguese: "O conteúdo não pôde ser convertido para UTF-8."
        )
    }

    static func invalidLineJSON(line: Int, detail: String) -> String {
        localized(
            english: "Line \(line) of the LJSON file does not contain valid JSON. \(detail)",
            portuguese: "A linha \(line) do arquivo LJSON não contém um JSON válido. \(detail)"
        )
    }

    private static func localized(english: String, portuguese: String) -> String {
        switch PureTextCoreLanguage.current {
        case .englishUS:
            return english
        case .portugueseBrazil:
            return portuguese
        }
    }
}
