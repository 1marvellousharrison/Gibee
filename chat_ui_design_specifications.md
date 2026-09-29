# Dark Neumorphic Mobile Chat UI Specifications

## Overview
This document outlines the UI specifications, design system, component breakdown, and layout hierarchy for the dark-themed mobile chat interface. The design features a modern, dark aesthetic with soft depth, subtle inner/outer shadows (neumorphic tendencies), and high-contrast coral/red accents.

---

## 1. Design System & Theme Setup

### Color Palette

| Category | Token / Name | Hex Code | Usage |
| :--- | :--- | :--- | :--- |
| **Background** | Canvas Dark | `#1E2026` | Main application background canvas |
| **Surface** | Card / Container | `#252830` | Conversation items, search bar, bottom bar elements |
| **Primary Accent** | Coral Red | `#FF3B47` | Action buttons, active badges, unread indicators, outgoing message bubbles |
| **Text Primary** | High Contrast White | `#FFFFFF` | Headings, active contact names, outgoing message text |
| **Text Secondary** | Slate Gray | `#8A8F9E` | Message previews, timestamps, placeholder text, secondary icons |
| **Accent Text** | Light Coral | `#FF7A83` | Subtitles, status indicators (e.g., "Typing...") |

### Typography
* **Primary Font Family:** Inter / SF Pro Display / System UI Sans-serif
* **Scale:**
  * **Title 1 (Screen Titles):** `22px` | Bold (`700`)
  * **Body Bold (Contact Names):** `15px` | Semi-bold (`600`)
  * **Body Regular (Message Content):** `14px` | Regular (`400`)
  * **Caption / Subtext:** `12px` | Regular (`400`)
  * **Timestamp & Badges:** `11px` | Semi-bold (`600`)

### Shadows & Elevation
* **Soft Neumorphic Elevation:**
  * Top-Left Shadow: `rgba(255, 255, 255, 0.03)`
  * Bottom-Right Shadow: `rgba(0, 0, 0, 0.45)`
  * Blur Radius: `10px - 15px`
* **Rounded Corner Radius:**
  * Cards / Items: `16px`
  * Action Buttons / Badges: `9999px` (Pill / Circular)
  * Message Bubbles: `18px`

---

## 2. Screen 1: Chats Overview (List View)

### Top Navigation Header
* **Left Avatar:** `36x36px` circular user profile image.
* **Title:** `"Chats"` (`22px`, Bold).
* **Right Primary Action Button:** Floating Circular Button (`40x40px`) in **Coral Red** (`#FF3B47`) with a white `+` icon.

### Search Bar
* **Container:** Full-width rounded input (`48px` height, `16px` border-radius).
* **Placeholder:** `"Search"` in Slate Gray (`#8A8F9E`).
* **Background:** Soft inset container background (`#252830`).

### Conversation List Items
Each conversation item contains:
1. **Avatar:** `48x48px` circular profile photo with a subtle drop-shadow border.
2. **Contact Name:** Text primary (`#FFFFFF`), `15px` Semi-bold.
3. **Last Message Preview:** Text secondary (`#8A8F9E`), `13px` Regular (Truncated with ellipsis).
4. **Timestamp:** Text secondary (`#8A8F9E`) or accent red (`#FF3B47` for active unread), right-aligned.
5. **Unread Badge:** Circular badge (`#FF3B47`), bold white text (`11px`), displaying count (e.g., `100`, `99+`, `3`).

### Bottom Navigation Dock
* **Floating Container:** Dark rounded pill shape anchored to the bottom.
* **Icons:**
  * **Chats (Active):** Highlighted with a red container badge.
  * **Camera:** Outline icon.
  * **Scan / QR Code:** Center utility icon.
  * **Settings:** Gear/cog outline icon.

---

## 3. Screen 2: Active Conversation View

### Header Bar
* **Back Button:** Left circular button with a red arrow (`#FF3B47`).
* **Contact Avatar:** `38x38px` circular photo.
* **Contact Details:**
  * **Name:** `"Kathy Gomez"` (`16px`, Bold).
  * **Status:** `"Typing..."` (`12px`, Light Coral `#FF7A83`).
* **Call Action:** Floating circular phone icon button on top right (`#FF3B47` icon tint).

### Chat Thread (Message Bubbles)
* **Date Separator:** Centered caption `"Today"` (`12px`, `#8A8F9E`).
* **Incoming Message (Left Aligned):**
  * **Background:** Dark Surface (`#2B2E38`).
  * **Text:** Light Slate / White (`#E1E4ED`).
  * **Corner Radius:** `16px` (Bottom-left subtle rounding).
* **Outgoing Message (Right Aligned):**
  * **Background:** Coral Red (`#FF3B47`).
  * **Text:** White (`#FFFFFF`).
  * **Corner Radius:** `16px` (Bottom-right subtle rounding).
* **Timestamps:** Placed inline at bottom-right of bubbles in small font (`10px`).

### Message Input Dock
* **Input Container:** Rounded capsule bar (`#252830`).
* **Left Attachment:** Emoji smile icon (`#FF3B47`).
* **Text Placeholder:** `"Type a message"` (`14px`, Slate Gray).
* **Right Actions:**
  * Attachment / Paperclip icon (`#FF3B47`).
  * Camera icon (`#FF3B47`).
* **Primary Send / Voice Button:** Solid Coral Red circular floating button with a microphone/send icon (`#FF3B47` background, white icon).

---

## 4. Key UX & Visual Highlights
* **Neumorphism Aesthetics:** Soft, organic depth creates a physical button feel for interactive elements without harsh lines.
* **Color Hierarchy:** High visual interest focused on action points (Red floating buttons, unread notifications, sent messages).
* **Accessibility:** High contrast ratios between bright coral elements and dark slate surfaces ensure easy readability in low-light environments.