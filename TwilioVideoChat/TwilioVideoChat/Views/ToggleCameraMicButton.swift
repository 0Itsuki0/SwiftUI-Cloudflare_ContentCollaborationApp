//
//  ToggleCameraMicButton.swift
//  TwilioVideoChat
//
//  Created by Itsuki on 2026/01/20.
//

import SwiftUI

struct ToggleCameraMicButton: View {
    var setOnOff: (() -> Void)?
    var isOn: Bool
    var isCamera: Bool

    var body: some View {
        Button(
            action: {
                setOnOff?()
            },
            label: {
                Image(
                    systemName: isCamera ? "camera.circle" : "microphone.circle"
                )
                .opacity(isOn ? 1.0 : 0.6)
                .overlay(content: {
                    if !isOn {
                        Image(systemName: "slash.circle")
                    }
                })
                .font(.system(size: 36))
                .fontWeight(.semibold)
                .foregroundStyle(.white)
            }
        )
        .buttonStyle(.borderless)
        .disabled(setOnOff == nil)
    }
}
