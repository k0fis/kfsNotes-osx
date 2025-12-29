import Cocoa

final class FormTextView: NSTextView {

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
