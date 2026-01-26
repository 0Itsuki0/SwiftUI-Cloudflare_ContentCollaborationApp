//
//  TextSelection.swift
//  CloudflareContentCollaboration
//
//  Created by Itsuki on 2026/01/26.
//

import SwiftUI

extension TextSelection {
    func utf8Range(in string: String) -> Range<Int>? {
        let range: Range<Int>

        switch self.indices {

        case .selection(let stringRange):
            let lower = stringRange.lowerBound.utf8Offset(in: string)
            let upper = stringRange.upperBound.utf8Offset(in: string)
            range = lower..<upper
        case .multiSelection(let rangeSet):
            guard let first = rangeSet.ranges.first else {
                return nil
            }
            let lower = first.lowerBound.utf8Offset(in: string)
            let upper = first.upperBound.utf8Offset(in: string)
            range = lower..<upper
        @unknown default:
            return nil
        }

        return range
    }
}
