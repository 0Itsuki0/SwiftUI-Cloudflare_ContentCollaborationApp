//
//  ConnectionInitEvent.swift
//  CloudflareContentCollaboration
//
//  Created by Itsuki on 2026/01/26.
//

import Foundation

nonisolated
    struct ConnectionInitEvent: Codable
{
    // type: init
    var type: EventType
    var content: [UInt8]
    var collaborators: [String]
}
