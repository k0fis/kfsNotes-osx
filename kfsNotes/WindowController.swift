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
    var joplinWindow: NSWindow?

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
    
    func showJoplin() {
        if joplinWindow == nil {
            let rootView = JoplinConfigView()
            let hostingController = NSHostingController(rootView: rootView)
            joplinWindow = makeWindow(hostingController, title: "Joplin config",
                                      size: NSSize(width: 520, height: 400), id: "kfsJoplin")
        }
        bringToFront(joplinWindow)
    }

    func showSearch() {
        if searchWindow == nil {

                let searchView = SearchView(
                    onClose: { [weak self] in
                        self?.searchWindow?.close()
                        self?.searchWindow = nil
                    }
                )

                let hostingVC = NSHostingController(rootView: searchView)

                searchWindow = makeWindow(
                    hostingVC,
                    title: "Search Notes",
                    size: NSSize(width: 700, height: 450),
                    id: "kfsSearch"
                )
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
        DispatchQueue.main.async {
            NSApp.activate(ignoringOtherApps: true)
            w.makeKeyAndOrderFront(nil)
        }
    }
    
    @objc private func windowClosed(_ notification: Notification) {
        guard let window = notification.object as? NSWindow else { return }

        switch window.identifier?.rawValue {
        case "kfsSave":
            saveWindow = nil
        case "kfsSearch":
            searchWindow = nil
        case "kfsJoplin":
            joplinWindow = nil
        default:
            break
        }

        if saveWindow == nil && searchWindow == nil && joplinWindow == nil {
            NSApp.setActivationPolicy(.accessory)
        }
    }

}
