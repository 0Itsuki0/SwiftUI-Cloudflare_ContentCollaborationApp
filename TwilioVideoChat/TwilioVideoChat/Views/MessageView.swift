//
//  MessageView.swift
//  TwilioVideoChat
//
//  Created by Itsuki on 2026/01/20.
//

import SwiftUI
import TwilioVideo

struct MessageView: View {
    @Environment(VideoRoomManager.self) private var roomManager

    @FocusState var focused: Bool

    @State private var entry: String = ""
    @State private var scrollPosition: ScrollPosition = .init()

    @State private var entryHeight: CGFloat = 24
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollViewReader { proxy in

                List {
                    ForEach(roomManager.messages) { message in
                        let local =
                            message.participant.identity
                            == roomManager.localParticipantManager.participant?
                            .identity
                        self.messageView(
                            message.message,
                            isLocal: local,
                            identity: message.participant.identity
                        )
                        .id(message.id)
                    }
                }
                .contentMargins(.top, 0)
                .scrollTargetLayout()
                .scrollPosition($scrollPosition, anchor: .bottom)
                .defaultScrollAnchor(.bottom, for: .alignment)
                .defaultScrollAnchor(.bottom, for: .initialOffset)
                .scrollContentBackground(.hidden)
                .background(.gray.opacity(0.05))
                .onChange(
                    of: roomManager.messages,
                    initial: true,
                    {
                        if let last = roomManager.messages.last {
                            proxy.scrollTo(last.id, anchor: .bottom)
                        }
                    }
                )
                .overlay(content: {
                    if roomManager.messages.isEmpty {
                        ContentUnavailableView(
                            "No Messages yet",
                            systemImage: "character.bubble",
                            description: Text("Enter some messages to start.")
                        )
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }

                })

            }
            .safeAreaInset(
                edge: .bottom,
                content: {
                    HStack(spacing: 12) {
                        TextField("", text: $entry, axis: .vertical)
                            .focused($focused)
                            .onSubmit({
                                self.sendMessage()
                            })
                            .padding(.vertical, 4)
                            .padding(.horizontal, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(.gray, style: .init(lineWidth: 1))
                                    .fill(.white.opacity(0.8))
                            )

                        Button(
                            action: {
                                self.sendMessage()
                            },
                            label: {
                                Image(systemName: "paperplane.fill")
                            }
                        )

                    }
                    .padding(.vertical, 16)
                    .padding(.horizontal, 24)
                    .background(.gray.opacity(0.5))
                    .background(.white)
                }
            )
            .foregroundStyle(.black.opacity(0.8))
            .onTapGesture(perform: {
                self.focused = false
            })
            .toolbar(content: {
                ToolbarItem(
                    placement: .topBarTrailing,
                    content: {
                        Button(
                            action: {
                                self.roomManager.newMessageCount = 0
                                self.dismiss()
                            },
                            label: {
                                Image(systemName: "xmark")
                            }
                        )
                    }
                )
            })
            .navigationTitle("Messages")
        }

    }

    @ViewBuilder
    private func messageView(_ text: String, isLocal: Bool, identity: String)
        -> some View
    {
        VStack(
            alignment: isLocal ? .trailing : .leading,
            spacing: 8,
            content: {
                Text(text)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 8).fill(
                            .secondary.opacity(0.3)
                        )
                    )

                Text(isLocal ? "Me(\(identity))" : identity)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                    .foregroundStyle(.secondary)
                    .font(.caption)
                    .padding(isLocal ? .trailing : .leading, 4)

            }
        )
        .listRowBackground(Color.clear)
        .padding(isLocal ? .leading : .trailing, 64)
        .padding(.vertical, 8)
        .listRowInsets(.vertical, 0)
        .listRowInsets(.horizontal, 8)
        .listRowSeparator(.hidden)

    }

    private func sendMessage() {
        self.focused = false
        let entry = self.entry.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !entry.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        else {
            return
        }
        self.entry = ""
        roomManager.localParticipantManager.sendMessage(entry)
    }

}
