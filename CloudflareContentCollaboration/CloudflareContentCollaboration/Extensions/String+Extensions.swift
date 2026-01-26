//
//  String.swift
//  CloudflareContentCollaboration
//
//  Created by Itsuki on 2026/01/26.
//

import Foundation

extension String.Index {
    func utf8Offset(in string: String) -> Int {
        let endIndex = self > string.endIndex ? string.endIndex : self
        return string.utf8.distance(from: string.utf8.startIndex, to: endIndex)
    }

    init(utf8Offset: Int, in string: String) {
        let endUtf8 = string.endIndex.utf8Offset(in: string)
        let end = endUtf8 > utf8Offset ? utf8Offset : endUtf8
        let utf8View = string.utf8
        self = utf8View.index(utf8View.startIndex, offsetBy: end)
    }
}
