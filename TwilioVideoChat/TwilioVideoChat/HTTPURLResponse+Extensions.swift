//
//  HTTPURLResponse.swift
//  Swifly
//
//  Created by Itsuki on 2025/12/23.
//

import Foundation

extension HTTPURLResponse {
    var isSuccess: Bool {
        return (200...299).contains(self.statusCode)
    }
}
