//
//  UserEvent.swift
//  CloudflareContentCollaboration
//
//  Created by Itsuki on 2026/01/26.
//

import Foundation

nonisolated
    struct UserEvent: Codable
{
    // type: join or leave
    var type: EventType
    var userId: String
}
