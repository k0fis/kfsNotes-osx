//
//  Untitled.swift
//  kfsNotes
//
//  Created by Pavel Dřímalka on 01.01.2026.
//

import Foundation

final class JoplinConfigStore {

    private let key = "joplin.config"

    func load() -> JoplinConfig? {
        guard
            let data = UserDefaults.standard.data(forKey: key),
            let config = try? JSONDecoder().decode(JoplinConfig.self, from: data)
        else { return nil }
        return config
    }

    func save(_ config: JoplinConfig) {
        if let data = try? JSONEncoder().encode(config) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }

    func clear() {
        UserDefaults.standard.removeObject(forKey: key)
    }
}
