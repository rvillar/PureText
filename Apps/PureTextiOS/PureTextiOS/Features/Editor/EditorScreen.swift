import SwiftUI
import UniformTypeIdentifiers
import PureTextCore

struct EditorScreen: View {
    @EnvironmentObject private var session: EditorSessionStore

    @State private var showingImporter = false
    @State private var showingExporter = false
    @State private var exportDocument = PlainTextFileDocument(text: "")

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                if let notice = session.recoveredDraftNotice {
                    noticeBanner(notice)
                }

                PlainTextView(
                    text: Binding(
                        get: { session.document.content },
                        set: { session.updateContent($0) }
                    )
                )
            }
            .navigationTitle(session.navigationTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarLeading) {
                    Button {
                        session.createNewDocument()
                    } label: {
                        Image(systemName: "square.and.pencil")
                    }

                    Button {
                        showingImporter = true
                    } label: {
                        Image(systemName: "folder")
                    }
                }

                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    fileTypeMenu

                    if session.canFormatCurrentDocument {
                        Button {
                            session.formatCurrentDocument()
                        } label: {
                            Image(systemName: "text.alignleft")
                        }
                    }

                    Button {
                        if session.document.url == nil {
                            exportDocument = session.prepareExportDocument()
                            showingExporter = true
                        } else {
                            _ = session.saveToCurrentLocation()
                        }
                    } label: {
                        Image(systemName: session.document.url == nil ? "square.and.arrow.down" : "square.and.arrow.down.fill")
                    }
                }
            }
        }
        .navigationViewStyle(.stack)
        .fileImporter(
            isPresented: $showingImporter,
            allowedContentTypes: NoteFileType.supportedContentTypes,
            allowsMultipleSelection: false
        ) { result in
            switch result {
            case .success(let urls):
                if let url = urls.first {
                    session.importDocument(from: url)
                }
            case .failure(let error):
                session.errorMessage = error.localizedDescription
            }
        }
        .fileExporter(
            isPresented: $showingExporter,
            document: exportDocument,
            contentType: session.document.fileType.utType ?? .plainText,
            defaultFilename: session.document.suggestedFilename
        ) { result in
            switch result {
            case .success(let url):
                session.exportDocument(to: url)
            case .failure(let error):
                session.errorMessage = error.localizedDescription
            }
        }
        .alert("PureText", isPresented: alertBinding) {
            Button("OK", role: .cancel) {
                session.dismissError()
            }
        } message: {
            Text(session.errorMessage ?? "")
        }
    }

    private var alertBinding: Binding<Bool> {
        Binding(
            get: { session.errorMessage != nil },
            set: { presented in
                if !presented {
                    session.dismissError()
                }
            }
        )
    }

    private var fileTypeMenu: some View {
        Menu {
            ForEach(NoteFileType.allCases, id: \.rawValue) { fileType in
                Button(fileType.displayName) {
                    session.selectFileType(fileType)
                }
            }
        } label: {
            Text(session.document.fileType.displayName)
                .font(.caption.weight(.semibold))
        }
    }

    private func noticeBanner(_ notice: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: "clock.arrow.trianglehead.counterclockwise.rotate.90")
                .foregroundColor(.accentColor)

            Text(notice)
                .font(.caption)
                .frame(maxWidth: .infinity, alignment: .leading)

            Button("Dismiss") {
                session.dismissRecoveredDraftNotice()
            }
            .font(.caption.weight(.semibold))
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(Color(.systemYellow).opacity(0.18))
    }
}

#Preview {
    EditorScreen()
        .environmentObject(EditorSessionStore())
}
