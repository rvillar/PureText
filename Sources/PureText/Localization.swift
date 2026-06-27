import Foundation

/// Resolves a lightweight app language from the current macOS preferred language list.
enum AppLanguage {
    case englishUS
    case portugueseBrazil

    /// The language selected from the current system preferences.
    static var current: AppLanguage {
        let preferred = Locale.preferredLanguages.first?.lowercased() ?? "en"
        return preferred.hasPrefix("pt") ? .portugueseBrazil : .englishUS
    }
}

/// Centralizes user-facing strings so the app can follow the macOS language.
enum L10n {
    /// The localized application display name.
    static let appName = "PureText"

    /// Localized string for the About application menu item.
    static var aboutApp: String {
        localized(
            english: "About \(appName)",
            portuguese: "Sobre \(appName)"
        )
    }

    /// Localized string for the Quit application menu item.
    static var quitApp: String {
        localized(
            english: "Quit \(appName)",
            portuguese: "Encerrar \(appName)"
        )
    }

    /// Localized string for the File menu title.
    static var fileMenu: String {
        localized(english: "File", portuguese: "Arquivo")
    }

    /// Localized string for the Edit menu title.
    static var editMenu: String {
        localized(english: "Edit", portuguese: "Editar")
    }

    /// Localized string for the View menu title.
    static var viewMenu: String {
        localized(english: "View", portuguese: "Visualizar")
    }

    /// Localized string for the Find submenu title.
    static var findMenu: String {
        localized(english: "Find", portuguese: "Localizar")
    }

    /// Localized string for opening the search UI.
    static var find: String {
        localized(english: "Find…", portuguese: "Localizar…")
    }

    /// Localized string for moving to the next match.
    static var findNext: String {
        localized(english: "Find Next", portuguese: "Localizar Próxima")
    }

    /// Localized string for moving to the previous match.
    static var findPrevious: String {
        localized(english: "Find Previous", portuguese: "Localizar Anterior")
    }

    /// Localized string for using the current selection as the search text.
    static var useSelectionForFind: String {
        localized(english: "Use Selection for Find", portuguese: "Usar Seleção para Localizar")
    }

    /// Localized string for opening the replace UI.
    static var replace: String {
        localized(english: "Replace…", portuguese: "Substituir…")
    }

    /// Localized string for toggling the display of special characters.
    static var showSpecialCharacters: String {
        localized(
            english: "Show Tabs, Enters, and Linefeeds",
            portuguese: "Exibir Tab, Enter e Linefeed"
        )
    }

    /// Localized string for the selection-transform submenu title.
    static var transformSelectionMenu: String {
        localized(english: "Transform Selection", portuguese: "Transformar Seleção")
    }

    /// Localized string for uppercasing the selection.
    static var uppercaseSelection: String {
        localized(english: "Uppercase", portuguese: "Maiúsculas")
    }

    /// Localized string for lowercasing the selection.
    static var lowercaseSelection: String {
        localized(english: "Lowercase", portuguese: "Minúsculas")
    }

    /// Localized string for proper-casing the selection.
    static var properSelection: String {
        localized(english: "Proper", portuguese: "Iniciais Maiúsculas")
    }

    /// Localized string for the New Tab command.
    static var newTab: String {
        localized(english: "New Tab", portuguese: "Nova Aba")
    }

    /// Localized string for the Open command.
    static var open: String {
        localized(english: "Open…", portuguese: "Abrir…")
    }

    /// Localized string for the Open Recent submenu title.
    static var openRecent: String {
        localized(english: "Open Recent", portuguese: "Abrir Recentes")
    }

    /// Localized string for an empty recent-documents list.
    static var noRecentDocuments: String {
        localized(english: "No Recent Documents", portuguese: "Nenhum Documento Recente")
    }

    /// Localized string for clearing the recent-documents list.
    static var clearMenu: String {
        localized(english: "Clear Menu", portuguese: "Limpar Menu")
    }

    /// Localized string for the Save command.
    static var save: String {
        localized(english: "Save", portuguese: "Salvar")
    }

    /// Localized string for the Save As command.
    static var saveAs: String {
        localized(english: "Save As…", portuguese: "Salvar Como…")
    }

