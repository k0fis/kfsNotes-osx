//
//  SaveView.swift
//  kfsNotes
//
//  Created by Pavel Dřímalka on 30.12.2025.
//

import SwiftUI
import AppKit

struct SaveView: View {
    @State var text: String = ""
    @State var link: String = ""
    @State var tags: String = ""
    @State var note: String = ""

    var onSave: ((String, String, String, String) -> Void)?

    @Environment(\.presentationMode) private var presentationMode
    @FocusState private var textEditorFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Note text
            Text("Note text").monospaced()
            
            // Resizable TextEditor s focus highlight
            ZStack {
                TextEditor(text: $text)
                    .font(.system(size: NSFont.systemFontSize))
                    .foregroundColor(.primary)
                    .background(Color(NSColor.textBackgroundColor))
                    .focused($textEditorFocused)
                    .textSelection(.enabled)
                    .padding(4)
                    .overlay(
                        RoundedRectangle(cornerRadius: 4)
                            .stroke(textEditorFocused ? Color.accentColor : Color.gray.opacity(0.5), lineWidth: 2)
                    )
            }
            .frame(minHeight: 145)
            .frame(maxHeight: .infinity)

            // Link
            Text("Link").monospaced()
            LinkFieldView(link: $link)

            // Tags
            Text("Tags").monospaced()
            TextField("deploy, prod", text: $tags)
                .textFieldStyle(RoundedBorderTextFieldStyle())

            // Note field
            Text("Short note").monospaced()
            TextField("note", text: $note)
                .textFieldStyle(RoundedBorderTextFieldStyle())

            Divider()

            // Buttons
            HStack {
                Button("Save") {
                    onSave?(text, link, tags, note)
                    presentationMode.wrappedValue.dismiss()
                }
                .keyboardShortcut("s", modifiers: [.command])
                Spacer()
                Button("Close") {
                    presentationMode.wrappedValue.dismiss()
                }
                .keyboardShortcut("w", modifiers: [.command])
            }
        }
        .padding()
        .frame(minWidth: 420, minHeight: 400)
        .onAppear {
            loadFromClipboard()
            textEditorFocused = true  // focus při startu
        }
    }

    // MARK: - Clipboard

    private func loadFromClipboard() {
        let pb = NSPasteboard.general
        guard let content = pb.string(forType: .string) else { return }
        text = content

        if let url = extractFirstURL(from: content) {
            link = url.absoluteString
        }
    }

    private func extractFirstURL(from text: String) -> URL? {
        let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
        let range = NSRange(text.startIndex..., in: text)
        return detector?.firstMatch(in: text, options: [], range: range)?.url
    }
}
