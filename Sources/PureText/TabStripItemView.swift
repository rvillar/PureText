import AppKit

/// Renders an individual tab in the custom tab strip, including selection and close actions.
final class TabStripItemView: NSView {
    private let titleButton = NSButton(title: "", target: nil, action: nil)
    private let closeButton = NSButton()
    private let stackView = NSStackView()

    /// Called when the user selects the tab body.
    var onSelect: (() -> Void)?
    /// Called when the user requests that the tab be closed.
    var onClose: (() -> Void)?

    /// The title rendered across the selectable tab surface.
    var title: String = "" {
        didSet {
            titleButton.title = title
            titleButton.toolTip = title
        }
    }

    /// Indicates whether the tab is the currently selected tab.
    var isSelected: Bool = false {
        didSet {
            applySelectionStyle()
        }
    }

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        configureView()
        configureButtons()
        configureLayout()
        applySelectionStyle()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }

    override var intrinsicContentSize: NSSize {
        NSSize(width: 164, height: 26)
    }

    /// Refreshes adaptive colors when the system appearance changes.
    override func viewDidChangeEffectiveAppearance() {
        super.viewDidChangeEffectiveAppearance()
        applySelectionStyle()
    }

    /// Treats clicks on the tab body as a selection action.
    override func mouseDown(with event: NSEvent) {
        let location = convert(event.locationInWindow, from: nil)
        if closeButton.frame.contains(location) {
            super.mouseDown(with: event)
            return
        }

        onSelect?()
    }

    @objc private func selectTab(_ sender: Any?) {
        onSelect?()
    }

    @objc private func closeTab(_ sender: Any?) {
        onClose?()
    }

    private func configureView() {
        wantsLayer = true
        layer?.cornerRadius = 6
        layer?.borderWidth = 1
        translatesAutoresizingMaskIntoConstraints = false
    }

    private func configureButtons() {
        titleButton.isBordered = false
        titleButton.bezelStyle = .regularSquare
        titleButton.setButtonType(.momentaryChange)
        titleButton.alignment = .left
        titleButton.lineBreakMode = .byTruncatingTail
        titleButton.font = NSFont.systemFont(ofSize: 11, weight: .medium)
        titleButton.contentTintColor = .labelColor
        titleButton.target = self
        titleButton.action = #selector(selectTab(_:))
        titleButton.setButtonType(.momentaryChange)
        titleButton.focusRingType = .none
        titleButton.imagePosition = .noImage

        closeButton.isBordered = false
        closeButton.bezelStyle = .regularSquare
        closeButton.setButtonType(.momentaryChange)
        closeButton.image = NSImage(
            systemSymbolName: "xmark",
            accessibilityDescription: L10n.closeTabAccessibility
        )
        closeButton.imagePosition = .imageOnly
        closeButton.contentTintColor = .secondaryLabelColor
        closeButton.target = self
        closeButton.action = #selector(closeTab(_:))
        closeButton.focusRingType = .none
    }

    private func configureLayout() {
        stackView.orientation = .horizontal
        stackView.alignment = .centerY
        stackView.spacing = 6
        stackView.edgeInsets = NSEdgeInsets(top: 3, left: 6, bottom: 3, right: 8)
        stackView.translatesAutoresizingMaskIntoConstraints = false

        titleButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.translatesAutoresizingMaskIntoConstraints = false

        addSubview(stackView)
        stackView.addArrangedSubview(closeButton)
        stackView.addArrangedSubview(titleButton)

        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            widthAnchor.constraint(greaterThanOrEqualToConstant: 120),
            closeButton.widthAnchor.constraint(equalToConstant: 14),
            closeButton.heightAnchor.constraint(equalToConstant: 14),
        ])
    }

    private func applySelectionStyle() {
        let backgroundColor = isSelected ? selectedBackgroundColor : idleBackgroundColor
        let borderColor = isSelected ? selectedBorderColor : idleBorderColor

        layer?.backgroundColor = backgroundColor.cgColor
        layer?.borderColor = borderColor.cgColor
        titleButton.contentTintColor = isSelected ? .labelColor : .secondaryLabelColor
        closeButton.contentTintColor = isSelected ? .labelColor : .secondaryLabelColor
    }

    private var selectedBackgroundColor: NSColor {
        dynamicColor(light: NSColor(calibratedWhite: 0.86, alpha: 1.0),
                     dark: NSColor(calibratedWhite: 0.24, alpha: 1.0))
    }

    private var idleBackgroundColor: NSColor {
        dynamicColor(light: NSColor(calibratedWhite: 0.93, alpha: 1.0),
                     dark: NSColor(calibratedWhite: 0.16, alpha: 1.0))
    }

    private var selectedBorderColor: NSColor {
        dynamicColor(light: NSColor(calibratedWhite: 0.70, alpha: 1.0),
                     dark: NSColor(calibratedWhite: 0.34, alpha: 1.0))
    }

    private var idleBorderColor: NSColor {
        dynamicColor(light: NSColor(calibratedWhite: 0.84, alpha: 1.0),
                     dark: NSColor(calibratedWhite: 0.22, alpha: 1.0))
    }

    private func dynamicColor(light: NSColor, dark: NSColor) -> NSColor {
        let match = effectiveAppearance.bestMatch(from: [.darkAqua, .aqua])
        return match == .darkAqua ? dark : light
    }
}
