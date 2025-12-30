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
        guard let appURL = NSWorkspace.shared.urlForApplication(
            withBundleIdentifier: "kfs.kfsNotes"
        ) else {
            NSApp.terminate(nil)
            return
        }

        let config = NSWorkspace.OpenConfiguration()
        config.activates = false   // neskáče do popředí při loginu

        NSWorkspace.shared.openApplication(
            at: appURL,
            configuration: config
        ) { _, _ in
            NSApp.terminate(nil)
        }
        
    }

}

