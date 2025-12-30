import Cocoa

final class SaveViewController: NSViewController, NSTextViewDelegate {

    // MARK: - UI

    private let textView = NSTextView()
    private let linkField = NSTextField()
    private let tagsField = NSTextField()
    private let noteField = NSTextField()

    private let saveButton = FocusableButton(title: "Save", target: nil, action: nil)
    private let closeButton = FocusableButton(title: "Close", target: nil, action: nil)

    // MARK: - Lifecycle

    override func loadView() {
        view = NSView()
        setupUI()
        loadFromClipboard()
    }

    // MARK: - UI setup

    private func setupUI() {

        let textLabel = FormLabel("Note text")
        let linkLabel = FormLabel("Link")
        let tagsLabel = FormLabel("Tags")
        let noteLabel = FormLabel("Short note")

        // Multiline NSTextField setup
        let scrollView = NSScrollView()
        scrollView.hasVerticalScroller = true
        scrollView.hasHorizontalScroller = false
        scrollView.autohidesScrollers = true
        scrollView.borderType = .bezelBorder
        scrollView.drawsBackground = true
        scrollView.backgroundColor = .textBackgroundColor

        
        textView.isRichText = false
        textView.allowsUndo = true

        textView.font = .systemFont(ofSize: NSFont.systemFontSize)

        textView.isAutomaticQuoteSubstitutionEnabled = false
        textView.isAutomaticDashSubstitutionEnabled = false
        textView.isAutomaticTextReplacementEnabled = false
        textView.isAutomaticSpellingCorrectionEnabled = false
        textView.isAutomaticDataDetectionEnabled = false

        // důležité pro multiline
        textView.isVerticallyResizable = true
        textView.isHorizontallyResizable = false
        textView.textContainer?.widthTracksTextView = true
        textView.textContainer?.layoutManager?.allowsNonContiguousLayout = false
        textView.importsGraphics = false
        textView.delegate = self
        textView.backgroundColor = .textBackgroundColor
        textView.insertionPointColor = .labelColor
        
        textView.backgroundColor = NSColor.textBackgroundColor.usingColorSpace(.deviceRGB)!

        textView.drawsBackground = true

        textView.textColor = NSColor.controlTextColor.usingColorSpace(.deviceRGB)
        textView.insertionPointColor = NSColor.controlTextColor.usingColorSpace(.deviceRGB)
        
        textView.font = .systemFont(ofSize: NSFont.systemFontSize)

        
        scrollView.documentView = textView
        scrollView.layer?.cornerRadius = 6
        scrollView.layer?.masksToBounds = true
        scrollView.focusRingType = .default


        // Other fields
        linkField.placeholderString = "https://..."
        tagsField.placeholderString = "deploy, prod"
        noteField.placeholderString = "note"

        // Buttons
        saveButton.target = self
        saveButton.action = #selector(save)
        saveButton.keyEquivalent = "s"
        saveButton.keyEquivalentModifierMask = [.command]

        closeButton.target = self
        closeButton.action = #selector(close)
        closeButton.keyEquivalent = "w"
        closeButton.keyEquivalentModifierMask = [.command]

        let separator = NSBox()
        separator.boxType = .separator

        let stack = NSStackView(views: [
            textLabel,
            scrollView,
            linkLabel,
            linkField,
            tagsLabel,
            tagsField,
            noteLabel,
            noteField,
            separator,
            buttonsStack()
        ])

        stack.orientation = .vertical
        stack.spacing = 8
        stack.alignment = .leading
        stack.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: view.topAnchor, constant: 12),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -12),
            stack.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -12),

            scrollView.heightAnchor.constraint(equalToConstant: 140)
        ])

        // TAB order
        textView.nextKeyView = linkField
        linkField.nextKeyView = tagsField
        tagsField.nextKeyView = noteField
        noteField.nextKeyView = textView
    }

    private func buttonsStack() -> NSView {
        let stack = NSStackView(views: [saveButton, closeButton])
        stack.orientation = .horizontal
        stack.spacing = 8
        return stack
    }

    // MARK: - Clipboard

    private func loadFromClipboard() {
        let pb = NSPasteboard.general
        guard let content = pb.string(forType: .string) else { return }

        if let url = extractFirstURL(from: content) {
            linkField.stringValue = url.absoluteString
        } else {
            textView.string = content
        }
    }

    private func extractFirstURL(from text: String) -> URL? {
        let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
        let range = NSRange(text.startIndex..., in: text)
        return detector?.firstMatch(in: text, options: [], range: range)?.url
    }

    // MARK: - Actions

    @objc private func save() {
        SQLiteManager.shared.insert(
            text: textView.string,
            link: linkField.stringValue,
            tags: tagsField.stringValue,
            note: noteField.stringValue
        )
        close()
    }

    @objc private func close() {
        view.window?.close()
    }

    override func cancelOperation(_ sender: Any?) {
        close()
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        DispatchQueue.main.async {
            self.view.window?.makeFirstResponder(self.textView)
        }
    }

    // MARK: - NSTextViewDelegate
    func textView(_ textView: NSTextView,
                  doCommandBy commandSelector: Selector) -> Bool {

        switch commandSelector {
        case #selector(NSResponder.insertTab(_:)):
            view.window?.selectNextKeyView(nil)
            return true

        case #selector(NSResponder.insertBacktab(_:)):
            view.window?.selectPreviousKeyView(nil)
            return true

        default:
            return false
        }
    }

}
