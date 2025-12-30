import SwiftUI
import AppKit

struct SearchView: View {

    @State private var query: String = ""
    @State private var results: [Message] = []
    @State private var selectedMessage: Message?
    @State private var selection: Message.ID?

    @State private var text: String = ""
    @State private var tags: String = ""
    @State private var link: String = ""
    @State private var note: String = ""

    @FocusState private var focusedField: Field?

    enum Field: Hashable {
        case search, text, tags, link, note
    }

    var body: some View {
        VStack(spacing: 4) {
            // Search bar + help button
            HStack {
                TextField("Search…", text: $query)
                    .focused($focusedField, equals: .search)
                    .onSubmit(performSearch)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .help("Use AND, OR, NOT, quotes for phrases, * for prefix")
                Button(action: showHelp) {
                    Image(systemName: "questionmark.circle")
                }
                .buttonStyle(BorderlessButtonStyle())
                .help("Search syntax help")
            }
            .onExitCommand {onClose?()}

            // Results table
            List(results, id: \.id, selection: $selection) { msg in
                HStack {
                    Text(msg.text)
                        .lineLimit(1)
                    Spacer()
                    Text(msg.tags)
                        .foregroundColor(selection == msg.id ? .white : .secondary)
                        .lineLimit(1)
                }
                .contentShape(Rectangle())
                .listRowBackground(selection == msg.id ? Color.accentColor.opacity(0.4) : Color.clear)
                .onTapGesture {
                    selectedMessage = msg
                    selection = msg.id
                    loadEditor(msg)
                }
            }
            .frame(height: 220)
            //.focusable(true)
            .onMoveCommand { direction in
                guard !results.isEmpty else { return }
                
                let currentIndex: Int
                if let sel = selection, let idx = results.firstIndex(where: { $0.id == sel }) {
                    currentIndex = idx
                } else {
                    currentIndex = direction == .up ? results.count - 1 : 0
                }
                
                let newIndex: Int
                if direction == .up {
                    newIndex = max(currentIndex - 1, 0)
                } else {
                    newIndex = min(currentIndex + 1, results.count - 1)
                }
                selection = results[newIndex].id
            }
            .onChange(of: selection) { newSelection, _ in
                guard let id = newSelection,
                      let msg = results.first(where: { $0.id == id }) else {
                    clearEditor()
                    return
                }
                selectedMessage = msg
                loadEditor(msg)
            }
            

            // Editor section
            VStack(alignment: .leading, spacing: 8) {
                Text("Text").monospaced()
                TextEditor(text: $text)
                    .focused($focusedField, equals: .text)
                    .overlay(
                        RoundedRectangle(cornerRadius: 4)
                            .stroke(focusedField == .text ? Color.accentColor : Color.gray.opacity(0.5), lineWidth: 2)
                    )
                    .frame(minHeight: 120)
                    .frame(maxHeight: .infinity)
                    .textSelection(.enabled)

                Text("Tags").monospaced()
                TextField("tags", text: $tags)
                    .focused($focusedField, equals: .tags)
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                Text("Link").monospaced()
                LinkFieldView(link: $link)
                Text("Note").monospaced()
                TextField("note", text: $note)
                    .focused($focusedField, equals: .note)
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                HStack {
                    Button("Save", action: saveChanges).keyboardShortcut("s", modifiers: [.command])
                    Spacer()
                    Button("Close", action: closeWindow).keyboardShortcut("w", modifiers: [.command])
                }
            }
        }
        .padding()
        .frame(minWidth: 700, minHeight: 620)
        .onAppear(perform: performSearch)
    }

    // MARK: - Actions

    private func performSearch() {
        results = SQLiteManager.shared.searchFTS(query: query)
        if let first = results.first {
            loadEditor(first)
        } else {
            clearEditor()
        }
    }

    private func loadEditor(_ msg: Message) {
        selectedMessage = msg
        text = msg.text
        tags = msg.tags
        link = msg.link
        note = msg.note
    }

    private func clearEditor() {
        selectedMessage = nil
        text = ""
        tags = ""
        link = ""
        note = ""
    }

    private func saveChanges() {
        guard var msg = selectedMessage else { return }
        msg.text = text
        msg.tags = tags
        msg.link = link
        msg.note = note
        SQLiteManager.shared.update(msg: msg)
        performSearch()
    }

    private func openLink() {
        guard !link.isEmpty else { return }
        let urlString = link.hasPrefix("http") ? link : "https://\(link)"
        if let url = URL(string: urlString) {
            NSWorkspace.shared.open(url)
        }
    }

    private func showHelp() {
        // popover nebo alert s pomocí
        let alert = NSAlert()
        alert.messageText = "Search Help"
        alert.informativeText = "Use AND, OR, NOT, quotes for phrases, * for prefix"
        alert.runModal()
    }

    private func closeWindow() {
        NSApp.keyWindow?.close()
    }
    
    var onClose: (() -> Void)?

}

