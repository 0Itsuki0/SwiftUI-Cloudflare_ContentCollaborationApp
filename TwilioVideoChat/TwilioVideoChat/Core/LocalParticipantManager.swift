//
//  LocalParticipantManager.swift
//  TwilioVideoChat
//
//  Created by Itsuki on 2026/01/19.
//

import SwiftUI
import TwilioVideo

// nonisolated required deinit CameraSource
@Observable
nonisolated
    class LocalParticipantManager: NSObject
{
    var error: String? = nil

    // returning videoTrack?.isEnabled will not trigger view update
    private(set) var isCameraOn: Bool = false
    private(set) var isMicOn: Bool = false
    private(set) var networkQuality: NetworkQualityLevel = .unknown

    var participant: LocalParticipant? {
        didSet {
            self.participant?.delegate = self
            self.updateParticipantProperties()
            self.messages = []
            if let dataTrack {
                let _ = participant?.publishDataTrack(dataTrack)
            }
        }
    }

    private(set) var messages: [DataTrackMessage] = []

    private(set) var cameraPosition: AVCaptureDevice.Position = .front

    var cameraPreview: CameraPreviewView? {
        return cameraSource?.previewView
    }

    // video track for camera capture
    private(set) var videoTrack: LocalVideoTrack?

    private(set) var cameraSource: CameraSource?

    // audio track for capturing audio from mic
    private(set) var audioTrack: LocalAudioTrack?

    // data track for sending string messages or data
    private(set) var dataTrack: LocalDataTrack?

    override init() {
        super.init()

        // init video track
        let cameraSourceOption = CameraSourceOptions(block: { builder in
            // Only a few apple devices supports this features. Twilio Video SDK will enable this feature by default when possible
            builder.enableCameraMultitasking = true
            // Enable the use of `TVICameraPreviewView` to preview video from the camera. Defaults to `NO`.
            builder.enablePreview = true
            builder.zoomFactor = 1.0
            // How `TVICameraSource` should handle rotation tags. Defaults to `TVICameraSourceOptionsRotationTagsKeep`.
            builder.rotationTags = .keep
        })

        if let cameraSource = CameraSource(
            options: cameraSourceOption,
            delegate: self
        ) {
            // It is possible to enable and disable local tracks. The results of this operation are signaled to other
            // Participants in the same Room. When a video track is disabled, black frames are sent in place of normal video.
            videoTrack = LocalVideoTrack(
                source: cameraSource,
                enabled: false,
                name: TrackName.camera
            )
            self.cameraSource = cameraSource
        }

        // init audio track
        let audioOptions = AudioOptions(block: { builder in
            builder.highpassFilter = true
        })
        self.audioTrack = LocalAudioTrack(
            options: audioOptions,
            enabled: false,
            name: TrackName.mic
        )

        // init data track
        let dataTrackOptions = DataTrackOptions(block: { builder in
            builder.isOrdered = true
        })
        self.dataTrack = LocalDataTrack(options: dataTrackOptions)
    }

    deinit {
        cameraSource?.stopCapture()
    }

    func switchCameraPosition(_ new: AVCaptureDevice.Position) async {
        do {
            guard let captureDevice = CameraSource.captureDevice(position: new)
            else {
                throw MediaError.failToGetDevice
            }

            try await self.cameraSource?.selectCaptureDevice(captureDevice)
            self.cameraPosition = new
        } catch (let error) {
            self.error = error.localizedDescription
        }
    }

    func startCamera() async {
        do {
            guard
                let captureDevice = CameraSource.captureDevice(
                    position: self.cameraPosition
                )
            else {
                throw MediaError.failToGetDevice
            }
            try await self.cameraSource?.startCapture(device: captureDevice)
            try self.enableVideo()

        } catch (let error) {
            self.error = error.localizedDescription
        }
    }

    func stopCamera() async {
        do {
            self.disableVideo()
            try await self.cameraSource?.stopCapture()
        } catch (let error) {
            self.error = error.localizedDescription
        }

    }

