//
//  ContentView.swift
//  CloudflareContentCollaboration
//
//  Created by Itsuki on 2026/01/24.
//

import SwiftUI

struct ContentView: View {
    @State private var documentManager = DocumentManager()

    var body: some View {

        NavigationStack {
            Group {
                if documentManager.documentId != nil {
                    DocumentCollaborationView()
                        .environment(documentManager)
                } else {
                    OpenDocumentView()
                        .environment(documentManager)
                }
            }

        }
    }
}
