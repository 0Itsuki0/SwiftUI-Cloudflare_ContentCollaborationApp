//
//  DocumentUpdateEvent.swift
//  CloudflareContentCollaboration
//
//  Created by Itsuki on 2026/01/26.
//

import Foundation

nonisolated
    struct DocumentUpdateEvent: Codable
{
    // type: update
    var type: EventType
    var data: [UInt8]
    var userId: String
}
