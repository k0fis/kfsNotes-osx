//
//  FormLabel.swift
//  kfsNotes
//
//  Created by Pavel Dřímalka on 27.12.2025.
//

import Cocoa

final class FormLabel: NSTextField {

    init(_ text: String) {
        super.init(frame: .zero)

        stringValue = text
        isEditable = false
        isBordered = false
        drawsBackground = false

        font = NSFont.systemFont(ofSize: 11, weight: .medium)
        textColor = .secondaryLabelColor
        alignment = .left
        lineBreakMode = .byTruncatingTail

        setContentHuggingPriority(.required, for: .vertical)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}

