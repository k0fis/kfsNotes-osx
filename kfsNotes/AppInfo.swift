//
//  AppInfo.swift
//  kfsNotes
//
//  Created by Pavel Dřímalka on 29.12.2025.
//

struct AppInfo {
    #if APP_VERSION
    static let version = APP_VERSION
    #else
    static let version = "v0.0.0"
    #endif

    #if APP_BUILD
    static let build = APP_BUILD
    #else
    static let build = "0"
    #endif

    static let full: String = "\(version) (\(build))"
}
