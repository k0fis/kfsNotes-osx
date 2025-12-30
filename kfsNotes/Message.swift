//
//  Message.swift
//  kfs KB
//
//  Created by Pavel Dřímalka on 25.12.2025.
//

import Foundation

struct Message : Identifiable, Hashable{
    let id: Int
    var text: String
    var link: String
    var tags: String
    var note: String
    let createdAt: String
}
