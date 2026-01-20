//
//  NetworkQualityView.swift
//  TwilioVideoChat
//
//  Created by Itsuki on 2026/01/19.
//

import SwiftUI
import TwilioVideo

// Not used in this demo but can be used for displaying a little icon showing the network quality
struct NetworkQualityView: View {
    var level: NetworkQualityLevel

    var body: some View {
        let image: (String, Double?) =
            switch level {
            case .unknown:
                ("wifi.exclamationmark", nil)

            case .zero:
                ("wifi.slash", nil)

            case .one, .two, .three, .four, .five:
                ("wifi", Double(level.rawValue) / 5.0)

            default:
                ("wifi.exclamationmark", nil)
            }

        Image(systemName: image.0, variableValue: image.1)
    }
}
