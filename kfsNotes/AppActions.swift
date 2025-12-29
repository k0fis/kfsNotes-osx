//
//  AppActions.swift
//  kfs KB
//
//  Created by Pavel Dřímalka on 25.12.2025.
//

import Cocoa

enum AppActions {

    static func openSave() {
        WindowController.shared.showSave()
    }

    static func openSearch() {
        WindowController.shared.showSearch()
    }
}
