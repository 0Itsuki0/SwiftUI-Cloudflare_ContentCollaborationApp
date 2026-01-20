//
//  NetworkQualityView.swift
//  TwilioVideoChat
//
//  Created by Itsuki on 2026/01/19.
//



struct NetworkQualityView: View {
    var level: NetworkQualityLevel
    
    var body: some View {
        Group {
            switch level {
            case .unknown:
                Image(systemName: "wifi.exclamationmark")

            case .zero:
                Image(s)
                
            default:
                Image(systemName: "wifi.exclamationmark")

            }
            Image(systemName: "wifi")
        }
    }
}
