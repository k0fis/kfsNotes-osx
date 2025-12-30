//
//  WindowController.swift
//  kfs KB
//
//  Created by Pavel Dřímalka on 25.12.2025.
//

import Cocoa
import SwiftUI

final class WindowController : NSObject {

    static let shared = WindowController()

    var saveWindow: NSWindow?
    var searchWindow: NSWindow?

    override init() {
        super.init()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(windowClosed(_:)),
            name: NSWindow.willCloseNotification,
            object: nil
        )
    }
    
    func showSave(text: String = "", link: String = "", tags: String = "", note: String = "") {
        if saveWindow == nil {
            let rootView = SaveView(text: text, link: link, tags: tags, note: note) { text, link, tags, note in
                SQLiteManager.shared.insert(text: text, link: link, tags: tags, note: note)
            }
            let hostingController = NSHostingController(rootView: rootView)
            saveWindow = makeWindow(hostingController, title: "Save note", size: NSSize(width: 520, height: 400), id: "kfsSave")
        }
        bringToFront(saveWindow)
    }

    func showSearch() {
        if searchWindow == nil {
            let vc = SearchViewController()
            searchWindow = makeWindow(vc, title: "Search Notes", size: NSSize(width: 700, height: 450), id: "kfsSearch")
        }
        bringToFront(searchWindow)
    }

    private func makeWindow(_ vc: NSViewController, title: String, size: NSSize, id: String) -> NSWindow {
        let w = NSWindow(
            contentViewController: vc
        )
        w.title = title
        w.setContentSize(size)
        w.styleMask = [.titled, .closable, .resizable]
        w.identifier = NSUserInterfaceItemIdentifier(id)
        return w
    }

    private func bringToFront(_ window: NSWindow?) {
        guard let w = window else { return }
        NSApp.setActivationPolicy(.regular)
        NSApp.activate(ignoringOtherApps: true)
        w.makeKeyAndOrderFront(nil)
    }
    
    @objc private func windowClosed(_ notification: Notification) {
        guard let window = notification.object as? NSWindow else { return }

        switch window.identifier?.rawValue {
        case "kfsSave":
            saveWindow = nil

        case "kfsSearch":
            searchWindow = nil

        default:
            break
        }

        if saveWindow == nil && searchWindow == nil {
            NSApp.setActivationPolicy(.accessory)
        }
    }

}
