//
//  EventType.swift
//  CloudflareContentCollaboration
//
//  Created by Itsuki on 2026/01/26.
//

import Foundation

nonisolated
    enum EventType: String, Codable
{
    // user event
    case join
    case leave

    // init event
    case `init`

    // update
    case update
}
