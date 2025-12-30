import Cocoa

final class FormTextView: NSTextView {
    
    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()

        isRichText = false
        allowsUndo = true

        drawsBackground = false
        backgroundColor = .clear

        usesAdaptiveColorMappingForDarkAppearance = false
        textColor = .textColor
        font = NSFont.systemFont(ofSize: NSFont.systemFontSize)

        typingAttributes = [
            .foregroundColor: NSColor.textColor,
            .font: font!
        ]
        print("FormTextView awakeFromNib")
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
