//
//  ExternalExport.swift
//  kfsNotes
//
//  Created by Pavel Dřímalka on 31.12.2025.
//

import Foundation

struct ExternalExport {
    let id: Int
    let messageId: Int
    let system: String
    let externalId: String
    let exportedAt: Date?
}


extension Date {
    var unixTimestamp: Int {
        Int(timeIntervalSince1970)
    }

    static func fromUnix(_ value: Int) -> Date {
        Date(timeIntervalSince1970: TimeInterval(value))
    }
}
