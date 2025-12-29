//
//  FormTextView.swift
//  kfsNotes
//
//  Created by Pavel Dřímalka on 27.12.2025.
//

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
    
    override func didChangeText() {
        super.didChangeText()

        textStorage?.setAttributedString(
            NSAttributedString(
                string: string,
                attributes: typingAttributes
            )
        )
    }
    
    override func keyDown(with event: NSEvent) {
        // TAB
        if event.keyCode == 48, !event.modifierFlags.contains(.shift) {
            window?.selectNextKeyView(nil)
            return
        }

        // Shift+TAB
        if event.keyCode == 48, event.modifierFlags.contains(.shift) {
            window?.selectPreviousKeyView(nil)
            return
        }

        super.keyDown(with: event)
    }

    override var acceptsFirstResponder: Bool {
        true
    }
}
