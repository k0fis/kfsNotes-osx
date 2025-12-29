//
//  FocusableButton.swift
//  kfsNotes
//
//  Created by Pavel Dřímalka on 27.12.2025.
//

import Cocoa

final class FocusableButton: NSButton {

    // MARK: - Init

    init(title: String, target: AnyObject?, action: Selector?) {
        super.init(frame: .zero)

        self.title = title
        self.target = target
        self.action = action

        setupDefaults()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupDefaults()
    }

    // MARK: - Defaults

    private func setupDefaults() {
        bezelStyle = .rounded
        controlSize = .regular
        focusRingType = .default
        setButtonType(.momentaryPushIn)
        isBordered = true

        refusesFirstResponder = false
    }

    // MARK: - Focus
    
    override var acceptsFirstResponder: Bool {
        true
    }

    override func becomeFirstResponder() -> Bool {
        needsDisplay = true
        return true
    }

    override func resignFirstResponder() -> Bool {
        needsDisplay = true
        return true
    }
}

