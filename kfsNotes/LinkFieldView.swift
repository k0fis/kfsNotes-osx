//
//  LinkFieldView.swift
//  kfsNotes
//
//  Created by Pavel Dřímalka on 30.12.2025.
//

import SwiftUI

struct LinkFieldView: View {

    @Binding var link: String

    var body: some View {
        HStack {
            TextField("https://...", text: $link)
                .textFieldStyle(RoundedBorderTextFieldStyle())

            Button {
                openDefault()
            } label: {
                Image(systemName: "arrow.up.right.square")
            }
            .buttonStyle(.borderless)
            .contextMenu {
                browserMenu
            }
        }
    }

    // MARK: - Menu

    @ViewBuilder
    private var browserMenu: some View {
        Button("Open in Default Browser") {
            openDefault()
        }

        Divider()

        if let url = normalizedURL {
            ForEach(availableBrowsers(for: url), id: \.self) { appURL in
                Button(appURL.deletingPathExtension().lastPathComponent) {
                    open(in: appURL)
                }
            }
        }
    }

    func availableBrowsers(for url: URL) -> [URL] {
        NSWorkspace.shared.urlsForApplications(toOpen: url)
    }

    // MARK: - Actions

    private var normalizedURL: URL? {
        let raw = link.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !raw.isEmpty else { return nil }
        return URL(string: raw.hasPrefix("http") ? raw : "https://\(raw)")
    }

    private func openDefault() {
        guard let url = normalizedURL else { return }
        NSWorkspace.shared.open(url)
    }

    private func open(in appURL: URL) {
        guard let url = normalizedURL else { return }
        NSWorkspace.shared.open(
            [url],
            withApplicationAt: appURL,
            configuration: .init(),
            completionHandler: nil
        )
    }
}
