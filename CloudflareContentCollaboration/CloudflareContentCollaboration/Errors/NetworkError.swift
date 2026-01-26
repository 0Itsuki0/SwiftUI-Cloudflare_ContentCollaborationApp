//
//  NetworkError.swift
//  CloudflareContentCollaboration
//
//  Created by Itsuki on 2026/01/26.
//

import Foundation

nonisolated
    enum NetworkError: Error, LocalizedError
{
    case failToCreateURL

    var errorDescription: String? {
        switch self {
        case .failToCreateURL:
            "Fail to create URL."
        }
    }

    var recoverySuggestion: String? {
        switch self {
        default:
            nil
        }
    }
}
