
class RemoteParticipantManager: NSObject, Identifiable {
    var connectionState: ConnectionState = .disconnected
    
    var participant: RemoteParticipant
    
    var identity: String {
        return participant.identity
    }
    
    init(participant: RemoteParticipant) {
        self.participant = participant
        super.init()
        participant.delegate = self
    }
    
    func isDominantSpeaking(in room: Room) -> Bool {
        return room.dominantSpeaker?.identity == self.participant.identity
    }
}


extension RemoteParticipantManager: RemoteParticipantDelegate {
    func remoteParticipantSwitchedOnVideoTrack(participant: RemoteParticipant, track: RemoteVideoTrack) {
        print(#function)
        self.participant = participant
    }
    func remoteParticipantSwitchedOffVideoTrack(participant: RemoteParticipant, track: RemoteVideoTrack) {
        print(#function)
        self.participant = participant
    }
    func remoteParticipantDidEnableAudioTrack(participant: RemoteParticipant, publication: RemoteAudioTrackPublication) {
        print(#function)
        self.participant = participant
    }
    func remoteParticipantDidEnableVideoTrack(participant: RemoteParticipant, publication: RemoteVideoTrackPublication) {
        print(#function)
        self.participant = participant
    }
    func remoteParticipantDidPublishDataTrack(participant: RemoteParticipant, publication: RemoteDataTrackPublication) {
        print(#function)
        self.participant = participant
    }
    func remoteParticipantDidDisableAudioTrack(participant: RemoteParticipant, publication: RemoteAudioTrackPublication) {
        print(#function)
        self.participant = participant
    }
    func remoteParticipantDidDisableVideoTrack(participant: RemoteParticipant, publication: RemoteVideoTrackPublication) {
        print(#function)
        self.participant = participant
    }
    func remoteParticipantDidPublishAudioTrack(participant: RemoteParticipant, publication: RemoteAudioTrackPublication) {
        print(#function)
        self.participant = participant
    }
    func remoteParticipantDidPublishVideoTrack(participant: RemoteParticipant, publication: RemoteVideoTrackPublication) {
        print(#function)
        self.participant = participant
    }
    func remoteParticipantDidUnpublishDataTrack(participant: RemoteParticipant, publication: RemoteDataTrackPublication) {
        print(#function)
        self.participant = participant
    }
    func remoteParticipantDidUnpublishAudioTrack(participant: RemoteParticipant, publication: RemoteAudioTrackPublication) {
        print(#function)
        self.participant = participant
    }
    func remoteParticipantDidUnpublishVideoTrack(participant: RemoteParticipant, publication: RemoteVideoTrackPublication) {
        print(#function)
        self.participant = participant
    }
    func remoteParticipantNetworkQualityLevelDidChange(participant: RemoteParticipant, networkQualityLevel: NetworkQualityLevel) {
        print(#function)
        self.participant = participant
    }
    
    
    // no manually subscription needed.
    // If we don't want to subscribe, we can set the `builder.isAutomaticSubscriptionEnabled` to false when connecting to a room
    // [Connect as a publish-only Participant](https://www.twilio.com/docs/video/ios-getting-started#connect-as-a-publish-only-participant)
    func didSubscribeToDataTrack(dataTrack: RemoteDataTrack, publication: RemoteDataTrackPublication, participant: RemoteParticipant) {
        print(#function)
        self.participant = participant
    }
    func didSubscribeToAudioTrack(audioTrack: RemoteAudioTrack, publication: RemoteAudioTrackPublication, participant: RemoteParticipant) {
        print(#function)
        self.participant = participant
    }
    func didSubscribeToVideoTrack(videoTrack: RemoteVideoTrack, publication: RemoteVideoTrackPublication, participant: RemoteParticipant) {
        print(#file, #function)
        self.participant = participant
    }
}