//
//  ContentView.swift
//  TwilioVideoChat
//
//  Created by Itsuki on 2026/01/19.
//

import SwiftUI

struct ContentView: View {
    @State private var roomManager = VideoRoomManager()

    var body: some View {

        NavigationStack {
            Group {
                if roomManager.room != nil {
                    RoomView()
                        .environment(roomManager)
                } else {
                    JoinRoomView()
                        .environment(roomManager)
                }
            }

        }
    }
}
