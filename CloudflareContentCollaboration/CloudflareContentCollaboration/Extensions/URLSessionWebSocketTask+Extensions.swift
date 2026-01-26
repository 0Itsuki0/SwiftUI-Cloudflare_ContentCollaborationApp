//
//  File.swift
//  CloudflareContentCollaboration
//
//  Created by Itsuki on 2026/01/26.
//

import Foundation

nonisolated
extension URLSessionWebSocketTask.Message {
    var data: Data? {
        switch self {
        case .data(let data):
            return data
        case .string(let string):
            return Data(string.utf8)
        @unknown default:
            return nil
        }
    }
}
