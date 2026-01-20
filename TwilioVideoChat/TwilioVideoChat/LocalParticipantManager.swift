
@Observable
class LocalParticipantManager: NSObject {
    var participant: LocalParticipant? {
        didSet {
            self.participant?.delegate = self
        }
    }

    private(set) var videoTrack: LocalVideoTrack?
    private(set) var audioTrack: LocalAudioTrack?
}


extension LocalParticipantManager: LocalParticipantDelegate {
    func localParticipantDidPublishDataTrack(participant: LocalParticipant, dataTrackPublication: LocalDataTrackPublication) {
        print(#function)
    }
    func localParticipantDidPublishAudioTrack(participant: LocalParticipant, audioTrackPublication: LocalAudioTrackPublication) {
        print(#function)
    }
    func localParticipantDidPublishVideoTrack(participant: LocalParticipant, videoTrackPublication: LocalVideoTrackPublication) {
        print(#function)
    }
    func localParticipantNetworkQualityLevelDidChange(participant: LocalParticipant, networkQualityLevel: NetworkQualityLevel) {
        print(#function)
    }
    func localParticipantDidFailToPublishDataTrack(participant: LocalParticipant, dataTrack: LocalDataTrack, error: any Error) {
        print(#function)
    }
    func localParticipantDidFailToPublishAudioTrack(participant: LocalParticipant, audioTrack: LocalAudioTrack, error: any Error) {
        print(#function)
    }
    func localParticipantDidFailToPublishVideoTrack(participant: LocalParticipant, videoTrack: LocalVideoTrack, error: any Error) {
        print(#function)
    }
}

