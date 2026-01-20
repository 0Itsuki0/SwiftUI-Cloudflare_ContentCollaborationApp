//
//  DataTrackMessage.swift
//  TwilioVideoChat
//
//  Created by Itsuki on 2026/01/20.
//

import Foundation
import TwilioVideo

nonisolated
struct DataTrackMessage: Identifiable, Equatable {
    let id = UUID()
    let createdAt = Date()
    let participant: Participant
    let message: String
    
    init(participant: Participant, message: String) {
        self.participant = participant
        self.message = message
    }
    
    init(participant: Participant, data: Data) {
        self.participant = participant
        self.message = String(data: data, encoding: .utf8) ?? "(Unknown data)"
    }
}
