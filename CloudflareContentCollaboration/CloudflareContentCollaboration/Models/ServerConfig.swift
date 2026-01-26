//
//  ServerConfig.swift
//  CloudflareContentCollaboration
//
//  Created by Itsuki on 2026/01/26.
//

import Foundation

nonisolated
    enum ServerConfig
{
    static let url = "http://127.0.0.1:8787/websocket"
    static let method = "GET"
    static let headers: [String: String] = [:]
}
