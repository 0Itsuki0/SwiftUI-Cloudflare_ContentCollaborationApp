//
//  VideoViewRepresentable.swift
//  TwilioVideoChat
//
//  Created by Itsuki on 2026/01/20.
//

import SwiftUI
import TwilioVideo

struct VideoViewRepresentable: UIViewRepresentable {
    let videoView = VideoView()
    let videoTrack: VideoTrack
    let shouldMirror: Bool

    func makeUIView(context: Context) -> VideoView {
        videoView.contentMode = .scaleAspectFit
        videoTrack.addRenderer(videoView)
        videoView.shouldMirror = shouldMirror
        return videoView
    }

    func updateUIView(_ uiView: VideoView, context: Context) {}
}
