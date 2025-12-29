//
//  AppInfo.swift
//  kfsNotes
//
//  Created by Pavel Dřímalka on 29.12.2025.
//

import Foundation

struct AppInfo {
    static let version = ProcessInfo.processInfo.environment["APP_VERSION"] ?? "v0.0.0"
    static let build = ProcessInfo.processInfo.environment["APP_BUILD"] ?? "0"

    static let full: String = "\(version) (\(build))"
}
