import Cocoa
import SwiftUI
import ServiceManagement

@main
class AppDelegate: NSObject, NSApplicationDelegate {

    private var allowQuit = false
    var statusItem: NSStatusItem!

    func applicationDidFinishLaunching(_ notification: Notification) {

        NSApp.setActivationPolicy(.accessory)
        setupStatusItem()
        setupMainMenu() // <-- tady přidáme Edit menu

        _ = HotKeyManager.shared
        enableLaunchAtLogin(true)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            for window in NSApp.windows {
                window.orderOut(nil)
            }
        }
    }

    private func setupStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        if let button = statusItem.button {
            button.image = NSImage(named: "kfsMenuIcon")
            button.image?.isTemplate = true
            button.toolTip = "kfs KB"
        }

        let menu = NSMenu()

        let saveMenu = NSMenuItem(title: "Save", action: #selector(openSave), keyEquivalent: "s")
        saveMenu.keyEquivalentModifierMask = [.command, .option]
        menu.addItem(saveMenu)

        let findMenu = NSMenuItem(title: "Find", action: #selector(openSearch), keyEquivalent: "f")
        findMenu.keyEquivalentModifierMask = [.command, .option]
        menu.addItem(findMenu)

        menu.addItem(.separator())

        let infoItem = NSMenuItem(title: "Info", action: #selector(showBuildInfo(_:)), keyEquivalent: "")
        infoItem.target = self
        menu.addItem(infoItem)

        menu.addItem(NSMenuItem.separator())

        let quitItem = NSMenuItem(title: "Quit", action: #selector(quit), keyEquivalent: "q")
        quitItem.target = self
        menu.addItem(quitItem)

        statusItem.menu = menu
    }

    private func setupMainMenu() {
        let mainMenu = NSMenu()
        NSApp.mainMenu = mainMenu

        // App menu
        let appMenuItem = NSMenuItem()
        mainMenu.addItem(appMenuItem)

        let appMenu = NSMenu()
        appMenuItem.submenu = appMenu
        appMenu.addItem(withTitle: "About kfsNotes", action: nil, keyEquivalent: "")

        // Edit menu
        let editMenuItem = NSMenuItem()
        mainMenu.addItem(editMenuItem)

        let editMenu = NSMenu(title: "Edit")
        editMenuItem.submenu = editMenu

        editMenu.addItem(withTitle: "Cut", action: #selector(NSText.cut(_:)), keyEquivalent: "x")
        editMenu.addItem(withTitle: "Copy", action: #selector(NSText.copy(_:)), keyEquivalent: "c")
        editMenu.addItem(withTitle: "Paste", action: #selector(NSText.paste(_:)), keyEquivalent: "v")
        editMenu.addItem(withTitle: "Select All", action: #selector(NSText.selectAll(_:)), keyEquivalent: "a")
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

    @objc func showBuildInfo(_ sender: Any?) {
        let sqlitePath = SQLiteManager.shared.dbURL.absoluteString
        let message = """
        App Version: \(AppInfo.full)
        SQLite path: \(sqlitePath)
        """
        let alert = NSAlert()
        alert.messageText = "kfsNotes Info"
        alert.informativeText = message
        alert.alertStyle = .informational
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }
    
    func enableLaunchAtLogin(_ enable: Bool) {
        let launcherBundleId = "kfs.kfsNotesLauncher"
        SMLoginItemSetEnabled(launcherBundleId as CFString, enable)
    }
}
