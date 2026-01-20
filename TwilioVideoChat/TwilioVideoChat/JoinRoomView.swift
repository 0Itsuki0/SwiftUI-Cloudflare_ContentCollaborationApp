
struct JoinRoomView: View {
    @State private var roomManager = VideoRoomManager()

    @State private var roomName = "itsuki's room"
    @State private var identityPrefix = "itsuki\(Int.random(in:0..<10))"
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                
                if roomManager.room != nil {
                    RoomView()
                } else {
                    
                    
                }
                
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(.yellow.opacity(0.1))
            
        }
    }
}

