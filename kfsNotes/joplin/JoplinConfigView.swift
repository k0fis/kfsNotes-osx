//
//  JoplinConfigView.swift
//  kfsNotes
//
//  Created by Pavel Dřímalka on 01.01.2026.
//

import SwiftUI

struct JoplinConfigView: View {

    @Environment(\.dismiss) private var dismiss
    
    @StateObject private var vm = JoplinConfigViewModel()

    var onSaved: (() -> Void)?
    var onClose: (() -> Void)?
    
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Joplin Export Configuration")
                .font(.headline)
            TextField("Base URL", text: $vm.baseURL)
            SecureField("Token", text: $vm.token)
            
            HStack {
                Button("Test connection") {
                    Task { await vm.testConnection() }
                }
                .disabled(vm.isTesting)
                
                if let status = vm.statusMessage {
                    Text(status)
                        .foregroundColor(status.contains("successful") ? .green : .red)
                }
            }
            HStack {
                Button("Save") {
                    vm.save()
                    onSaved?()
                    dismiss()
                    onClose?()
                }
                .keyboardShortcut("s")
                .buttonStyle(.borderedProminent)
                Spacer()

                Button("Reset") {
                    Task {
                        do {
                            try SQLiteManager.shared.resetExport(system: JoplinExporter().name)
                            dismiss()
                            onClose?()
                        } catch {
                            vm.statusMessage = "Reset failed: \(error.localizedDescription)"
                        }
                    }
                }
                .keyboardShortcut("c")
                .buttonStyle(.borderedProminent)

                Button("Cancel") {
                    dismiss()
                    onClose?()
                }
                .keyboardShortcut("c")
                .buttonStyle(.borderedProminent)

                

                
            }
        }
        .padding()
        .frame(width: 420)
        .onExitCommand {onClose?()}
    }
}
