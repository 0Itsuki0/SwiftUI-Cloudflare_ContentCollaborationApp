//
//  RemoteParticipantManager.swift
//  TwilioVideoChat
//
//  Created by Itsuki on 2026/01/19.
//

import SwiftUI
import TwilioVideo

@Observable
class RemoteParticipantManager: NSObject, Identifiable {
    var onNewMessage: () -> Void

    var connectionState: ConnectionState = .disconnected

    var participant: RemoteParticipant {
        didSet {
            self.updateParticipantProperties()
        }
    }

    // getter returning participant.cameraTrack and etc. will not trigger view update
    var cameraTrack: RemoteVideoTrack?
    var isMicOn: Bool = false
    var isCameraOn: Bool = false
    var networkQuality: NetworkQualityLevel = .unknown

    var messages: [DataTrackMessage] = []

    var identity: String {
        return participant.identity
    }

    init(participant: RemoteParticipant, onNewMessage: @escaping () -> Void) {
        self.participant = participant
        self.onNewMessage = onNewMessage
        super.init()
        participant.delegate = self
        self.connectionState = .connected
        self.updateParticipantProperties()
    }

    private func updateParticipantProperties() {
        self.cameraTrack = self.participant.cameraTrack
        self.isMicOn = self.participant.isMicOn
        self.isCameraOn = self.participant.isCameraOn
        self.networkQuality = self.participant.networkQualityLevel
    }

}

// MARK: - RemoteParticipantDelegate
// update participant property to force view update to trigger
extension RemoteParticipantManager: RemoteParticipantDelegate {
    func remoteParticipantSwitchedOnVideoTrack(
        participant: RemoteParticipant,
        track: RemoteVideoTrack
    ) {
        print("\(#file), \(#function)")
        self.participant = participant
    }
    func remoteParticipantSwitchedOffVideoTrack(
        participant: RemoteParticipant,
        track: RemoteVideoTrack
    ) {
        print("\(#file), \(#function)")
        self.participant = participant
    }
    func remoteParticipantDidEnableAudioTrack(
        participant: RemoteParticipant,
        publication: RemoteAudioTrackPublication
    ) {
        print("\(#file), \(#function)")
        self.participant = participant
    }
    func remoteParticipantDidEnableVideoTrack(
        participant: RemoteParticipant,
        publication: RemoteVideoTrackPublication
    ) {
        print("\(#file), \(#function)")
        self.participant = participant
    }
    func remoteParticipantDidPublishDataTrack(
        participant: RemoteParticipant,
        publication: RemoteDataTrackPublication
    ) {
        print("\(#file), \(#function)")
        self.participant = participant
    }
    func remoteParticipantDidDisableAudioTrack(
        participant: RemoteParticipant,
        publication: RemoteAudioTrackPublication
    ) {
        print("\(#file), \(#function)")
        self.participant = participant
    }
    func remoteParticipantDidDisableVideoTrack(
        participant: RemoteParticipant,
        publication: RemoteVideoTrackPublication
    ) {
        print("\(#file), \(#function)")
        self.participant = participant
    }
    func remoteParticipantDidPublishAudioTrack(
        participant: RemoteParticipant,
        publication: RemoteAudioTrackPublication
    ) {
        print("\(#file), \(#function)")
        self.participant = participant
    }
    func remoteParticipantDidPublishVideoTrack(
        participant: RemoteParticipant,
        publication: RemoteVideoTrackPublication
    ) {
        print("\(#file), \(#function)")
        self.participant = participant
    }
    func remoteParticipantDidUnpublishDataTrack(
        participant: RemoteParticipant,
        publication: RemoteDataTrackPublication
    ) {
        print("\(#file), \(#function)")
        self.participant = participant
    }

