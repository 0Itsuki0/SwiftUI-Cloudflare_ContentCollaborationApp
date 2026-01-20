//
//  JoinRoomView.swift
//  TwilioVideoChat
//
//  Created by Itsuki on 2026/01/20.
//

import SwiftUI

struct JoinRoomView: View {
    @Environment(VideoRoomManager.self) private var roomManager

    @State private var roomName = "itsuki's room"

    @State private var progressingMessage: String? = nil

    var body: some View {
        let localParticipantManager = roomManager.localParticipantManager

        VStack(
            alignment: .leading,
            spacing: 36,
            content: {
                VStack(alignment: .leading, spacing: 16) {
                    HStack(spacing: 16) {
                        Text("Room")
                            .font(.headline)
                        TextField("", text: $roomName)
                            .textFieldStyle(.roundedBorder)
                    }

                    Text("You will be joining as \n\(roomManager.identity)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                }

                VStack(alignment: .leading, spacing: 16) {

                    RoundedRectangle(cornerRadius: 8)
                        .fill(.black)
                        .aspectRatio(1.5, contentMode: .fit)
                        .overlay(content: {
                            if localParticipantManager.isCameraOn,
                                let cameraPreview = localParticipantManager
                                    .cameraPreview
                            {
                                CameraPreviewViewRepresentable(
                                    previewView: cameraPreview
                                )
                            }
                        })
                        .overlay(
                            alignment: .bottom,
                            content: {
                                HStack(spacing: 16) {
                                    ToggleCameraMicButton(
                                        setOnOff: {
                                            Task {
                                                self.progressingMessage =
                                                    "Starting Camera..."
                                                localParticipantManager
                                                    .isCameraOn
                                                    ? await
                                                        localParticipantManager
                                                        .stopCamera()
                                                    : await
                                                        localParticipantManager
                                                        .startCamera()
                                                self.progressingMessage = nil
                                            }

                                        },
                                        isOn: localParticipantManager
                                            .isCameraOn,
                                        isCamera: true
                                    )

                                    ToggleCameraMicButton(
                                        setOnOff: {
                                            localParticipantManager.isMicOn
                                                ? localParticipantManager
                                                    .stopMic()
                                                : localParticipantManager
                                                    .startMic()
                                        },
                                        isOn: localParticipantManager.isMicOn,
                                        isCamera: false
                                    )

                                }
                                .padding(.bottom, 8)
                            }
                        )

                    if let error = localParticipantManager.error {
                        Text(error)
                            .foregroundStyle(.red)
                    }

                }

                VStack(alignment: .leading, spacing: 16) {

                    Button(
                        action: {
                            Task {
                                self.progressingMessage =
                                    "Creating / Joining Room..."
                                await self.roomManager.createJoinRoom(
                                    self.roomName,
                                    micOn: localParticipantManager.isMicOn,
                                    cameraOn: localParticipantManager.isCameraOn
                                )
                                self.progressingMessage = nil
                            }
                        },
                        label: {
                            Text("JOIN")
                                .padding(.vertical, 8)
                                .font(.headline)
                        }
                    )
                    .buttonStyle(.borderedProminent)
                    .buttonSizing(.flexible)

                    if let error = self.roomManager.connectionState.error {
                        Text(error)
                            .foregroundStyle(.red)
                    }
                }
            }
        )
        .padding(.all, 24)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(.yellow.opacity(0.1))
        .navigationTitle("Join A Room")
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
            self.progressingMessage = nil
        }
        .onDisappear {
            self.progressingMessage = nil
        }

    }
}
