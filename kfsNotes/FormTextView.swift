import Cocoa

final class FormTextView: NSTextView {

    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()

        isRichText = false
        allowsUndo = true

        //  avoid adaptive vibrant background
        drawsBackground = true
        backgroundColor = NSColor.textBackgroundColor

        // non-adaptive always visible text color
        textColor = NSColor.controlTextColor
        font = NSFont.systemFont(ofSize: NSFont.systemFontSize)

        typingAttributes = [
            .foregroundColor: NSColor.controlTextColor,
            .font: font!
        ]
    }

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
            self.string = string
        }
    }

    override func keyDown(with event: NSEvent) {
        if event.keyCode == 48 {
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