    func remoteParticipantDidUnpublishAudioTrack(
        participant: RemoteParticipant,
        publication: RemoteAudioTrackPublication
    ) {
        print("\(#file), \(#function)")
        self.participant = participant
    }
    func remoteParticipantDidUnpublishVideoTrack(
        participant: RemoteParticipant,
        publication: RemoteVideoTrackPublication
    ) {
        print("\(#file), \(#function)")
        self.participant = participant
    }
    func remoteParticipantNetworkQualityLevelDidChange(
        participant: RemoteParticipant,
        networkQualityLevel: NetworkQualityLevel
    ) {
        print("\(#file), \(#function)")
        self.participant = participant
    }

    // no manually subscription needed.
    // If we don't want to subscribe, we can set the `builder.isAutomaticSubscriptionEnabled` to false when connecting to a room
    // [Connect as a publish-only Participant](https://www.twilio.com/docs/video/ios-getting-started#connect-as-a-publish-only-participant)
    func didSubscribeToDataTrack(
        dataTrack: RemoteDataTrack,
        publication: RemoteDataTrackPublication,
        participant: RemoteParticipant
    ) {
        print("\(#file), \(#function)")
        self.participant = participant
        dataTrack.delegate = self
    }
    func didSubscribeToAudioTrack(
        audioTrack: RemoteAudioTrack,
        publication: RemoteAudioTrackPublication,
        participant: RemoteParticipant
    ) {
        print("\(#file), \(#function)")
        self.participant = participant
    }
    func didSubscribeToVideoTrack(
        videoTrack: RemoteVideoTrack,
        publication: RemoteVideoTrackPublication,
        participant: RemoteParticipant
    ) {
        print(#file, #function)
        self.participant = participant
    }

    func didFailToSubscribeToDataTrack(
        publication: RemoteDataTrackPublication,
        error: any Error,
        participant: RemoteParticipant
    ) {
        print("\(#file), \(#function)")
        self.participant = participant
        print(error.localizedDescription)
        self.connectionState = .error(error.localizedDescription)

    }

    func didFailToSubscribeToAudioTrack(
        publication: RemoteAudioTrackPublication,
        error: any Error,
        participant: RemoteParticipant
    ) {
        print("\(#file), \(#function)")
        self.participant = participant
        print(error.localizedDescription)
        self.connectionState = .error(error.localizedDescription)

    }

    func didFailToSubscribeToVideoTrack(
        publication: RemoteVideoTrackPublication,
        error: any Error,
        participant: RemoteParticipant
    ) {
        print("\(#file), \(#function)")
        self.participant = participant
        print(error.localizedDescription)
        self.connectionState = .error(error.localizedDescription)
    }

    func didUnsubscribeFromDataTrack(
        dataTrack: RemoteDataTrack,
        publication: RemoteDataTrackPublication,
        participant: RemoteParticipant
    ) {
        print("\(#file), \(#function)")
        self.participant = participant

    }
    func didUnsubscribeFromAudioTrack(
        audioTrack: RemoteAudioTrack,
        publication: RemoteAudioTrackPublication,
        participant: RemoteParticipant
    ) {
        print("\(#file), \(#function)")
        self.participant = participant
    }

    func didUnsubscribeFromVideoTrack(
        videoTrack: RemoteVideoTrack,
        publication: RemoteVideoTrackPublication,
        participant: RemoteParticipant
    ) {
        print("\(#file), \(#function)")
        self.participant = participant

    }
}

// MARK: - RemoteDataTrackDelegate
extension RemoteParticipantManager: RemoteDataTrackDelegate {
    func remoteDataTrackDidReceiveData(
        remoteDataTrack: RemoteDataTrack,
        message: Data
    ) {
        print("\(#file), \(#function)")
        self.messages.append(
            .init(participant: self.participant, data: message)
        )
        self.onNewMessage()
    }

    func remoteDataTrackDidReceiveString(
        remoteDataTrack: RemoteDataTrack,
        message: String
    ) {
        print("\(#file), \(#function)")
        self.messages.append(
            .init(participant: self.participant, message: message)
        )
        self.onNewMessage()
    }
}
