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
    let updatedAt: String
    
    func toMdString() -> String {
        var md = "# \(text)\n\n"
        
        if !tags.isEmpty {
            md += "**Tags:** \(tags)\n\n"
        }
        
        if !link.isEmpty {
            md += "**Link:** [\(link)](\(link))\n\n"
        }
        
        if !note.isEmpty {
            md += "**Note:** \(note)\n\n"
        }
        
        md += "_Created at: \(createdAt)_\n"
        md += "_Updated at: \(createdAt)_\n"
        return md
    }
    
    func toHTML() -> String {
        """
        <html>
        <body style="font-family: -apple-system; font-size: 13px;">
            <pre>\(escape(text))</pre>

            \(link.isEmpty ? "" :
                "<p><a href=\"\(escape(link))\">\(escape(link))</a></p>"
            )

            \(tags.isEmpty ? "" :
                "<p><strong>Tags:</strong> \(escape(tags))</p>"
            )

            \(note.isEmpty ? "" :
                "<hr/><p>\(escape(note).replacingOccurrences(of: "\n", with: "<br/>"))</p>"
            )
            <hr/>
            <p>Created at: \(escape(createdAt))</p>
            <p>Updated at: \(escape(updatedAt))</p>
        </body>
        </html>
        """
    }
    
    private func escape(_ s: String) -> String {
        s
            .replacingOccurrences(of: "&", with: "&amp;")
            .replacingOccurrences(of: "<", with: "&lt;")
            .replacingOccurrences(of: ">", with: "&gt;")
            .replacingOccurrences(of: "\"", with: "&quot;")
    }
}
