import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate {

    private var allowQuit = false
    
    var statusItem: NSStatusItem!

    func applicationDidFinishLaunching(_ notification: Notification) {

        NSApp.setActivationPolicy(.accessory)
        
        setupStatusItem()
        
        _ = HotKeyManager.shared
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            for window in NSApp.windows {
                window.orderOut(nil)
            }
        }
    }

    private func setupStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength        )

        if let button = statusItem.button {
            button.image = NSImage(named: "kfsMenuIcon")
                button.image?.isTemplate = true
                button.toolTip = "kfs KB"
        }

        let menu = NSMenu()

        let saveMenu = NSMenuItem(
            title: "Save",
            action: #selector(openSave),
            keyEquivalent: "s"
        )
        saveMenu.keyEquivalentModifierMask = [.command, .option]
        
        menu.addItem(saveMenu)
        
        let findMenu = NSMenuItem(
            title: "Find",
            action: #selector(openSearch),
            keyEquivalent: "f"
        )
        findMenu.keyEquivalentModifierMask = [.command, .option]

        menu.addItem(findMenu)

        menu.addItem(.separator())

        menu.addItem(
            NSMenuItem(
                title: "Quit",
                action: #selector(quit),
                keyEquivalent: ""
            )
        )

        let item = NSMenuItem(
            title: "Focus Search",
            action: #selector(SearchViewController.focusSearchField),
            keyEquivalent: "l"
        )
        item.keyEquivalentModifierMask = [.command]
        item.target = nil
        
        let mainMenu = NSMenu()
        NSApp.mainMenu = mainMenu

        let appMenuItem = NSMenuItem()
        mainMenu.addItem(appMenuItem)

        let appMenu = NSMenu()
        appMenuItem.submenu = appMenu
        appMenu.addItem(item)
        
        statusItem.menu = menu
    }

    @objc private func openSave() {
        WindowController.shared.showSave()
    }

    @objc private func openSearch() {
        WindowController.shared.showSearch()
    }

    @objc private func quit() {
        allowQuit = true
        NSApp.terminate(nil)
    }
    
    func applicationShouldTerminate(_ sender: NSApplication) -> NSApplication.TerminateReply {
        return allowQuit ? .terminateNow : .terminateCancel
    }
}
