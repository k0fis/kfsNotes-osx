import Cocoa

final class FormTextView: NSTextView {

    override func awakeFromNib() {
        super.awakeFromNib()

        isRichText = false
        allowsUndo = true

        backgroundColor = .clear
        drawsBackground = false

        textColor = .labelColor
        font = NSFont.systemFont(ofSize: NSFont.systemFontSize)

        typingAttributes = [
            .foregroundColor: NSColor.labelColor,
            .font: font!
        ]
    }

    // Při nastavování stringu vždy čistý text a správné atributy
    override var string: String {
        didSet {
            applyPlainAttributes()
        }
    }

    private func applyPlainAttributes() {
        guard let textStorage = textStorage else { return }
        textStorage.setAttributedString(
            NSAttributedString(
                string: string,
                attributes: [
                    .foregroundColor: NSColor.labelColor,
                    .font: font!
                ]
            )
        )
        typingAttributes = [
            .foregroundColor: NSColor.labelColor,
            .font: font!
        ]
    }

    // Vložený text přes paste nebo insertText bude vždy plain
    override func insertText(_ insertString: Any, replacementRange: NSRange) {
        let plain: String
        if let attr = insertString as? NSAttributedString {
            plain = attr.string
        } else if let str = insertString as? String {
            plain = str
        } else {
            return
        }
        super.insertText(plain, replacementRange: replacementRange)
    }

    override func paste(_ sender: Any?) {
        let pb = NSPasteboard.general
        if let string = pb.string(forType: .string) {
            self.string = string // vyvolá didSet a applyPlainAttributes()
        }
    }

    override func keyDown(with event: NSEvent) {
        if event.keyCode == 48 { // TAB
            if event.modifierFlags.contains(.shift) {
                window?.selectPreviousKeyView(nil)
            } else {
                window?.selectNextKeyView(nil)
            }
            return
        }
        super.keyDown(with: event)
    }

    override var acceptsFirstResponder: Bool { true }
}
