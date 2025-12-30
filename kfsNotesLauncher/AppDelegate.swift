//
//  AppDelegate.swift
//  kfsNotesLauncher
//
//  Created by Pavel Dřímalka on 30.12.2025.
//

import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate {

    func applicationDidFinishLaunching(_ aNotification: Notification) {
            let path = "/Applications/kfsNotes.app"
            NSWorkspace.shared.launchApplication(path)
            NSApp.terminate(nil)
        }

}

