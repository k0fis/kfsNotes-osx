//
//  JoplinExporter.swift
//  kfsNotes
//
//  Created by Pavel Dřímalka on 01.01.2026.
//


final class JoplinExporter: NotesExporter {

    private let store = JoplinConfigStore()
    
    let name = "Joplin"
    
    let help = """
        Enable Joplin Web Clipper in
        Tools → Options → Web Clipper
        Copy the authorization token.
        Joplin must be running during export.
        """
    
    func insert(msg: Message) async throws -> String {
        guard let config = store.load() else {
            throw ExportError.missingConfig
        }

        let api = JoplinAPI(config: config)
        
        let noteId = try await api.createNote(
            title: msg.note,
            body: msg.toMdString()
        )

        try await api.applyTags(["kfsnote"],toNote: noteId)
        try await api.applyTags(
            msg.tags.split(separator: " ").map(String.init),
            toNote: noteId
        )
        
        return noteId
    }
    
    
    
    func update(msg: Message, ext: ExternalExport) async throws {
        guard let config = store.load() else {
            throw ExportError.missingConfig
        }

        let api = JoplinAPI(config: config)
        try await api.updateNote(
            id: ext.externalId,
            title: msg.note,
            body: msg.toMdString())
        
        try await api.applyTags(["kfsnote"],toNote: ext.externalId)
        try await api.applyTags(
            msg.tags.split(separator: " ").map(String.init),
            toNote: ext.externalId
        )
    }
}
