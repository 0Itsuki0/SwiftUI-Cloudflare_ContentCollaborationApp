//
//  RoomView.swift
//  TwilioVideoChat
//
//  Created by Itsuki on 2026/01/20.
//

import SwiftUI
import TwilioVideo

struct RoomView: View {
    @Environment(VideoRoomManager.self) private var roomManager

    @State private var showMessagesSheet: Bool = false

    var body: some View {
        if let room = roomManager.room {
            VStack(alignment: .leading, spacing: 36) {

                VStack(alignment: .leading, spacing: 16) {
                    Text("Other Participants")
                        .font(.headline)

                    if roomManager.remoteParticipantManagers.isEmpty {
                        Text("No one else is in the room...")
                            .foregroundStyle(.secondary)
                    } else {
                        ScrollView(
                            .horizontal,
                            content: {
                                HStack {
                                    ForEach(
                                        roomManager.remoteParticipantManagers,
                                        id: \.identity
                                    ) { remoteParticipant in
                                        self.videoView(
                                            track: remoteParticipant
                                                .cameraTrack,
                                            shouldMirror: false,
                                            isDominantSpeaker: room
                                                .dominantSpeaker?.identity
                                                == remoteParticipant.identity,
                                            isCameraOn: remoteParticipant
                                                .isCameraOn,
                                            isMicOn: remoteParticipant.isMicOn,
                                            toggleCamera: nil,
                                            toggleMic: nil
                                        )
                                        .overlay(content: {
                                            Group {
                                                switch remoteParticipant
                                                    .connectionState
                                                {
                                                case .disconnected:
                                                    Text("Disconnected...")
                                                case .connecting:
                                                    Text("Connecting...")
                                                case .disconnecting:
                                                    Text("Disconnecting...")
                                                case .error(let error):
                                                    Text(error)
                                                        .foregroundStyle(.red)
                                                default:
                                                    EmptyView()
                                                }
                                            }
                                            .foregroundStyle(.white)
                                        })
                                    }
                                }
                                .frame(height: 120)
                            }
                        )
                        .scrollBounceBehavior(.basedOnSize, axes: .horizontal)

                    }
                }

                VStack(alignment: .leading, spacing: 16) {
                    let localParticipantManager = roomManager
                        .localParticipantManager
                    Text("Me")
                        .font(.headline)

                    self.videoView(
                        track: localParticipantManager.videoTrack,
                        shouldMirror: true,
                        isDominantSpeaker: room.dominantSpeaker?.identity
                            == localParticipantManager.participant?.identity,
                        isCameraOn: localParticipantManager.isCameraOn,
                        isMicOn: localParticipantManager.isMicOn,
                        toggleCamera: {
                            Task {
                                localParticipantManager.isCameraOn
                                    ? await localParticipantManager.stopCamera()
                                    : await localParticipantManager.startCamera()
                            }
                        },
                        toggleMic: {
                            localParticipantManager.isMicOn
                                ? localParticipantManager.stopMic()
                                : localParticipantManager.startMic()
                        }
                    )
                }
            }
            .padding(.all, 24)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .background(.yellow.opacity(0.1))
            .navigationTitle("Room: \(room.name)")
            .toolbar(content: {
                ToolbarItem(
                    placement: .topBarTrailing,
                    content: {
                        Button(
                            action: {
                                self.roomManager.leaveRoom()
                            },
                            label: {
                                Text("Leave")
                            }
                        )
                    }
                )

                ToolbarItem(
                    placement: .topBarTrailing,
                    content: {
                        Button(
                            action: {
                                self.roomManager.newMessageCount = 0
                                self.showMessagesSheet = true
                            },
                            label: {
                                Text("Messages")
                            }
                        )
                        .badge(self.roomManager.newMessageCount)
                        .id(self.roomManager.newMessageCount)  // to force badge update
                    }
                )
            })
            .sheet(
                isPresented: $showMessagesSheet,
                content: {
                    MessageView()
                        .environment(self.roomManager)
                }
            )
        }

    }

    @ViewBuilder
    private func videoView(
        track: VideoTrack?,
        shouldMirror: Bool,
        isDominantSpeaker: Bool,
        isCameraOn: Bool,
        isMicOn: Bool,
        toggleCamera: (() -> Void)?,
        toggleMic: (() -> Void)?
    ) -> some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(.black)
            .aspectRatio(1.5, contentMode: .fit)
            .overlay(content: {
                if let track {
                    VideoViewRepresentable(
                        videoTrack: track,
                        shouldMirror: shouldMirror
                    )
                }
            })
            .overlay(
                alignment: .bottom,
                content: {
                    HStack(spacing: 16) {
                        ToggleCameraMicButton(
                            setOnOff: toggleCamera,
                            isOn: isCameraOn,
                            isCamera: true
                        )

                        ToggleCameraMicButton(
                            setOnOff: toggleMic,
                            isOn: isMicOn,
                            isCamera: false
                        )
                    }
                    .padding(.bottom, 8)
                }
            )
            .overlay(
                alignment: .topLeading,
                content: {
                    if isDominantSpeaker {
                        Image(systemName: "microphone.circle")
                            .font(.system(size: 36))
                            .fontWeight(.semibold)
                            .foregroundStyle(.red)
                            .padding(.all, 8)

                    }
                }
            )

    }
}
