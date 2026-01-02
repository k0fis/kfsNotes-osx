//
//  JoplinConfigViewModel.swift
//  kfsNotes
//
//  Created by Pavel Dřímalka on 01.01.2026.
//

import Foundation
internal import Combine

@MainActor
final class JoplinConfigViewModel: ObservableObject {

    @Published var baseURL: String = ""
    @Published var token: String = ""
    @Published var statusMessage: String?
    @Published var isTesting = false

    private let store = JoplinConfigStore()

    init() {
        if let cfg = store.load() {
            baseURL = cfg.baseURL
            token = cfg.token
        } else {
            baseURL = "http://127.0.0.1:41184"
        }
    }

    func testConnection() async {
        isTesting = true
        statusMessage = nil

        let config = JoplinConfig(baseURL: baseURL, token: token)
        do {
            try await JoplinAPI(config: config).ping()
            statusMessage = "Connection successful"
        } catch {
            statusMessage = "Connection failed"
        }

        isTesting = false
    }

    func save() {
        let cfg = JoplinConfig(baseURL: baseURL, token: token)
        store.save(cfg)
    }
}
