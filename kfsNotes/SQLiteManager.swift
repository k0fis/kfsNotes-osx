//
//  SQLiteManager.swift
//  kfs KB
//
//  Created by Pavel Dřímalka on 25.12.2025.
//

import Foundation
import SQLite3

final class SQLiteManager {

    private let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)

    static let shared = SQLiteManager()

    private var db: OpaquePointer?

    private init() {
        open()
        createTables()
    }

    var dbURL: URL {
        let fm = FileManager.default
        let dir = fm.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let appDir = dir.appendingPathComponent("TeamsNotes", isDirectory: true)
        try? fm.createDirectory(at: appDir, withIntermediateDirectories: true)
        return appDir.appendingPathComponent("messages.sqlite")
    }

    private func open() {
        if sqlite3_open(dbURL.path, &db) != SQLITE_OK {
            fatalError("Cannot open DB")
        }
        print("SQLite path:", dbURL.path)
    }

    private func createTables() {
        let sql = """
        CREATE TABLE IF NOT EXISTS messages (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            text TEXT,
            link TEXT,
            tags TEXT,
            note TEXT,
            created_at DATETIME DEFAULT CURRENT_TIMESTAMP
        );

        CREATE VIRTUAL TABLE IF NOT EXISTS messages_fts
        USING fts5(text, tags, note, content='messages', content_rowid='id');

        CREATE TRIGGER IF NOT EXISTS messages_ai AFTER INSERT ON messages BEGIN
            INSERT INTO messages_fts(rowid, text, tags, note)
            VALUES (new.id, new.text, new.tags, new.note);
        END;

        CREATE TRIGGER IF NOT EXISTS messages_ad AFTER DELETE ON messages BEGIN
            INSERT INTO messages_fts(messages_fts, rowid, text, tags, note)
            VALUES ('delete', old.id, old.text, old.tags, old.note);
        END;

        CREATE TRIGGER IF NOT EXISTS messages_au AFTER UPDATE ON messages BEGIN
            INSERT INTO messages_fts(messages_fts, rowid, text, tags, note)
            VALUES ('delete', old.id, old.text, old.tags, old.note);

            INSERT INTO messages_fts(rowid, text, tags, note)
            VALUES (new.id, new.text, new.tags, new.note);
        END;
        """
        exec(sql)
    }


    private func exec(_ sql: String) {
        var err: UnsafeMutablePointer<Int8>?
        if sqlite3_exec(db, sql, nil, nil, &err) != SQLITE_OK {
            let msg = String(cString: err!)
            print("SQLite error:", msg)
        }
    }

    // MARK: - Insert

    func insert(text: String, link: String, tags: String, note: String) {
        let sql = """
        INSERT INTO messages (text, link, tags, note)
        VALUES (?, ?, ?, ?);
        """
        let normalizedTags = tags
            .lowercased()
            .split(separator: " ")
            .sorted()
            .joined(separator: " ")

        var stmt: OpaquePointer?
        sqlite3_prepare_v2(db, sql, -1, &stmt, nil)

        sqlite3_bind_text(stmt, 1, text, -1, SQLITE_TRANSIENT)
        sqlite3_bind_text(stmt, 2, link, -1, SQLITE_TRANSIENT)
        sqlite3_bind_text(stmt, 3, normalizedTags, -1, SQLITE_TRANSIENT)
        sqlite3_bind_text(stmt, 4, note, -1, SQLITE_TRANSIENT)

        if sqlite3_step(stmt) != SQLITE_DONE {
            print("Insert failed:", String(cString: sqlite3_errmsg(db)))
        }

        sqlite3_finalize(stmt)
    }
    
    // MARK: - Update

    func update(msg: Message) {
        
        if (msg.id <= 0) {
            print("Error - use insert and update ID");
        }
        
        let sql = """
        UPDATE messages SET text=?, link=?, tags=?, note=? WHERE id = ?;
        """
        let normalizedTags = msg.tags
            .lowercased()
            .split(separator: " ")
            .sorted()
            .joined(separator: " ")

        var stmt: OpaquePointer?
        sqlite3_prepare_v2(db, sql, -1, &stmt, nil)

        sqlite3_bind_text(stmt, 1, msg.text, -1, SQLITE_TRANSIENT)
        sqlite3_bind_text(stmt, 2, msg.link, -1, SQLITE_TRANSIENT)
        sqlite3_bind_text(stmt, 3, normalizedTags, -1, SQLITE_TRANSIENT)
        sqlite3_bind_text(stmt, 4, msg.note, -1, SQLITE_TRANSIENT)
        sqlite3_bind_int(stmt, 5, Int32(msg.id))

        if sqlite3_step(stmt) != SQLITE_DONE {
            print("Update failed:", String(cString: sqlite3_errmsg(db)))
        }

        sqlite3_finalize(stmt)
    }
    
    // MARK: - Search

    func searchFTS(query: String) -> [Message] {
        var results: [Message] = []

        let sql: String
        if query.isEmpty {
            sql = """
            SELECT * FROM messages
            ORDER BY created_at DESC
            LIMIT 100;
            """
        } else {
            sql = """
            SELECT m.*
            FROM messages m
            JOIN messages_fts fts ON fts.rowid = m.id
            WHERE messages_fts MATCH ?
            ORDER BY rank
            LIMIT 100;
            """
        }

        var stmt: OpaquePointer?
        sqlite3_prepare_v2(db, sql, -1, &stmt, nil)

        if !query.isEmpty {
            if (sqlite3_bind_text(stmt, 1, query, -1, SQLITE_TRANSIENT) != SQLITE_OK ) {
                print("Bind error: ", (String(cString: sqlite3_errmsg(db))))
                
            }
        }

        while sqlite3_step(stmt) == SQLITE_ROW {
            results.append(Message(
                id: Int(sqlite3_column_int(stmt, 0)),
                text: String(cString: sqlite3_column_text(stmt, 1)),
                link: String(cString: sqlite3_column_text(stmt, 2)),
                tags: String(cString: sqlite3_column_text(stmt, 3)),
                note: String(cString: sqlite3_column_text(stmt, 4)),
                createdAt: String(cString: sqlite3_column_text(stmt, 5))
            ))
        }

        sqlite3_finalize(stmt)
        return results
    }

    
    

}
