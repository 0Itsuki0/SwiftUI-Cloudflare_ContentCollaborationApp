//
//  NetworkError.swift
//  TwilioVideoChat
//
//  Created by Itsuki on 2026/01/19.
//

import Foundation

enum NetworkError: Error, LocalizedError {
    case failToCreateURL
    case badResponse(code: Int)
    case dataTaskError(Error)

    var errorDescription: String? {
        switch self {
        case .failToCreateURL:
            "Fail to create URL."
        case .badResponse(let code):
            "Network failed. Code:\(code)."
        case .dataTaskError(let error):
            "Error making network request: \(error.localizedDescription)"
        }
    }

    var recoverySuggestion: String? {
        switch self {
        case .badResponse(code: _):
            "Please check your network."
        default:
            nil
        }
    }
}