    /// Localized string for the content formatting command.
    static var formatContent: String {
        localized(english: "Format Content", portuguese: "Formatar Conteúdo")
    }

    /// Localized string for the Close Tab command.
    static var closeTab: String {
        localized(english: "Close Tab", portuguese: "Fechar Aba")
    }

    /// Localized string for the Undo command.
    static var undo: String {
        localized(english: "Undo", portuguese: "Desfazer")
    }

    /// Localized string for the Redo command.
    static var redo: String {
        localized(english: "Redo", portuguese: "Refazer")
    }

    /// Localized string for the Cut command.
    static var cut: String {
        localized(english: "Cut", portuguese: "Recortar")
    }

    /// Localized string for the Copy command.
    static var copy: String {
        localized(english: "Copy", portuguese: "Copiar")
    }

    /// Localized string for the Paste command.
    static var paste: String {
        localized(english: "Paste", portuguese: "Colar")
    }

    /// Localized string for the Select All command.
    static var selectAll: String {
        localized(english: "Select All", portuguese: "Selecionar Tudo")
    }

    /// Localized string for the New Tab toolbar item.
    static var newTabToolbar: String {
        newTab
    }

    /// Localized string for the Open toolbar item.
    static var openToolbar: String {
        localized(english: "Open", portuguese: "Abrir")
    }

    /// Localized string for the Save toolbar item.
    static var saveToolbar: String {
        save
    }

    /// Localized string for the Format toolbar item.
    static var formatToolbar: String {
        localized(english: "Format", portuguese: "Formatar")
    }

    /// Localized title for generic open-file failures.
    static var couldNotOpenFile: String {
        localized(english: "Could not open file", portuguese: "Não foi possível abrir o arquivo")
    }

    /// Localized title for formatting failures.
    static var couldNotFormatContent: String {
        localized(english: "Could not format content", portuguese: "Não foi possível formatar o conteúdo")
    }

    /// Localized title for save failures.
    static var couldNotSaveFile: String {
        localized(english: "Could not save file", portuguese: "Não foi possível salvar o arquivo")
    }

    /// Localized error used when the file extension is unsupported.
    static var unsupportedFileType: String {
        localized(english: "The file type is not supported.", portuguese: "O tipo do arquivo não é suportado.")
    }

    /// Localized text for the tab close button accessibility description.
    static var closeTabAccessibility: String {
        localized(english: "Close tab", portuguese: "Fechar aba")
    }

    /// Localized prompt asking whether changes should be saved.
    static func saveChangesPrompt(for documentName: String) -> String {
        localized(
            english: "Save changes to \(documentName)?",
            portuguese: "Salvar alterações em \(documentName)?"
        )
    }

    /// Localized explanation shown when unsaved changes would be lost.
    static var unsavedChangesWarning: String {
        localized(
            english: "Unsaved changes will be lost if you continue without saving.",
            portuguese: "As alterações não salvas serão perdidas se você continuar sem salvar."
        )
    }

    /// Localized string for the Don't Save button.
    static var dontSave: String {
        localized(english: "Don't Save", portuguese: "Não Salvar")
    }

    /// Localized string for the Cancel button.
    static var cancel: String {
        localized(english: "Cancel", portuguese: "Cancelar")
    }

    /// Localized string for formatter unavailability.
    static func formattingUnavailable(for fileType: String) -> String {
        localized(
            english: "Formatting is not available for \(fileType) files.",
            portuguese: "A formatação não está disponível para arquivos \(fileType)."
        )
    }

    /// Localized string for UTF-8 conversion failures.
    static var invalidUTF8Content: String {
        localized(
            english: "The content could not be converted to UTF-8.",
            portuguese: "O conteúdo não pôde ser convertido para UTF-8."
        )
    }

    /// Localized string for invalid line-delimited JSON input.
    static func invalidLineJSON(line: Int, detail: String) -> String {
        localized(
            english: "Line \(line) of the LJSON file does not contain valid JSON. \(detail)",
            portuguese: "A linha \(line) do arquivo LJSON não contém um JSON válido. \(detail)"
        )
    }

    private static func localized(english: String, portuguese: String) -> String {
        switch AppLanguage.current {
        case .englishUS:
            return english
        case .portugueseBrazil:
            return portuguese
        }
    }
}
