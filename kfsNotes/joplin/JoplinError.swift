//
//  JoplinError.swift
//  kfsNotes
//
//  Created by Pavel Dřímalka on 02.01.2026.
//

import Foundation

enum JoplinError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case unauthorized
    case notFound
    case api(String)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid Joplin URL"
        case .invalidResponse:
            return "Invalid response from Joplin"
        case .unauthorized:
            return "Invalid Joplin token"
        case .api(let msg):
            return msg
        case .notFound:
            return "Not Found";
        }
    }
}
