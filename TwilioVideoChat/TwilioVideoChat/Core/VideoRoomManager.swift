//
//  VideoRoomManager.swift
//  TwilioVideoChat
//
//  Created by Itsuki on 2026/01/19.
//

import SwiftUI
import TwilioVideo

@Observable
class VideoRoomManager: NSObject {

    var newMessageCount: Int = 0

    var messages: [DataTrackMessage] {
        var messages = localParticipantManager.messages
        messages.append(
            contentsOf: remoteParticipantManagers.flatMap(\.messages)
        )
        return messages.sorted(by: { first, second in
            first.createdAt < second.createdAt
        })
    }

    private(set) var room: Room?

    private(set) var connectionState: ConnectionState = .disconnected

    private(set) var localParticipantManager = LocalParticipantManager()
    private(set) var remoteParticipantManagers: [RemoteParticipantManager] = []

    private static let identityKey: String = "identity"
    private(set) var identity: String = "" {
        didSet {
            UserDefaults.standard.set(
                self.identity,
                forKey: VideoRoomManager.identityKey
            )
        }
    }

    override init() {
        super.init()
        self.identity =
            UserDefaults.standard.string(forKey: VideoRoomManager.identityKey)
            ?? UUID().uuidString
    }

    // If the room already exist with the given name, this function will join the existing room.
    // Otherwise, a new room will be created
    func createJoinRoom(_ roomName: String, micOn: Bool, cameraOn: Bool) async {
        guard
            self.connectionState != .connecting
                && self.connectionState != .connected
        else {
            return
        }
        self.connectionState = .disconnected

        print("\(#file), \(#function)")
        do {
            let token = try await self.getAccessToken(
                identity: self.identity,
                roomName: roomName
            )
            let connectOptions: ConnectOptions = .init(
                token: token,
                block: { builder in
                    builder.roomName = roomName
                    builder.dataTracks = [
                        self.localParticipantManager.dataTrack
                    ].compactMap({ $0 })
                    if micOn {
                        builder.audioTracks = [
                            self.localParticipantManager.audioTrack
                        ].compactMap({ $0 })
                    }
                    if cameraOn {
                        builder.videoTracks = [
                            self.localParticipantManager.videoTrack
                        ].compactMap({ $0 })
                    }
                }
            )

            self.room = TwilioVideoSDK.connect(
                options: connectOptions,
                delegate: self
            )
            self.connectionState = .connecting
        } catch (let error) {
            self.connectionState = .error(error.localizedDescription)
        }
    }

    func leaveRoom() {
        room?.disconnect()
        room = nil
        self.connectionState = .disconnecting
        Task {
            await self.localParticipantManager.stopCamera()
        }
    }

    private func getAccessToken(identity: String, roomName: String) async throws
        -> String
    {

        guard let url = URL(string: "\(ServerConfig.url)") else {
            throw NetworkError.failToCreateURL
        }
        let request = GetAccessTokenRequest(
            identity: identity,
            roomName: roomName
        )
        let body = try JSONEncoder().encode(request)

        let data = try await NetworkService.sendURLRequest(
            url: url,
            method: ServerConfig.method,
            headers: ServerConfig.headers,
            body: body
        )

        let accessTokenResponse = try NetworkService.decode(
            GetAccessTokenResponse.self,
            from: data
        )

        return accessTokenResponse.token
    }

    private func managerForParticipant(_ participant: RemoteParticipant)
        -> RemoteParticipantManager
    {
        if let manager = self.remoteParticipantManagers.first(where: {
            $0.identity == participant.identity
        }) {
            // manually update to ensure view updates
            manager.participant = participant
            return manager
        }
        let manager = RemoteParticipantManager(
            participant: participant,
            onNewMessage: {
                self.newMessageCount += 1
            }
        )
        self.remoteParticipantManagers.append(manager)
        return manager
    }
}

// MARK: - RoomDelegate
// update the room property manually so that the view can be re-rendered
// the local `room` property will always contain the newest information without re-assigning such as localParticipant or remoteParticipants
// However, the view update will not be triggered, ie:  we might find that remote participant video not showing up.
extension VideoRoomManager: RoomDelegate {

    func roomDidConnect(room: Room) {
        print("\(#file), \(#function)")
        self.room = room
        self.localParticipantManager.participant = room.localParticipant
        self.remoteParticipantManagers = room.remoteParticipants.map({
            RemoteParticipantManager(
                participant: $0,
                onNewMessage: {
                    self.newMessageCount += 1
                }
            )
        })
        self.connectionState = .connected
    }

    func roomDidReconnect(room: Room) {
        print("\(#file), \(#function)")
        self.room = room
        self.connectionState = .connected
    }

    func roomDidDisconnect(room: Room, error: (any Error)?) {
        print("\(#file), \(#function)")
        self.room = nil
        if let error {
            self.connectionState = .error(error.localizedDescription)
        } else {
            self.connectionState = .disconnected
        }
    }

    func participantDidConnect(room: Room, participant: RemoteParticipant) {
        print("\(#file), \(#function)")
        self.room = room
        let manager = self.managerForParticipant(participant)
        manager.connectionState = .connected
    }

    func participantDidReconnect(room: Room, participant: RemoteParticipant) {
        print("\(#file), \(#function)")
        self.room = room
        let manager = self.managerForParticipant(participant)
        manager.connectionState = .connected
    }

    func participantDidDisconnect(room: Room, participant: RemoteParticipant) {
        print("\(#file), \(#function)")
        self.room = room
        self.remoteParticipantManagers.removeAll(where: {
            $0.identity == participant.identity
        })
    }

    func participantIsReconnecting(room: Room, participant: RemoteParticipant) {
        print("\(#file), \(#function)")
        self.room = room
        let manager = self.managerForParticipant(participant)
        manager.connectionState = .connected
    }

    func dominantSpeakerDidChange(room: Room, participant: RemoteParticipant?) {
        print("\(#file), \(#function)")
        self.room = room
    }

}
