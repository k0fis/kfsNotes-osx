import SwiftUI
import AppKit

struct SearchView: View {

    @State private var query: String = ""
    @State private var results: [Message] = []
    @State private var selectedMessage: Message?
    @State private var selection: Message.ID?
    @State private var alertMessage: String?
    @State private var toastMessage: String?
    @State private var showHelp = false
    @State private var showExportHelp = false
    @State private var showConfigDialog = false
    @State private var pendingExportMessage: Message?
    @State private var searchTask: Task<Void, Never>?

    @State private var text: String = ""
    @State private var tags: String = ""
    @State private var link: String = ""
    @State private var note: String = ""

    @FocusState private var focusedField: Field?
    
    private let exporter = JoplinExporter()

    enum Field: Hashable {
        case search, text, tags, link, note
    }

    var body: some View {
        ZStack {
            mainContent
            .sheet(isPresented: $showConfigDialog) {
                JoplinConfigView(
                    onSaved: {
                        showConfigDialog = false
                        retryPendingExport()
                    }
                )
            }
            .alert("Export failed",
                   isPresented: Binding(
                    get: { alertMessage != nil },
                    set: { _ in alertMessage = nil }
                   )) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(alertMessage ?? "")
            }
            if let toastMessage {
                VStack {
                    Spacer()
                    ToastView(message: toastMessage)
                        .padding(.bottom, 20)
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
    }
    
    var mainContent: some View {
        VStack(spacing: 4) {
            // Search bar + help button
            HStack {
                TextField("Search…", text: $query)
                    .focused($focusedField, equals: .search)
                    //.onSubmit(performSearch)
                    .onChange(of: query) { _, _ in
                        debounceSearch()
                    }
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .help("Use AND, OR, NOT, quotes for phrases, * for prefix")
                Button { showHelp = true} label: { Image(systemName: "questionmark.circle")}
                .popover(isPresented: $showHelp) {
                    Text("""
                    Use AND, OR, NOT
                    Quotes for phrases
                    * for prefix search
                    """)
                    .padding()
                    .frame(width: 260)
                }.buttonStyle(BorderlessButtonStyle())
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
            }
            .frame(height: 220)
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
            .onChange(of: selection) { _, newSelection in
                guard let id = newSelection,
                      let msg = results.first(where: { $0.id == id }) else {
                    clearEditor()
                    return
                }
                selectedMessage = msg
                //selection = msg.id
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
                LinkFieldView(link: $link).onSubmit {openLink()}
                Text("Note").monospaced()
                TextField("note", text: $note)
                    .focused($focusedField, equals: .note)
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                HStack {
                    Button("Save", action: saveChanges).keyboardShortcut("s", modifiers: [.command])
                    Button("Export to " + exporter.name, action: exportTo)
                        .keyboardShortcut("j", modifiers: [.command])
                    Button { showExportHelp = true} label: { Image(systemName: "questionmark.circle")}
                    .popover(isPresented: $showExportHelp) {
                        Text(exporter.help)
                        .padding()
                        .frame(width: 260)
                    }.buttonStyle(BorderlessButtonStyle())
                    Button("Copy text", action: copyMessageAText).keyboardShortcut("c", modifiers: [.command, .shift])
                    Button("Copy MD", action: copyMessageMd).keyboardShortcut("m", modifiers: [.command, .shift])
                    Spacer()
                    Button("Close", action: closeWindow).keyboardShortcut("w", modifiers: [.command])
                    
                }
            }
        }
        .padding()
        .frame(minWidth: 700, minHeight: 620)
        .onAppear(perform: performSearch)
        .alert("Error", isPresented: Binding(
            get: { alertMessage != nil },
            set: { _ in alertMessage = nil }
        )) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(alertMessage ?? "")
        }
    }

    // MARK: - Actions

    private func exportTo() {
        guard let msg2 = selectedMessage else { return }
        saveChanges()
        guard let msg = SQLiteManager.shared.getNote(id: msg2.id) else { return }
        loadEditor(msg)
        Task {
            do {
                try await exporter.export(msg: msg)
                showToast("Exported")
            } catch ExportError.missingConfig {
                showConfigDialog = true
                pendingExportMessage = msg
                showConfigDialog = true
            } catch {
                alertMessage = "Cannot export to " + exporter.name+": " + error.localizedDescription
            }
        }
    }
    
    func toAttributedString(_ html: String) throws -> NSAttributedString {
        let data = Data(html.utf8)

        return try NSAttributedString(
            data: data,
            options: [
                .documentType: NSAttributedString.DocumentType.html,
                .characterEncoding: String.Encoding.utf8.rawValue
            ],
            documentAttributes: nil
        )
    }
    
    private func copyMessageAText() {
        guard let msg2 = selectedMessage else { return }
        saveChanges()
        guard let msg = SQLiteManager.shared.getNote(id: msg2.id) else { return }
        loadEditor(msg)
        let pb = NSPasteboard.general
        do {
            let html = msg.toHTML()
            let astr = try toAttributedString(html)
            pb.clearContents()
            pb.writeObjects([astr])
            pb.setString(html, forType: .html)
        } catch {
            alertMessage = error.localizedDescription
        }
    }
    
    private func copyMessageMd() {
        guard let msg2 = selectedMessage else { return }
        saveChanges()
        guard let msg = SQLiteManager.shared.getNote(id: msg2.id) else { return }
        let pb = NSPasteboard.general
        pb.clearContents()
        pb.setString(msg.toMdString(), forType: .string)
        loadEditor(msg)
    }
    
    func retryPendingExport() {
        guard let msg = pendingExportMessage else { return }
        pendingExportMessage = nil
        exportSelectedMessage(msg)
    }

    private func exportSelectedMessage(_ msg: Message) {
        Task {
            do {
                try await exporter.export(msg: msg)
            } catch {
                alertMessage = error.localizedDescription
            }
        }
    }
    
    private func debounceSearch() {
        searchTask?.cancel()
        searchTask = Task {
            try? await Task.sleep(nanoseconds: 300_000_000)
            performSearch()
        }
    }
    
    private func performSearch() {
        results = SQLiteManager.shared.searchFTS(query: query)
        if let first = results.first {
            selection = first.id
            focusedField = .text
            DispatchQueue.main.async {
                selection = first.id
            }
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
        //performSearch()
        if let index = results.firstIndex(where: { $0.id == msg.id }) {
            results[index] = msg
        }
    }

    private func openLink() {
        guard !link.isEmpty else { return }
        let urlString = link.hasPrefix("http") ? link : "https://\(link)"
        if let url = URL(string: urlString) {
            NSWorkspace.shared.open(url)
        }
    }

    private func closeWindow() {
        NSApp.keyWindow?.close()
    }
    
    var onClose: (() -> Void)?
    
    private func showToast(_ message: String) {
        toastMessage = nil
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                withAnimation {
                    toastMessage = message
                }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                withAnimation {
                    toastMessage = nil
                }
            }
    }

}

struct ToastView: View {
    let message: String

    var body: some View {
        Text(message)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(.ultraThinMaterial)
            .cornerRadius(8)
            .shadow(radius: 5)
    }
}

