# SwiftUI: Twilio Video Chat

A two-way, multi-person video call app + text-based chats with Twilio Video.

Blog: [SwiftUI: Video Calls With Twilio]()

This repository contain two part:

- **Backend**: A simple express server expose a single endpoint for obtaining
  access token.
- **SwiftUI/iOS App**: the user create / join a room and share their media.

![](./Demo.gif)

## Run the App

1. Get API keys and Account SID from Twilio
2. Set up keys in `Server/.env`
   ```bash
   TWILIO_ACCOUNT_SID=ACxxxxxxxxxx
   TWILIO_API_KEY=SKxxxxxxxxxx
   TWILIO_API_SECRET=xxxxxxxxxx
   ```

3. Start the backend server
   ```bash
   cd Server
   npm install
   npm run dev
   ```

4. Update the App side `ServerConfig.url` to use the IP address of the wifi
   - make sure not to use localhost when running on real device

5. Run the app in multiple devices
   - When running on simulator, camera will not work.
