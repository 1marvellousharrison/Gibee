# Chat Application Login Page — Frontend Requirements & Design Specification

---

## 1. Visual Theme & Style Guide

The visual design system centers around a deep, modern dark mode palette utilizing rich purples and contrasting accents.

### Color Palette

| Tone | Hex Code | Usage |
| :--- | :--- | :--- |
| **Pure Black** | `#000000` | Main canvas background, primary page background |
| **Dark Purple** | `#120826` | Card/container background, modal headers, navigation backgrounds |
| **Mid Purple** | `#5B21B6` | Secondary buttons, active borders, subtle highlights |
| **Primary Purple** | `#7C3AED` | Primary interactive elements, CTA buttons, active focus states |
| **Light Purple** | `#C4B5FD` | Primary text highlights, icons, link text, secondary indicators |
| **Soft Light Purple** | `#EDE9FE` | Primary text color on dark backgrounds, input field text |
| **Subtle Overlay** | `#1E1B4B` | Input background fields, hover state containers |

---

## 2. User Submissions & Form Inputs

To log in, users must provide the following information depending on the selected login method:

### A. Phone Number Login (Default / Recommended for WhatsApp-style)
* **Country Code Selection:** Dropdown/Modal (e.g., `+1`, `+234`, `+44`).
* **Phone Number Field:** Digits only, dynamically masked based on country selection.
* **Verification Code (OTP):** 6-digit numeric input field with auto-advance across individual digit boxes.

### B. Email / Username Login (Alternative)
* **Identifier Field:** Validated email address or unique username.
* **Password Field:** Secure string with dynamic show/hide toggle.

### C. Universal Submissions
* **"Remember Me" Toggle:** Persistence state (Boolean).
* **Security Token:** Optional reCAPTCHA / Cloudflare Turnstile response payload.

---

## 3. Frontend Functional Requirements

### 1. Form Validation & UX
* **Client-Side Validation:**
  * Real-time regex check for phone number format and email structure before enabling the submission button.
  * Clear inline validation messages rendered in light purple (`#C4B5FD`).
* **Input Auto-Focus & Navigation:**
  * Auto-focus on the primary input field upon page load.
  * Support full keyboard navigation (`Tab`, `Shift+Tab`, `Enter`).
* **Loading & Feedback States:**
  * Animated loading spinner inside the submit button during API requests.
  * Form fields disabled while network requests are in flight.
* **Error Handling:**
  * Top toast/banner error display for backend authentication failures (e.g., *"Invalid verification code"*, *"Rate limit exceeded"*).

### 2. Multi-Step Login Flow
* **Step 1:** User inputs primary identifier (Phone or Email).
* **Step 2:** User inputs password or enters the 6-digit OTP code sent via SMS/Email.
* **Step 3:** Animated transition into the main chat interface upon successful authentication token receipt.

### 3. Session & Security Management
* **Token Storage:** Store short-lived access tokens in memory/state and long-lived refresh tokens in secure `HttpOnly` cookies.
* **Auto-Redirect:** Check local session state on load; automatically redirect logged-in users away from the login page.

---

## 4. Transmission & API Submission Methods

All credentials and payload submissions **must** occur over secure `HTTPS` protocols using JSON format payloads.

| Action / Workflow | HTTP Method & Endpoint | Payload Structure | Response Received |
| :--- | :--- | :--- | :--- |
| **Request Phone OTP** | `POST /api/v1/auth/request-otp` | `{"phone_number": "+1234567890", "country_code": "US"}` | `{"status": "success", "session_id": "xyz123"}` |
| **Verify Phone OTP** | `POST /api/v1/auth/verify-otp` | `{"session_id": "xyz123", "otp_code": "582910"}` | `{"access_token": "JWT...", "user": {...}}` |
| **Password Auth** | `POST /api/v1/auth/login` | `{"identifier": "user@example.com", "password": "..."}` | `{"access_token": "JWT...", "user": {...}}` |
| **OAuth Login** | `POST /api/v1/auth/oauth` | `{"provider": "google", "id_token": "..."}` | `{"access_token": "JWT...", "user": {...}}` |

---

## 5. UI Layout Blueprint

```
+-----------------------------------------------------------------+
|                                                                 |
|                      [ Pure Black Background ]                  |
|                                                                 |
|               +---------------------------------+               |
|               |  [ Dark Purple Card Container ] |               |
|               |                                 |               |
|               |       ( Logo / App Name )       |               |
|               |     Light Purple Typography     |               |
|               |                                 |               |
|               |   [ Input: Country & Phone ]    |               |
|               |     Subtle Dark BG + Accent     |               |
|               |                                 |               |
|               |   [ Button: Continue (CTA) ]    |               |
|               |     Solid Vibrant Purple BG     |               |
|               |                                 |               |
|               |   ---------------------------   |               |
|               |      OR Continue With Social    |               |
|               |                                 |               |
|               +---------------------------------+               |
|                                                                 |
+-----------------------------------------------------------------+
```