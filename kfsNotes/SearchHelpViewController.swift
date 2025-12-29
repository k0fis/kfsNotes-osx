//
//  SearchHelpViewController.swift
//  kfsNotes
//
//  Created by Pavel Dřímalka on 28.12.2025.
//

import Cocoa

final class SearchHelpViewController: NSViewController {

    override func loadView() {
        let textView = NSTextView()
        textView.isEditable = false
        textView.drawsBackground = false
        textView.font = .systemFont(ofSize: 12)

        textView.string = """
Search syntax:

• Words are combined using AND by default
  golem praha

• OR operator
  golem OR praha

• Exclude a word
  golem NOT praha

• Exact phrase
  "golem of prague"

• Prefix search
  gol* pra*

Tips:
– Search is case-insensitive
– Results are ranked by relevance
"""

        let scroll = NSScrollView()
        scroll.documentView = textView
        scroll.hasVerticalScroller = true

        self.view = scroll
        self.preferredContentSize = NSSize(width: 320, height: 220)
    }
}

