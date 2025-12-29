import Cocoa

class SaveViewController: NSViewController {

    // UI prvky
    private let textView = FormTextView()
    private let linkField = NSTextField()
    private let tagsField = NSTextField()
    private let noteField = NSTextField()

    private let saveButton = FocusableButton(title: "Save", target: nil, action: nil)
    private let closeButton = FocusableButton(title: "Close", target: nil, action: nil)

    override func loadView() {
        self.view = NSView()
        self.view.translatesAutoresizingMaskIntoConstraints = false
        setupUI()
        loadFromClipboard()
    }

    // MARK: - UI

    private func setupUI() {

        // Labels
        let textLabel = FormLabel("Note text")
        let linkLabel = FormLabel("Link")
        let tagsLabel = FormLabel("Tags")
        let noteLabel = FormLabel("Short note")

        // TextView (multiline)
        textView.isRichText = false
        textView.font = NSFont.systemFont(ofSize: 13)
        textView.isVerticallyResizable = true
        textView.textContainerInset = NSSize(width: 6, height: 6)
        textView.isAutomaticTextCompletionEnabled = false
        textView.isAutomaticTextReplacementEnabled = false
        textView.isAutomaticQuoteSubstitutionEnabled = false
        textView.isAutomaticDashSubstitutionEnabled = false
        textView.isAutomaticSpellingCorrectionEnabled = false
        textView.isAutomaticDataDetectionEnabled = false

        textView.allowsUndo = true
        textView.isRichText = false


        let textScroll = NSScrollView()
        textScroll.documentView = textView
        textScroll.hasVerticalScroller = true
        textScroll.borderType = .bezelBorder
        textScroll.translatesAutoresizingMaskIntoConstraints = false
        //textScroll.refusesFirstResponder = true //

        // Text fields
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
        
        // Layout
        let stack = NSStackView(views: [
            textLabel,
            textScroll,
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
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.alignment = .left

        view.addSubview(stack)
        
        let h = textScroll.heightAnchor.constraint(equalToConstant: 140)
        h.priority = .defaultHigh
        h.isActive = true
        
        textView.nextKeyView = linkField
        linkField.nextKeyView = tagsField
        tagsField.nextKeyView = noteField
        noteField.nextKeyView = saveButton
        saveButton.nextKeyView = closeButton
        closeButton.nextKeyView = textView

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: view.topAnchor, constant: 12),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -12),
            stack.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -12),

            textScroll.heightAnchor.constraint(equalToConstant: 140)
        ])
    }

    // MARK: - Buttons
    
    private func buttonsStack() -> NSView {
        let stack = NSStackView(views: [
            saveButton,
            closeButton
        ])

        stack.orientation = .horizontal
        stack.alignment = .centerY
        stack.spacing = 8

        return stack
    }

    // MARK: - Clipboard
    
    func extractFirstURL(from text: String) -> URL? {
        let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
        let range = NSRange(text.startIndex..., in: text)
        
        let match = detector?.firstMatch(in: text, options: [], range: range)
        return match?.url
    }

    private func loadFromClipboard() {
        let pb = NSPasteboard.general
        guard let content = pb.string(forType: .string) else { return }

        if let url = extractFirstURL(from: content) {
            linkField.stringValue = url.absoluteString
        } else {
            textView.string = content
        }
    }
    
    // MARK: - ESC close dialog
    
    override func cancelOperation(_ sender: Any?) {
        close()
    }

    
    // MARK: -
    override func viewDidAppear() {
        super.viewDidAppear()
        view.window?.standardWindowButton(.closeButton)?.target = self
        view.window?.standardWindowButton(.closeButton)?.action = #selector(close)
       
        DispatchQueue.main.async {
            self.view.window?.makeFirstResponder(self.textView)
        }
    }

    // MARK: - Actions

    @objc private func save() {
        SQLiteManager.shared.insert(
               text: textView.string,
               link: linkField.stringValue,
               tags: tagsField.stringValue,
               note: noteField.stringValue
           )

       self.view.window?.close()
    }

    @objc private func close() {
        self.view.window?.close()
    }
    
}
