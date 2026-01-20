//
//  CameraPreviewViewRepresentable.swift
//  TwilioVideoChat
//
//  Created by Itsuki on 2026/01/20.
//

import SwiftUI
import TwilioVideo

struct CameraPreviewViewRepresentable: UIViewRepresentable {
    var previewView: CameraPreviewView

    func makeUIView(context: Context) -> CameraPreviewView {
        return previewView
    }

    func updateUIView(_ uiView: CameraPreviewView, context: Context) {
    }
}
