//
//  MediaError.swift
//  TwilioVideoChat
//
//  Created by Itsuki on 2026/01/20.
//

import Foundation

enum MediaError: Error, LocalizedError {
    case failToGetDevice
    case failToCreateTrack

    var errorDescription: String? {
        switch self {
        case .failToGetDevice:
            "Failed to get camera capture device."
        case .failToCreateTrack:
            "Fail to create media track."
        }
    }
}
