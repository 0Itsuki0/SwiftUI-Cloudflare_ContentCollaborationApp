//
//  OpenDocumentView.swift
//  CloudflareContentCollaboration
//
//  Created by Itsuki on 2026/01/26.
//

import SwiftUI

struct OpenDocumentView: View {
    @Environment(DocumentManager.self) private var documentManager

    @State private var documentName = "default"

    @State private var progressingMessage: String? = nil

    var body: some View {

        VStack(
            alignment: .leading,
            spacing: 36,
            content: {
                VStack(alignment: .leading, spacing: 16) {
                    HStack(spacing: 16) {
                        Text("Document")
                            .font(.headline)
                        TextField("", text: $documentName)
                            .textFieldStyle(.roundedBorder)
                    }

                    Text(
                        "If the document does not exist, a new one will be created with the give name."
                    )
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                    Text("You will be joining as \n\(documentManager.userID)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                }

                if let error = documentManager.error {
                    Text(error.localizedDescription)
                        .foregroundStyle(.red)
                }

                VStack(alignment: .leading, spacing: 16) {

                    Button(
                        action: {
                            Task {
                                self.progressingMessage =
                                    "Creating / Opening Document..."
                                await self.documentManager.openOrCreateDocument(
                                    self.documentName
                                )
                                self.progressingMessage = nil
                            }
                        },
                        label: {
                            Text("OPEN")
                                .padding(.vertical, 8)
                                .font(.headline)
                        }
                    )
                    .disabled(self.documentName.isEmpty)
                    .buttonStyle(.borderedProminent)
                    .buttonSizing(.flexible)

                }
            }
        )
        .padding(.all, 24)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(.yellow.opacity(0.1))
        .navigationTitle("Open/Create Doc")
        .overlay(content: {
            if let progressingMessage {
                ProgressView(label: {
                    Text(progressingMessage)
                })
                .controlSize(.extraLarge)
                .foregroundStyle(.secondary)
                .padding(.all, 36)
                .background(RoundedRectangle(cornerRadius: 8).fill(.white))
            }
        })
        .onAppear {
            self.documentManager.error = nil
            self.progressingMessage = nil
        }
        .onDisappear {
            self.documentManager.error = nil
            self.progressingMessage = nil
        }

    }
}
