//
//  DocumentCollaborationView.swift
//  CloudflareContentCollaboration
//
//  Created by Itsuki on 2026/01/26.
//

import SwiftUI

struct DocumentCollaborationView: View {
    @Environment(DocumentManager.self) private var documentManager

    @State private var selection: TextSelection?
    @State private var text: String = ""

    var body: some View {
        if let documentId = documentManager.documentId {
            VStack(spacing: 36) {
                TextEditor(text: $text, selection: $selection)
                    .textEditorStyle(.plain)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 4).fill(.clear).stroke(
                            .secondary,
                            style: .init()
                        )
                    )
                    .containerRelativeFrame(
                        .vertical,
                        { length, axis in
                            if axis == .horizontal {
                                return length
                            }
                            return length * 0.6
                        }
                    )

                if let error = documentManager.error {
                    Text(error.localizedDescription)
                        .foregroundStyle(.red)
                }

                VStack(
                    alignment: .leading,
                    spacing: 16,
                    content: {
                        Text("Collaborators")
                            .font(.headline)
                        let collaborators = self.documentManager.collaborators
                            .filter({ $0 != self.documentManager.userID })
                        ForEach(Array(collaborators), id: \.self) {
                            collaborator in
                            Text("- \(collaborator)")
                                .lineLimit(1)
                                .foregroundStyle(.secondary)
                        }

                        if collaborators.isEmpty {
                            Text("No Collaborators.")
                                .foregroundStyle(.secondary)

                        }
                    }
                )
                .frame(maxWidth: .infinity, alignment: .leading)

            }
            .disabled(self.documentManager.wsConnectionState != .connected)
            .overlay(content: {
                if self.documentManager.wsConnectionState != .connected {
                    VStack(spacing: 36) {

                        switch self.documentManager.wsConnectionState {
                        case .connected:
                            EmptyView()
                        case .connecting:
                            ProgressView(label: {
                                Text("Connecting...")
                            })
                            .controlSize(.extraLarge)
                            .frame(maxWidth: .infinity)

                        case .disConnected:
                            Text("You are disconnected From the server.")
                                .font(.headline)

                            HStack {
                                Button(
                                    role: .destructive,
                                    action: {
                                        self.documentManager.closeDocument()
                                    },
                                    label: {
                                        Text("Close")
                                    }
                                )

                                Spacer()

                                Button(
                                    action: {
                                        Task {
                                            await self.documentManager
                                                .openOrCreateDocument(
                                                    documentId
                                                )
                                        }
                                    },
                                    label: {
                                        Text("Re-Connect")
                                    }
                                )
                            }
                        }
                    }
                    .fixedSize(horizontal: true, vertical: false)
                    .buttonStyle(.borderedProminent)
                    .foregroundStyle(.background)
                    .padding(.all, 36)
                    .background(
                        RoundedRectangle(cornerRadius: 8).fill(.foreground)
                    )

                }
            })
            .padding(.all, 24)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .background(.yellow.opacity(0.1))
            .navigationTitle("Doc: \(documentId)")
            .onChange(
                of: text,
                { old, new in
                    guard new != self.documentManager.currentContent else {
                        return
                    }
                    self.documentManager.applyDocumentUpdate(old: old, new: new)
                }
            )
            .task {
                for await contentUpdate in self.documentManager.contentUpdates {
                    guard contentUpdate != self.text else {
                        continue
                    }
                    self.updateText(old: self.text, new: contentUpdate)
                }
            }
            .onAppear {
                self.documentManager.error = nil
            }
            .onDisappear {
                self.documentManager.error = nil
            }
            .toolbar(content: {
                ToolbarItem(
                    placement: .topBarTrailing,
                    content: {
                        Button(
                            action: {
                                self.documentManager.closeDocument()
                            },
                            label: {
                                Text("Close")
                            }
                        )
                    }
                )
            })

        }

    }

    private func updateText(old: String, new: String) {
        let range = self.getNewSelectionRange(old: old, new: new)
        self.text = new
        if let range {
            self.selection = .init(range: range)
        }
    }

    private func getNewSelectionRange(old: String, new: String) -> Range<
        String.Index
    >? {
        guard let selection else {
            return nil
        }

        let differences = new.utf8.difference(from: old.utf8)
        guard !differences.isEmpty else {
            return nil
        }

        guard let range: Range<Int> = selection.utf8Range(in: old) else {
            return nil
        }
        let isInsertion: Bool = selection.isInsertion

        var newRangeLower = range.lowerBound
        var newRangeUpper = range.upperBound

        for difference in differences {
            switch difference {

            case .insert(let offset, element: _, associatedWith: _):
                if offset > newRangeUpper {
                    continue
                }
                if (newRangeLower..<newRangeUpper).contains(offset),
                    !isInsertion
                {
                    newRangeUpper += 1
                } else {
                    newRangeUpper += 1
                    newRangeLower += 1
                }
            case .remove(let offset, element: _, associatedWith: _):
                if offset >= newRangeUpper {
                    continue
                }
                if (newRangeLower..<newRangeUpper).contains(offset),
                    !isInsertion
                {
                    newRangeUpper -= 1
                } else {
                    newRangeUpper -= 1
                    newRangeLower -= 1
                }
            }
        }

        let newStringRangeLower = String.Index(
            utf8Offset: newRangeLower,
            in: new
        )
        let newStringRangeUpper = String.Index(
            utf8Offset: newRangeUpper,
            in: new
        )

        return newStringRangeLower..<newStringRangeUpper
    }

}
