import SwiftUI
import UIKit

struct PlainTextView: UIViewRepresentable {
    @Binding var text: String

    func makeCoordinator() -> Coordinator {
        Coordinator(text: $text)
    }

    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.delegate = context.coordinator
        textView.backgroundColor = .systemBackground
        textView.textColor = .label
        textView.font = .monospacedSystemFont(ofSize: 13, weight: .regular)
        textView.adjustsFontForContentSizeCategory = false
        textView.autocapitalizationType = .none
        textView.autocorrectionType = .no
        textView.smartDashesType = .no
        textView.smartQuotesType = .no
        textView.smartInsertDeleteType = .no
        textView.spellCheckingType = .no
        textView.keyboardDismissMode = .interactive
        textView.alwaysBounceVertical = true
        textView.textContainer.lineFragmentPadding = 0
        textView.textContainerInset = UIEdgeInsets(top: 12, left: 12, bottom: 16, right: 12)
        textView.text = text
        return textView
    }

    func updateUIView(_ textView: UITextView, context: Context) {
        guard textView.text != text else { return }
        context.coordinator.isApplyingExternalUpdate = true
        textView.text = text
        context.coordinator.isApplyingExternalUpdate = false
    }

    final class Coordinator: NSObject, UITextViewDelegate {
        @Binding var text: String
        var isApplyingExternalUpdate = false

        init(text: Binding<String>) {
            self._text = text
        }

        func textViewDidChange(_ textView: UITextView) {
            guard !isApplyingExternalUpdate else { return }
            text = textView.text
        }
    }
}
