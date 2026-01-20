//
//  HTTPURLResponse.swift
//  TwilioVideoChat
//
//  Created by Itsuki on 2026/01/19.
//

import Foundation

extension HTTPURLResponse {
    var isSuccess: Bool {
        return (200...299).contains(self.statusCode)
    }
}
