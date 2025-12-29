//
//  SearchViewController.swift
//  kfs KB
//
//  Created by Pavel Dřímalka on 25.12.2025.
//
import Cocoa

final class SearchViewController: NSViewController {

    // MARK: - UI

    private let searchField = NSSearchField()

    let tableView = NSTableView()
    private let tableScroll = NSScrollView()

    private let textView = NSTextView()
    private let textScroll = NSScrollView()

    private let tagsField = NSTextField()
    private let linkField = NSTextField()
    private let noteField = NSTextField()

    private let saveButton = NSButton(title: "Save", target: nil, action: nil)
    
    private let openLinkButton = NSButton(
        image: NSImage(systemSymbolName: "arrow.up.right.square", accessibilityDescription: "Open link")!,
        target: self,
        action: #selector(openLink)
    )
    let helpButton = NSButton(
        image: NSImage(systemSymbolName: "questionmark.circle", accessibilityDescription: "Search help")!,
        target: self,
        action: #selector(showSearchHelp)
    )

    // MARK: - State

    var results: [Message] = []
    var selectedMessage: Message?

    // MARK: - Lifecycle

    override func loadView() {
        view = NSView()
        setupUI()
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        view.window?.makeFirstResponder(searchField)
    }

    // MARK: - UI setup

    private func setupUI() {

        // Search field
        searchField.placeholderString = "Search…"
        searchField.target = self
        searchField.action = #selector(performSearch)
        searchField.toolTip = "Use AND, OR, NOT, quotes for phrases, * for prefix"

        
        //search help
        helpButton.bezelStyle = .texturedRounded
        helpButton.isBordered = false
        helpButton.toolTip = "Search syntax help"
        
        // link button
        openLinkButton.bezelStyle = .texturedRounded
        openLinkButton.isBordered = true
        openLinkButton.target = nil
        openLinkButton.action = #selector(openLink)
        openLinkButton.menu = makeBrowserMenu()
        openLinkButton.toolTip = "Open link in browser"

        // Table
        let textCol = NSTableColumn(identifier: .init("text"))
        textCol.title = "Text"
        textCol.width = 420

        let tagsCol = NSTableColumn(identifier: .init("tags"))
        tagsCol.title = "Tags"
        tagsCol.width = 160
        

        tableView.addTableColumn(textCol)
        tableView.addTableColumn(tagsCol)
        tableView.headerView = nil
        tableView.target = self
        tableView.action = #selector(rowSelected)
        tableView.allowsEmptySelection = false
        tableView.allowsMultipleSelection = false
        tableView.focusRingType = .default

        tableScroll.documentView = tableView
        tableScroll.hasVerticalScroller = true

        // Editor
        textView.isRichText = false
        textView.font = .systemFont(ofSize: 13)
        textView.isEditable = true
        textScroll.documentView = textView
        textScroll.hasVerticalScroller = true
        textScroll.borderType = .bezelBorder

        tagsField.placeholderString = "tags"
        linkField.placeholderString = "link"
        noteField.placeholderString = "note"

        saveButton.target = self
        saveButton.action = #selector(saveChanges)

        // Layout
        let linkStack = NSStackView(views: [linkField, openLinkButton])
        linkStack.orientation = .horizontal
        linkStack.spacing = 6
        
        let editorStack = NSStackView(views: [
            textScroll,
            tagsField,
            linkStack,
            noteField,
            saveButton
        ])
        editorStack.orientation = .vertical
        editorStack.spacing = 8

        let searchStack = NSStackView(views: [searchField, helpButton])
        searchStack.orientation = .horizontal
        searchStack.spacing = 6
        
        let mainStack = NSStackView(views: [
            searchStack,
            tableScroll,
            editorStack
        ])
        mainStack.orientation = .vertical
        mainStack.spacing = 10
        mainStack.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(mainStack)

        NSLayoutConstraint.activate([
            mainStack.topAnchor.constraint(equalTo: view.topAnchor, constant: 12),
            mainStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12),
            mainStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -12),
            mainStack.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -12),

            tableScroll.heightAnchor.constraint(equalToConstant: 220),
            textScroll.heightAnchor.constraint(equalToConstant: 120)
        ])

        tableView.dataSource = self
        tableView.delegate = self 
        
        performSearch()
    }
    
    // MARK: - makeBrowserMenu()
    
    private func makeBrowserMenu() -> NSMenu {
        let menu = NSMenu()

        let defaultItem = NSMenuItem(
            title: "Open in Default Browser",
            action: #selector(openLink),
            keyEquivalent: ""
        )
        defaultItem.target = self
        menu.addItem(defaultItem)

        menu.addItem(.separator())

        guard let url = URL(string: "https://example.com") else { return menu }

        let apps = NSWorkspace.shared.urlsForApplications(toOpen: url) ?? []

        for appURL in apps {
            let name = appURL.deletingPathExtension().lastPathComponent

            let item = NSMenuItem(
                title: name,
                action: #selector(openLinkInSpecificBrowser(_:)),
                keyEquivalent: ""
            )
            item.representedObject = appURL
            item.target = self
            menu.addItem(item)
        }

        return menu
    }

 
    // MARK: - Actions

    @objc func focusSearchField(_ sender: Any?) {
        view.window?.makeFirstResponder(searchField)
    }
    
    @objc private func performSearch() {
        let q = searchField.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
        results = SQLiteManager.shared.searchFTS(query: q)
        tableView.reloadData()

        if let first = results.first {
            tableView.selectRowIndexes(IndexSet(integer: 0), byExtendingSelection: false)
            loadEditor(first)
        } else {
            clearEditor()
        }
    }

    @objc private func rowSelected() {
        let row = tableView.selectedRow
        guard row >= 0 else { return }
        loadEditor(results[row])
    }

    @objc private func saveChanges() {
        guard var msg = selectedMessage else { return }

        msg.text = textView.string
        msg.tags = tagsField.stringValue
        msg.link = linkField.stringValue
        msg.note = noteField.stringValue

        SQLiteManager.shared.update(msg:msg)
        performSearch()
    }
    
    @objc private func openLink() {
        let raw = linkField.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
        guard
            !raw.isEmpty,
            let url = URL(string: raw.hasPrefix("http") ? raw : "https://\(raw)")
        else { return }

        NSWorkspace.shared.open(url)
    }

    @objc private func openLinkInSpecificBrowser(_ sender: NSMenuItem) {
        guard
            let appURL = sender.representedObject as? URL,
            let url = URL(string: linkField.stringValue)
        else { return }

        NSWorkspace.shared.open(
            [url],
            withApplicationAt: appURL,
            configuration: NSWorkspace.OpenConfiguration(),
            completionHandler: nil
        )
    }

    @objc private func showSearchHelp(_ sender: NSButton) {
        searchHelpPopover.show(
            relativeTo: sender.bounds,
            of: sender,
            preferredEdge: .maxY
        )
    }

    // MARK: - Editor helpers

    func loadEditor(_ msg: Message) {
        selectedMessage = msg
        textView.string = msg.text
        tagsField.stringValue = msg.tags
        linkField.stringValue = msg.link
        noteField.stringValue = msg.note
    }

    private func clearEditor() {
        selectedMessage = nil
        textView.string = ""
        tagsField.stringValue = ""
        linkField.stringValue = ""
        noteField.stringValue = ""
    }
    
    // MARK: - search help
    private lazy var searchHelpPopover: NSPopover = {
        let popover = NSPopover()
        popover.behavior = .transient
        popover.contentViewController = SearchHelpViewController()
        return popover
    }()
    
}
