//
//  NotesExporter.swift
//  kfsNotes
//
//  Created by Pavel Dřímalka on 01.01.2026.
//

protocol NotesExporter {
    func export(msg: Message) async throws
    
    // MARK: -
    func insert(msg: Message) async throws -> String
    
    func update(msg: Message, ext: ExternalExport) async throws
    
    // MARK: - 
    var name: String { get }
    var help: String { get }
}

extension NotesExporter {
    
    func export(msg: Message) async throws {
        if let export = try SQLiteManager.shared.externalExport(messageId: msg.id, system: name) {
            do{
                try await update(msg: msg, ext: export)
                try SQLiteManager.shared.upsertExternalExport(messageId: msg.id, system: name,                externalId: export.externalId
                )
            } catch JoplinError.notFound {
                // NOTE BYLA SMAZANÁ
                let newId = try await insert(msg: msg)
                try SQLiteManager.shared.deleteExternalExport(messageId: msg.id, system: name)
                try SQLiteManager.shared.upsertExternalExport(messageId: msg.id, system: name, externalId: newId)
            }
        } else {
            let externalId = try await insert(msg: msg)
            if !externalId.isEmpty {
                try SQLiteManager.shared.upsertExternalExport(
                    messageId: msg.id,
                    system: name,
                    externalId: externalId)
            }
        }
    }
}
