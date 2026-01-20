//
//  GetAccessTokenRequest.swift
//  TwilioVideoChat
//
//  Created by Itsuki on 2026/01/20.
//

import Foundation

struct GetAccessTokenRequest: Codable {
    let identity: String
    let roomName: String
}
