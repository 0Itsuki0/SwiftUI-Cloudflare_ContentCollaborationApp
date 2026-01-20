//
//  GetAccessTokenResponse.swift
//  TwilioVideoChat
//
//  Created by Itsuki on 2026/01/20.
//

import Foundation

struct GetAccessTokenResponse: Decodable {
    let token: String
    let roomName: String
}
