//
//  HotKeyManager.swift
//  kfs KB
//
//  Created by Pavel Dřímalka on 25.12.2025.
//

import Cocoa
import Carbon

final class HotKeyManager {

    static let shared = HotKeyManager()

    private var saveHotKey: EventHotKeyRef?
    private var searchHotKey: EventHotKeyRef?

    private init() {
        register()
        installHandler()
    }

    // MARK: - Registration

    private func register() {

        // ⌥⌘S
        registerHotKey(
            keyCode: UInt32(kVK_ANSI_S),
            modifiers: UInt32(optionKey | cmdKey),
            id: 1,
            ref: &saveHotKey
        )

        // ⌥⌘F
        registerHotKey(
            keyCode: UInt32(kVK_ANSI_F),
            modifiers: UInt32(optionKey | cmdKey),
            id: 2,
            ref: &searchHotKey
        )
    }

    private func registerHotKey(
        keyCode: UInt32,
        modifiers: UInt32,
        id: UInt32,
        ref: inout EventHotKeyRef?
    ) {
        let hotKeyID = EventHotKeyID(
            signature: OSType(UInt32(truncatingIfNeeded: 0x4B465348)), // "KFSH"
            id: id
        )

        RegisterEventHotKey(
            keyCode,
            modifiers,
            hotKeyID,
            GetApplicationEventTarget(),
            0,
            &ref
        )
    }

    // MARK: - Handler

    private func installHandler() {

        var eventType = EventTypeSpec(
            eventClass: OSType(kEventClassKeyboard),
            eventKind: UInt32(kEventHotKeyPressed)
        )

        InstallEventHandler(
            GetApplicationEventTarget(),
            { (_, event, _) -> OSStatus in

                var hotKeyID = EventHotKeyID()

                GetEventParameter(
                    event,
                    EventParamName(kEventParamDirectObject),
                    EventParamType(typeEventHotKeyID),
                    nil,
                    MemoryLayout<EventHotKeyID>.size,
                    nil,
                    &hotKeyID
                )

                DispatchQueue.main.async {
                    switch hotKeyID.id {
                    case 1:
                        AppActions.openSave()
                    case 2:
                        AppActions.openSearch()
                    default:
                        break
                    }
                }

                return noErr
            },
            1,
            &eventType,
            nil,
            nil
        )
    }
}

