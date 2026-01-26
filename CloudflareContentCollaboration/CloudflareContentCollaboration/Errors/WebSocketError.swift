//
//  WebSocketError.swift
//  CloudflareContentCollaboration
//
//  Created by Itsuki on 2026/01/26.
//

import Foundation

nonisolated
    enum WebSocketError: Error, LocalizedError
{
    case webSocketTaskUndefined
    case connectionClosed(
        code: URLSessionWebSocketTask.CloseCode,
        reason: String
    )
    case connectionCompleted(Error)

    var errorDescription: String? {
        switch self {
        case .webSocketTaskUndefined:
            "No WebSocket service connected."
        case .connectionClosed(let code, let reason):
            "WebSocket connection closed with Error. Code: \(code). Reason: \(reason)"
        case .connectionCompleted(let error):
            "WebSocket connection completed with error: \(error.localizedDescription)."
        }
    }

    var recoverySuggestion: String? {
        nil
    }
}