    private func enableVideo() throws {
        guard let videoTrack else {
            throw MediaError.failToCreateTrack
        }
        videoTrack.isEnabled = true
        let _ = participant?.publishVideoTrack(videoTrack)
        self.isCameraOn = true
    }

    private func disableVideo() {
        if let videoTrack {
            let _ = participant?.unpublishVideoTrack(videoTrack)
        }
        self.videoTrack?.isEnabled = false
        self.isCameraOn = false
    }

    func startMic() {
        do {
            guard let audioTrack else {
                throw MediaError.failToCreateTrack
            }
            self.audioTrack?.isEnabled = true
            let _ = participant?.publishAudioTrack(audioTrack)
            self.isMicOn = true
        } catch (let error) {
            self.error = error.localizedDescription
        }
    }

    func stopMic() {
        if let audioTrack {
            // Un publishes the audio track from the Room
            // `YES` if the track was unpublished successfully, `NO` otherwise.
            let _ = participant?.unpublishAudioTrack(audioTrack)
        }
        self.audioTrack?.isEnabled = false
        self.isMicOn = false
    }

    func sendMessage(_ message: String) {
        do {
            guard let dataTrack else {
                throw MediaError.failToCreateTrack
            }
            let _ = participant?.publishDataTrack(dataTrack)
            dataTrack.send(message)
            if let participant {
                self.messages.append(
                    .init(participant: participant, message: message)
                )
            }
        } catch (let error) {
            self.error = error.localizedDescription
        }
    }

    private func updateParticipantProperties() {
        guard let participant else {
            self.networkQuality = .unknown
            return
        }
        self.networkQuality = participant.networkQualityLevel
    }

}

nonisolated
    extension LocalParticipantManager: CameraSourceDelegate
{
    func cameraSourceWasInterrupted(
        source: CameraSource,
        reason: AVCaptureSession.InterruptionReason
    ) {
        print("\(#file), \(#function)")
        self.disableVideo()
    }
    func cameraSourceInterruptionEnded(source: CameraSource) {
        print("\(#file), \(#function)")
        try? self.enableVideo()
    }

    func cameraSourceDidFail(source: CameraSource, error: any Error) {
        print("\(#file), \(#function)")
        print(error.localizedDescription)
        self.error = error.localizedDescription
    }

}

// update participant property to force view update to trigger
nonisolated
    extension LocalParticipantManager: LocalParticipantDelegate
{
    func localParticipantDidPublishDataTrack(
        participant: LocalParticipant,
        dataTrackPublication: LocalDataTrackPublication
    ) {
        print("\(#file), \(#function)")
        self.participant = participant
    }
    func localParticipantDidPublishAudioTrack(
        participant: LocalParticipant,
        audioTrackPublication: LocalAudioTrackPublication
    ) {
        print("\(#file), \(#function)")
        self.participant = participant
    }
    func localParticipantDidPublishVideoTrack(
        participant: LocalParticipant,
        videoTrackPublication: LocalVideoTrackPublication
    ) {
        print("\(#file), \(#function)")
        self.participant = participant
    }
    func localParticipantNetworkQualityLevelDidChange(
        participant: LocalParticipant,
        networkQualityLevel: NetworkQualityLevel
    ) {
        print("\(#file), \(#function)")
        self.participant = participant
    }
    func localParticipantDidFailToPublishDataTrack(
        participant: LocalParticipant,
        dataTrack: LocalDataTrack,
        error: any Error
    ) {
        print("\(#file), \(#function)")
        print(error.localizedDescription)
        self.participant = participant
        self.error = error.localizedDescription
    }
    func localParticipantDidFailToPublishAudioTrack(
        participant: LocalParticipant,
        audioTrack: LocalAudioTrack,
        error: any Error
    ) {
        print("\(#file), \(#function)")
        print(error.localizedDescription)
        self.participant = participant
        self.error = error.localizedDescription
    }
    func localParticipantDidFailToPublishVideoTrack(
        participant: LocalParticipant,
        videoTrack: LocalVideoTrack,
        error: any Error
    ) {
        print("\(#file), \(#function)")
        print(error.localizedDescription)
        self.participant = participant
        self.error = error.localizedDescription
    }

}
