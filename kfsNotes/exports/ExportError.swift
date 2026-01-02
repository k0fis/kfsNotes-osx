//
//  ExportError.swift
//  kfsNotes
//
//  Created by Pavel Dřímalka on 01.01.2026.
//

import Foundation

enum ExportError: LocalizedError {
    case missingConfig
    case connectionFailed

    var errorDescription: String? {
        switch self {
        case .missingConfig:
            return "Joplin is not configured"
        case .connectionFailed:
            return "Cannot connect to Joplin"
        }
    }
}
