# Chat Application Frontend Technical Specification

## 1. System Architecture & Tech Stack

### Framework & Libraries
* **Core Framework:** React / Next.js or React Native (Mobile)
* **Styling & UI Systems:** Tailwind CSS (Custom Theme Configuration) + Lucide Icons
* **State Management:** Zustand or Redux Toolkit (Optimized for real-time state synchronization)
* **Real-Time Layer:** Native WebSockets / Socket.io-client
* **Local Offline Storage:** IndexedDB (via Dexie.js for Web) or SQLite / Realm (for Mobile)
* **E2EE Encryption:** Signal Protocol JavaScript Library (`libsignal-protocol-javascript`) or Web Crypto API

---

## 2. Design System & Theme Engine

The frontend uses a customized dark/purple palette defined as Tailwind CSS extensions.

```javascript
// tailwind.config.js snippet
module.exports = {
  theme: {
    extend: {
      colors: {
        canvas: '#000000',       // Main page background
        surface: '#120826',      // Card & panel containers
        overlay: '#1E1B4B',      // Input fields & subtle overlays
        accent: {
          mid: '#5B21B6',        // Secondary borders & muted highlights
          primary: '#7C3AED',    // Primary interactive buttons / CTAs
          light: '#C4B5FD',      // Icons, links, secondary text
          soft: '#EDE9FE',       // Primary readable typography
        }
      }
    }
  }
}
```

---

## 3. Core Component Hierarchy

```
AppRoot
├── AuthProvider (Session & Token Management)
├── SocketProvider (WebSocket Connection & Event Hub)
└── Layout
    ├── NavigationSidebar (Settings, Profile, Unread Badges)
    ├── ChatListSidebar
    │   ├── SearchAndFilterBar
    │   ├── ActiveConversationsList
    │   │   └── ConversationItem (Avatar, Name, Preview, Last Seen, Unread Badge)
    │   └── ArchivedSection
    ├── MainChatWindow (Conditional: Active Chat Selected)
    │   ├── ChatHeader (Participant Details, Status, Call Actions, Search)
    │   ├── MessageFeed (Virtualized Scroll List)
    │   │   ├── DateDivider
    │   │   ├── SystemNoticeBubble
    │   │   └── MessageBubble (Text, Media, Voice Note, Reaction Overlay)
    │   ├── ReplyPreviewBar (Shown when replying to a message)
    │   └── MessageInputArea
    │       ├── AttachmentPicker (Images, Docs, Audio)
    │       ├── EmojiStickerPicker
    │       ├── AutoExpandingTextArea
    │       └── VoiceNoteRecorder / SendButton
    └── UserDetailsDrawer (Slide-out panel: Shared Media, Group Members, Encryption Info)
```

---

## 4. Real-Time Engine & State Architecture

### A. WebSocket Connection & Lifecycle Management
1. **Handshake & Auth:** Connect to `wss://api.app.com/v1/ws` passing the JWT access token in authorization headers or sub-protocols.
2. **Heartbeat / Ping-Pong:** Send `PING` every 30 seconds to maintain persistent connection and detect connection drops immediately.
3. **Automatic Reconnection:** Exponential backoff strategy (1s, 2s, 4s, 8s, up to 30s) when network state switches to offline or server drops connection.

### B. Core Event Contracts

| Event Name | Direction | Payload Structure |
|---|---|---|
| `message:send` | Client $\rightarrow$ Server | `{"tempId": "uuid-v4", "chatId": "c_123", "content": "Hello", "type": "text"}` |
| `message:received` | Server $\rightarrow$ Client | `{"id": "msg_890", "tempId": "uuid-v4", "chatId": "c_123", "senderId": "u_456", "content": "Hello", "timestamp": 1726900000}` |
| `message:ack` | Server $\rightarrow$ Client | `{"tempId": "uuid-v4", "messageId": "msg_890", "status": "sent"}` |
| `presence:update` | Server $\rightarrow$ Client | `{"userId": "u_456", "status": "online" | "offline", "lastSeen": 1726900000}` |
| `typing:state` | Dual | `{"chatId": "c_123", "userId": "u_456", "isTyping": true}` |

---

## 5. Offline Capabilities & Optimistic Updates

```
[User Types & Presses Send]
          │
          ├──> 1. Render message immediately in UI (Status: "Sending / Clock Icon")
          ├──> 2. Write message locally to IndexedDB/SQLite
          └──> 3. Emit `message:send` over WebSocket
                     │
         ┌───────────┴───────────┐
         ▼                       ▼
   [Server Responds ACK]   [Server Drops / Timeout]
         │                       │
         ├── Update UI Status    └── Queue message in local DB
         │   to "Sent" (✓)           Mark status as "Failed"
         └── Update local DB         Provide "Tap to Retry" button
```

---

## 6. Security & Performance Strategy

1. **Client-Side Encryption:** Messages are encrypted locally before `message:send` is dispatched, using shared keys derived during E2EE key exchange.
2. **Virtual Scroll List:** The `MessageFeed` utilizes DOM virtualization (e.g., `react-window` or `Virtuoso`) to ensure thousands of historical messages can be loaded without memory leaks.
3. **Media Compression:**
   * Images are auto-resized and compressed via HTML Canvas API before upload.
   * Audio recordings are encoded in `opus/webm` or `aac` format to optimize upload speeds.