# SwiftUI/Cloudflare: Content Collaboration App

A real-time, multi-user, content collaboration app with Cloudflare durable
object (websocket hibernation API), Y-Swift, and SwiftUI.

Blog:
[SwiftUI: Realtime, Multi-User Content Collaboration With CloudFlare +YJS-Swift](https://medium.com/@itsuki.enjoy/swiftui-realtime-multi-user-content-collaboration-with-cloudflare-yjs-swift-94a155fab5a7)

This repository contain two part:

- **Backend**: A websocket server with cloudflare durable object (hibernation
  API)

- **SwiftUI/iOS App**: the user create / open a document and collaborate with
  other collaborators in real time

![](./demo.gif)

## Run the App

1. Start the backend server
   ```bash
   cd content-collaboration-server
   npm install
   npm run dev
   ```

2. Run the app on multiple devices, enter the same document name and start
   collaborating.

## Deploy the server

The websocket endpoint can be deployed to cloudflare with the following
commands.

```bash
npx wrangler login
npm run deploy
```
