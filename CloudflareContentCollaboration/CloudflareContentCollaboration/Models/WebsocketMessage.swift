//
//  WebsocketMessage.swift
//  CloudflareContentCollaboration
//
//  Created by Itsuki on 2026/01/26.
//

import Foundation

nonisolated
    enum WebsocketMessage: Decodable
{
    case userEvent(UserEvent)
    case connectionInit(ConnectionInitEvent)
    case docUpdate(DocumentUpdateEvent)

    enum CodingKeys: String, CodingKey {
        case type
    }

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(String.self, forKey: .type)
        guard let eventType = EventType(rawValue: type) else {
            throw DecodingError.dataCorrupted(
                .init(
                    codingPath: [CodingKeys.type],
                    debugDescription: "Invalid type"
                )
            )
        }

        switch eventType {
        case .join, .leave:
            self = .userEvent(try UserEvent(from: decoder))
        case .`init`:
            self = .connectionInit(try ConnectionInitEvent(from: decoder))
        case .update:
            self = .docUpdate(try DocumentUpdateEvent(from: decoder))
        }
    }
}
