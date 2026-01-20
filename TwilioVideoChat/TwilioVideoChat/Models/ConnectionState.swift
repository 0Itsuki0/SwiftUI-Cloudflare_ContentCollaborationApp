//
//  ConnectionState.swift
//  TwilioVideoChat
//
//  Created by Itsuki on 2026/01/20.
//


import Foundation

enum ConnectionState: Equatable {
    case disconnected
    case connecting
    case connected
    case disconnecting
    case error(String)
    
    var error: String? {
        guard case .error(let string) = self else {
            return nil
        }
        return string
    }
}
