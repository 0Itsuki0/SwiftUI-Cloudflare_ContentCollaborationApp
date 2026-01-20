//
//  ServerConfig.swift
//  TwilioVideoChat
//
//  Created by Itsuki on 2026/01/20.
//

enum ServerConfig {
    // IP address of the wifi
    // make sure not to use localhost when running on real device
    static let url = "http://19x.xxx.x.x:8080/token"
    static let method = "POST"
    static let headers: [String: String] = [
        "Content-Type": "application/json"
    ]
}
