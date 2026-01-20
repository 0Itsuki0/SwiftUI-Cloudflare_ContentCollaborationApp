//
//  JoinRoomView.swift
//  TwilioVideoChat
//
//  Created by Itsuki on 2026/01/20.
//

import SwiftUI

struct JoinRoomView: View {
    @State private var roomManager = VideoRoomManager()

    @State private var roomName = "itsuki's room"

    var body: some View {
        NavigationStack {
            Group {

                if roomManager.room != nil {
                    RoomView()
                        .environment(roomManager)
                } else {
                    VStack(alignment: .leading, spacing: 36, content: {
                        HStack(spacing: 16) {
                            Text("Room")
                                .font(.headline)
                            TextField("", text: $roomName)
                                .textFieldStyle(.roundedBorder)
                        }

                        Text("You will be joining as \n\(roomManager.identity)")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        
                        Button(action: {
                            
                        }, label: {
                            Text("JOIN")
                                .padding(.vertical, 8)
                                .font(.headline)
                        })
                        .buttonStyle(.borderedProminent)
                        .buttonSizing(.flexible)
                    })
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(.yellow.opacity(0.1))
                    .navigationTitle("Join A Room")
                }

            }

        }
    }
}


#Preview {
    JoinRoomView()
}
