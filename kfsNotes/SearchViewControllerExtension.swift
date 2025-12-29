//
//  SearchViewControllerExtension.swift
//  kfsNotes
//
//  Created by Pavel Dřímalka on 28.12.2025.
//

import Cocoa

extension SearchViewController: NSTableViewDataSource, NSTableViewDelegate {

    func numberOfRows(in tableView: NSTableView) -> Int {
        results.count
    }

    func tableView(_ tableView: NSTableView,
                   viewFor tableColumn: NSTableColumn?,
                   row: Int) -> NSView? {

        let msg = results[row]
        let text: String

        switch tableColumn?.identifier.rawValue {
        case "text":
            text = msg.text.prefix(120) + "…"
        case "tags":
            text = msg.tags
        default:
            text = ""
        }

        let label = NSTextField(labelWithString: text)
        label.lineBreakMode = .byTruncatingTail
        label.backgroundColor = .clear
        label.isBezeled = false
        label.drawsBackground = false
        return label
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        let row = tableView.selectedRow
        guard row >= 0 else { return }
        loadEditor(results[row])
    }
}
