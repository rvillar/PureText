import AppKit

/// Renders an individual tab in the custom tab strip, including selection and close actions.
final class TabStripItemView: NSView {
    private let titleButton = NSButton(title: "", target: nil, action: nil)
    private let closeButton = NSButton()
    private let stackView = NSStackView()
    private let spacerView = NSView()

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
        NSSize(width: 164, height: 22)
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
        layer?.cornerRadius = 5
        layer?.borderWidth = 1
        layer?.shadowOffset = .zero
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
        titleButton.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

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
        closeButton.setContentCompressionResistancePriority(.required, for: .horizontal)

        spacerView.translatesAutoresizingMaskIntoConstraints = false
        spacerView.setContentHuggingPriority(.defaultLow, for: .horizontal)
        spacerView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
    }

    private func configureLayout() {
        stackView.orientation = .horizontal
        stackView.alignment = .centerY
        stackView.spacing = 4
        stackView.edgeInsets = NSEdgeInsets(top: 2, left: 6, bottom: 2, right: 6)
        stackView.translatesAutoresizingMaskIntoConstraints = false

        titleButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.translatesAutoresizingMaskIntoConstraints = false

        addSubview(stackView)
        stackView.addArrangedSubview(titleButton)
        stackView.addArrangedSubview(spacerView)
        stackView.addArrangedSubview(closeButton)

        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            widthAnchor.constraint(greaterThanOrEqualToConstant: 120),
            spacerView.widthAnchor.constraint(greaterThanOrEqualToConstant: 0),
            closeButton.widthAnchor.constraint(equalToConstant: 14),
            closeButton.heightAnchor.constraint(equalToConstant: 14),
        ])
    }

    private func applySelectionStyle() {
        let backgroundColor = isSelected ? selectedBackgroundColor : idleBackgroundColor
        let borderColor = isSelected ? selectedBorderColor : idleBorderColor

        layer?.backgroundColor = backgroundColor.cgColor
        layer?.borderColor = borderColor.cgColor
        layer?.borderWidth = isSelected ? 2 : 1
        layer?.shadowColor = selectedShadowColor.cgColor
        layer?.shadowOpacity = isSelected ? 0.18 : 0
        layer?.shadowRadius = isSelected ? 3 : 0

        titleButton.contentTintColor = isSelected ? selectedForegroundColor : .secondaryLabelColor
        closeButton.contentTintColor = isSelected ? selectedForegroundColor : .secondaryLabelColor
    }

    private var selectedBackgroundColor: NSColor {
        dynamicColor(
            light: NSColor(calibratedRed: 0.82, green: 0.88, blue: 0.98, alpha: 1.0),
            dark: NSColor(calibratedRed: 0.22, green: 0.30, blue: 0.44, alpha: 1.0)
        )
    }

    private var idleBackgroundColor: NSColor {
        dynamicColor(light: NSColor(calibratedWhite: 0.93, alpha: 1.0),
                     dark: NSColor(calibratedWhite: 0.16, alpha: 1.0))
    }

    private var selectedBorderColor: NSColor {
        dynamicColor(
            light: NSColor(calibratedRed: 0.34, green: 0.52, blue: 0.83, alpha: 1.0),
            dark: NSColor(calibratedRed: 0.44, green: 0.62, blue: 0.95, alpha: 1.0)
        )
    }

    private var idleBorderColor: NSColor {
        dynamicColor(light: NSColor(calibratedWhite: 0.84, alpha: 1.0),
                     dark: NSColor(calibratedWhite: 0.22, alpha: 1.0))
    }

    private var selectedForegroundColor: NSColor {
        dynamicColor(
            light: NSColor(calibratedWhite: 0.12, alpha: 1.0),
            dark: NSColor(calibratedWhite: 0.98, alpha: 1.0)
        )
    }

    private var selectedShadowColor: NSColor {
        dynamicColor(
            light: NSColor(calibratedWhite: 0.18, alpha: 1.0),
            dark: NSColor(calibratedRed: 0.06, green: 0.09, blue: 0.14, alpha: 1.0)
        )
    }

    private func dynamicColor(light: NSColor, dark: NSColor) -> NSColor {
        let match = effectiveAppearance.bestMatch(from: [.darkAqua, .aqua])
        return match == .darkAqua ? dark : light
    }
}
