//
//  FormTextView.swift
//  kfsNotes
//
//  Created by Pavel Dřímalka on 27.12.2025.
//

import Cocoa

final class FormTextView: NSTextView {

    
    
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
