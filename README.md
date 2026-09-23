# Veya — AI Visual Guide

> **"See it clearly. Know what to do."**

Veya is a privacy-first iOS app that turns any screenshot into an annotated step-by-step guide. A user intentionally shares an image, asks a question (typed or spoken), and Veya returns numbered visual callouts with clear, practical next steps.

---

## Features

- **Image import** — PhotosPicker, clipboard paste, or Share Extension from any app
- **Voice + text input** — hold to record a spoken question or type it
- **Annotated results** — zoomable image with numbered callout overlays
- **Step cards** — ordered guide steps with action suggestions (tap, call, navigate)
- **Conversation history** — SwiftData-backed session store
- **Siri Shortcut** — "Ask Veya" via App Intents
- **Privacy-first design** — no background monitoring, no library access, no API keys in binary

---

## Screenshots

> _Add screenshots here once the UI is finalized._

---

## Requirements

| | |
|---|---|
| Xcode | 16.0+ |
| iOS Target | 18.0+ |
| Swift | 6.0 |
| Architecture | MVVM + SwiftData |

---

## Getting Started

```bash
git clone https://github.com/marcompsci/Veya.git
cd Veya
open Veya.xcodeproj
```

1. Select the **Veya** scheme and an iPhone 16 simulator.
2. In **Signing & Capabilities**, select your Apple developer team.
3. Press `⌘R` to build and run.

The app runs fully out of the box using `MockGuideService` — no backend required for development.

---

## Project Structure

```
Veya/
  App/              AppRouter, RootView (navigation + dependency injection)
  Models/           GuideResponse, GuideStep, Annotation, ActionSuggestion, VeyaSession, VeyaError
  Services/         GuideService (protocol), MockGuideService, APIClient,
                    AudioRecorder, SpeechService, SessionStore, SharedImageInbox
  ViewModels/       HomeViewModel, AnalyzeViewModel, ResultViewModel, SettingsViewModel
  Views/
    Onboarding/     3-page onboarding with privacy promise
    Home/           Home screen, quick actions, recent session list
    Analyze/        Image input, voice/text question, prompt chips
    Result/         Annotated image overlay, step cards, action suggestions
    Settings/       Permissions, privacy controls
    Components/     VeyaOrbView, VeyaButton, VeyaCard, EmptyStateView, LoadingStateView
  DesignSystem/     VeyaColors, VeyaTypography, VeyaSpacing, PlatformTypes
  Intents/          AskVeyaIntent, VeyaShortcuts (Siri)
VeyaTests/          Unit tests (Swift Testing framework)
```

---

## Connecting a Live Backend

Veya ships with `MockGuideService` as a drop-in development service. When your backend is ready:

**1. Implement `LiveGuideService`** conforming to the `GuideService` protocol:

```swift
// Services/LiveGuideService.swift
struct LiveGuideService: GuideService {
    private let client = APIClient()

    func createGuide(imageData: Data, userQuestion: String) async throws -> GuideResponse {
        try await client.createGuide(imageData: imageData, userQuestion: userQuestion)
    }
}
```

**2. Swap it in `RootView.swift` line ~47** (marked with a `// TODO` comment):

```swift
// Before:
analyzeViewModel = AnalyzeViewModel(guideService: MockGuideService(), modelContext: modelContext)

// After:
analyzeViewModel = AnalyzeViewModel(guideService: LiveGuideService(), modelContext: modelContext)
```

**3. Update `APIClient.swift`** with your real endpoint and session-token auth.

### Backend security requirements

- API keys must **never** be embedded in the app binary
- Issue short-lived server-side session tokens per authenticated user
- Enforce: authentication, rate limiting, content filtering, HTTPS, deletion controls, audit-safe error logging
- Do **not** log raw image content by default

**Expected request shape** (`POST /v1/guides`):

```json
{
  "imageBase64": "...",
  "userQuestion": "What do I tap next?",
  "deviceLocale": "en-US",
  "appVersion": "1.0"
}
```

Response must decode into `GuideResponse` (see `Models/GuideResponse.swift`).

---

## Info.plist Keys

Add these before App Store submission:

| Key | Value |
|---|---|
| `NSMicrophoneUsageDescription` | `"Veya uses your microphone only when you hold the voice button."` |
| `NSSpeechRecognitionUsageDescription` | `"Veya converts your spoken question into text for your guide."` |

> Photos: Veya uses `PhotosPicker` (system UI) — no `NSPhotoLibraryUsageDescription` needed for read-only selection.

---

## Share Extension

See [`ShareExtensionSetup.md`](ShareExtensionSetup.md) for the complete 6-step guide to add the Share Extension target and App Group.

---

## Siri Shortcut

1. Run the app on device.
2. Open **Settings → Siri & Search → All Shortcuts**.
3. Add **"Ask Veya"**, then invoke with "Hey Siri, Ask Veya."

Registered variants: *"Ask Veya"*, *"Open Veya"*, *"Get help from Veya"*.

---

## Running Tests

```bash
# In Xcode: Product → Test (⌘U)
```

Test targets:
- `GuideResponseTests` — Codable round-trip, annotation types, MockGuideService determinism
- `AnnotationRendererTests` — coordinate conversion, zoom/pan geometry
- `VeyaTests` — SessionStore save/delete/deleteAll, session encoding

---

## Next Steps

| Priority | Task |
|---|---|
| 1 | Implement `LiveGuideService` + connect `APIClient` to real backend |
| 2 | Add Share Extension (see `ShareExtensionSetup.md`) |
| 3 | Add user authentication + server-side session tokens |
| 4 | Add StoreKit 2 subscription for usage tiers |
| 5 | TestFlight usability testing |
| 6 | App Store submission — metadata, screenshots, privacy policy |

---

## Privacy

Veya is designed to be privacy-respecting by default:

- **No background monitoring** — Veya never sees, listens to, or controls other apps without an explicit user share action
- **No broad library access** — uses system `PhotosPicker`; Veya never receives unrequested photos
- **No API keys in binary** — all provider credentials remain server-side
- **Explicit consent** — microphone and speech recognition permissions requested only when first used
- **User-controlled history** — all stored sessions can be deleted from Settings

---

## License

Private. All rights reserved.
