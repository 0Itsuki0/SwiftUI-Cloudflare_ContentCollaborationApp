//
//  RemoteParticipant+Extensions.swift
//  TwilioVideoChat
//
//  Created by Itsuki on 2026/01/20.
//

import SwiftUI
import TwilioVideo

extension RemoteParticipant {
    var isMicOn: Bool {
        guard
            let track = self.remoteAudioTracks.first(where: {
                $0.trackName.localizedCaseInsensitiveContains(TrackName.mic)
            })
        else { return false }
        return track.isTrackSubscribed && track.isTrackEnabled
    }

    var isCameraOn: Bool {
        guard let track = self.videoTrackPublication(for: TrackName.camera)
        else { return false }
        return track.remoteTrack?.isSwitchedOff == false && track.isTrackEnabled
            && track.isTrackSubscribed
    }

    var cameraTrack: RemoteVideoTrack? {
        // RemoteTracks: The audio, data, and video tracks from other participants connected to the Room.
        return self.videoTrackPublication(for: TrackName.camera)?.remoteTrack
    }

    private func videoTrackPublication(for name: String)
        -> RemoteVideoTrackPublication?
    {
        return self.remoteVideoTracks.first(where: {
            $0.trackName.localizedCaseInsensitiveContains(name)
        })
    }
}
