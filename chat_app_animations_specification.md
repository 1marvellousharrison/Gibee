# Chat Application Animation Specifications & Framer Motion Integration

This document outlines the motion design system and React animation components using **Framer Motion**, customized for the **Dark Purple / Black** theme.

---

## 1. Motion Design Tokens & Configuration

Add these global transition defaults to keep animations consistent across the entire application:

```javascript
// constants/motion.js
export const transitions = {
  spring: { type: "spring", stiffness: 400, damping: 25 },
  smooth: { duration: 0.2, ease: [0.25, 0.1, 0.25, 1.0] },
  bounce: { type: "spring", stiffness: 500, damping: 15 },
};

export const variants = {
  // Page / Tab Transitions
  pageFade: {
    initial: { opacity: 0, y: 8 },
    animate: { opacity: 1, y: 0 },
    exit: { opacity: 0, y: -8 },
  },
};
```

---

## 2. Core Animated Components

### A. Incoming & Outgoing Message Bubbles
* **Effect:** Pop in with a slight vertical slide and subtle spring scale up.
* **Purpose:** Distinguishes newly received or sent messages from old ones in the scroll history.

```jsx
import { motion } from "framer-motion";

export const MessageBubble = ({ message, isSent }) => {
  return (
    <motion.div
      initial={{ opacity: 0, scale: 0.92, y: 12 }}
      animate={{ opacity: 1, scale: 1, y: 0 }}
      transition={transitions.spring}
      className={`max-w-[70%] p-3 rounded-2xl ${
        isSent
          ? "bg-[#6b21a8] text-white self-end rounded-br-none"
          : "bg-[#18181b] text-[#e4e4e7] border border-[#3f3f46] self-start rounded-bl-none"
      }`}
    >
      <p className="text-sm">{message.text}</p>
    </motion.div>
  );
};
```

---

### B. Typing Indicator (Pulse Animation)
* **Effect:** Three glowing purple dots bouncing sequentially in a wave loop.
* **Purpose:** Shows real-time activity in a conversation without layout jumps.

```jsx
import { motion } from "framer-motion";

export const TypingIndicator = () => {
  const dotVariants = {
    initial: { y: "0%" },
    animate: { y: "-60%" },
  };

  return (
    <div className="flex items-center gap-1.5 p-3 bg-[#18181b] rounded-full w-fit border border-[#27272a]">
      {[0, 1, 2].map((index) => (
        <motion.span
          key={index}
          className="w-2 h-2 bg-[#a855f7] rounded-full shadow-[0_0_8px_rgba(168,85,247,0.6)]"
          variants={dotVariants}
          initial="initial"
          animate="animate"
          transition={{
            duration: 0.4,
            repeat: Infinity,
            repeatType: "reverse",
            delay: index * 0.15,
            ease: "easeInOut",
          }}
        />
      ))}
    </div>
  );
};
```

---

### C. Unread Badge & Reaction Counter
* **Effect:** Quick pop-out scale animation whenever a new unread message arrives or a reaction count increments.

```jsx
import { motion, AnimatePresence } from "framer-motion";

export const UnreadBadge = ({ count }) => {
  return (
    <AnimatePresence mode="wait">
      {count > 0 && (
        <motion.span
          key={count}
          initial={{ scale: 0, opacity: 0 }}
          animate={{ scale: 1, opacity: 1 }}
          exit={{ scale: 0, opacity: 0 }}
          transition={transitions.bounce}
          className="px-2 py-0.5 text-xs font-bold text-white bg-[#a855f7] rounded-full shadow-[0_0_10px_rgba(168,85,247,0.5)]"
        >
          {count}
        </motion.span>
      )}
    </AnimatePresence>
  );
};
```

---

### D. Active Chat Item Hover & Focus
* **Effect:** Smooth background highlight slide and subtle left border shift when hovering over a chat in the sidebar.

```jsx
import { motion } from "framer-motion";

export const ChatListItem = ({ chat, isActive, onClick }) => {
  return (
    <motion.div
      onClick={onClick}
      whileHover={{ backgroundColor: "rgba(39, 39, 42, 0.6)", x: 4 }}
      whileTap={{ scale: 0.98 }}
      transition={transitions.smooth}
      className={`flex items-center p-3 cursor-pointer rounded-xl transition-colors ${
        isActive ? "bg-[#27272a] border-l-4 border-[#a855f7]" : ""
      }`}
    >
      <div className="relative">
        <img src={chat.avatar} className="w-12 h-12 rounded-full" alt="" />
        {chat.isOnline && (
          <motion.span
            initial={{ scale: 0 }}
            animate={{ scale: 1 }}
            className="absolute bottom-0 right-0 w-3.5 h-3.5 bg-emerald-500 rounded-full border-2 border-[#09090b]"
          />
        )}
      </div>
      <div className="ml-3 flex-1">
        <h4 className="text-sm font-semibold text-[#f4f4f5]">{chat.name}</h4>
        <p className="text-xs text-[#a1a1aa] truncate">{chat.lastMessage}</p>
      </div>
    </motion.div>
  );
};
```

---

## 3. Animation Summary Matrix

| UI Element | Trigger Event | Motion Type | Purple Glow / Style Effect |
|---|---|---|---|
| **Message Bubble** | New message rendered | Slide up + Spring scale | Outgoing gets `#6b21a8` fill |
| **Typing Dots** | Socket `typing:start` event | Staggered vertical pulse | Dots glow with `#a855f7` box-shadow |
| **Unread Badge** | Counter increment | Spring scale pop (`0 -> 1`) | Bright `#a855f7` pill |
| **Sidebar Item** | Cursor hover | Horizontal slide (+4px) | Soft dark purple hover tint |
| **Send Button** | Hover / Click | Icon rotation + scale tap | Pulse purple glow when active |