//
//  JoplinAPI.swift
//  kfsNotes
//
//  Created by Pavel Dřímalka on 01.01.2026.
//

import Foundation

struct JoplinAPI {

    let config: JoplinConfig
    let tags : JoplinCache

    init(config: JoplinConfig) {
        self.config = config
        tags = JoplinCache()
    }

    private var baseURL: URL {
        URL(string: config.baseURL)!
    }

    private func request_o(
        _ path: String,
        method: String = "GET",
        body: Data? = nil
    ) throws -> URLRequest {

        var url = baseURL.appendingPathComponent(path)
        url.append(queryItems: [
            URLQueryItem(name: "token", value: config.token)
        ])

        var req = URLRequest(url: url)
        req.httpMethod = method
        req.httpBody = body
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        return req
    }
    
    private func request(
        path: String,
        query: [URLQueryItem] = [],
        method: String = "GET",
        body: Data? = nil
    ) throws -> URLRequest {

        var components = URLComponents(
            url: baseURL.appendingPathComponent(path),
            resolvingAgainstBaseURL: false
        )!

        components.queryItems = query + [
            URLQueryItem(name: "token", value: config.token)
        ]

        guard let url = components.url else {
            throw URLError(.badURL)
        }

        var req = URLRequest(url: url)
        req.httpMethod = method
        req.httpBody = body
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        return req
    }

    private func checkedData(
        for req: URLRequest
    ) async throws -> Data {
        let (data, response) = try await URLSession.shared.data(for: req)

        guard let http = response as? HTTPURLResponse else {
            throw JoplinError.invalidResponse
        }

        switch http.statusCode {
        case 200...299:
            return data

        case 404:
            throw JoplinError.notFound

        default:
            let msg = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw JoplinError.api(msg)
        }
    }
    
    // MARK: - ping
    
    func ping() async throws {
        let url = URL(string: "\(config.baseURL)/ping")!
        let (_, response) = try await URLSession.shared.data(from: url)

        guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
    }
    
    // MARK: - joplin folder
    func getOrCreateDefaultFolder() async throws -> String {
        let folders = try await fetchFolders()

        if let existing = folders.first(where: { $0.title == "kfsNotes" }) {
            return existing.id
        }

        return try await createFolder(title: "kfsNotes")
    }

    private func fetchFolders() async throws -> [JoplinFolder] {
        let req = try request_o("/folders")

        let (data, _) = try await URLSession.shared.data(for: req)
        let decoded = try JSONDecoder().decode(
            JoplinPage<JoplinFolder>.self,
            from: data
        )

        return decoded.items
    }

    private func createFolder(title: String) async throws -> String {
        let payload = try JSONSerialization.data(withJSONObject: [
            "title": title
        ])

        let req = try request_o("/folders", method: "POST", body: payload)
        let (data, _) = try await URLSession.shared.data(for: req)

        let folder = try JSONDecoder().decode(JoplinFolder.self, from: data)
        return folder.id
    }
    
    // MARK: - create note
    
    func createNote(title: String, body: String) async throws -> String {

        let folderId = try await getOrCreateDefaultFolder()

        let payload = try JSONSerialization.data(withJSONObject: [
            "title": title,
            "body": body,
            "parent_id": folderId
        ])

        let req = try request_o("/notes", method: "POST", body: payload)
        let (data, _) = try await URLSession.shared.data(for: req)

        let response = try JSONDecoder().decode(JoplinNoteResponse.self, from: data)
        return response.id
    }
    
    // MARK: - update
    
    func updateNote(id: String, title: String, body: String) async throws {

        let payload = try JSONSerialization.data(withJSONObject: [
            "title": title,
            "body": body
        ])

        let req = try request_o("/notes/\(id)", method: "PUT", body: payload)
        _ = try await checkedData(for: req)
    }

    // MARK: - tags
    func getOrCreateTag(title: String) async throws -> String {

         let tags = try await fetchAllTags()

         if let existing = tags.first(where: {
             $0.title.caseInsensitiveCompare(title) == .orderedSame
         }) {
             return existing.id
         }

         return try await createTag(title: title)
     }
        
    func fetchAllTags() async throws -> [JoplinTag] {
        return try await tags.getTags(api: self)
    }
        
    func _fetchAllTags() async throws -> [JoplinTag] {
        var page = 1
        var all: [JoplinTag] = []
        while true {
            let req = try request(path: "tags",
                                  query: [
                                    URLQueryItem(name: "page", value: String(page)),
                                    URLQueryItem(name: "limit", value: "100")
                                  ])
            let (data, _) = try await URLSession.shared.data(for: req)
            
            //print(String(decoding: data, as: UTF8.self))
            
            let decoded = try JSONDecoder().decode(
                JoplinPage<JoplinTag>.self,
                from: data
            )
            all.append(contentsOf: decoded.items)
            if !decoded.hasMore {
                break
            }
            page += 1
        }
        return all
    }

    private func createTag(title: String) async throws -> String {
         let payload = try JSONSerialization.data(withJSONObject: [
             "title": title
         ])

         let req = try request_o("/tags", method: "POST", body: payload)
         let (data, _) = try await URLSession.shared.data(for: req)

         let tag = try JSONDecoder().decode(JoplinTag.self, from: data)
         return tag.id
     }
    
    func applyTags(_ tags: [String], toNote noteId: String) async throws {

        for raw in tags {
            let tag = raw.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !tag.isEmpty else { continue }

            let tagId = try await getOrCreateTag(title: tag)

            let payload = try JSONSerialization.data(withJSONObject: [
                "id": noteId
            ])

            let req = try request_o(
                "/tags/\(tagId)/notes",
                method: "POST",
                body: payload
            )

            _ = try await checkedData(for: req)
        }
    }
}

struct JoplinFolder: Decodable {
    let id: String
    let title: String
    let parent_id: String?
}

struct JoplinNoteResponse: Decodable {
    let id: String
}

struct JoplinTag: Decodable {
    let id: String
    let title: String
}

struct JoplinPage<T: Decodable>: Decodable {
    let items: [T]
    let has_more: Bool?

    var hasMore: Bool {
        has_more ?? false
    }
}

actor JoplinCache {
    var tags: [JoplinTag] = []
    
    public func getTags(api: JoplinAPI) async throws -> [JoplinTag]{
        guard tags.isEmpty else { return tags }
        
        tags = try await api._fetchAllTags();
        
        return tags;
    }
}
