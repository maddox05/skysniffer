# SkySniffer

AI-powered contrail analysis iOS app for educational and entertainment purposes.

## Features

- 📸 Camera and photo library integration
- 🤖 AI-powered image analysis using GPT-4 Vision
- 📊 Detailed pattern detection and atmospheric analysis
- 💾 Local scan history with confidence scores
- 🎨 Beautiful, modern SwiftUI interface
- 🔒 Privacy-focused: all data stored locally

## Setup

### Prerequisites

- Xcode 15.0+
- iOS 17.0+
- Apple Developer Account (for App Store submission)

### Installation

1. Clone this repository
2. Copy `test_app/Config.example.swift` to `test_app/Config.swift`
3. Add your API keys to `Config.swift`:
   - AIProxy keys from https://aiproxy.pro
   - Superwall key from https://superwall.com
4. Open `test_app.xcodeproj` in Xcode
5. Build and run

## Configuration

Create `test_app/Config.swift` (do not commit) with:

```swift
enum Config {
    static let aiProxyPartialKey = "your_aiproxy_key"
    static let aiProxyServiceURL = "your_aiproxy_url"
    static let superwallAPIKey = "your_superwall_key"
}
```

## Privacy

See [PRIVACY_POLICY.md](PRIVACY_POLICY.md) for details on data handling and privacy practices.

## App Store Submission

See [APP_STORE_CHECKLIST.md](APP_STORE_CHECKLIST.md) for a complete submission guide.

## License

All rights reserved.

## Disclaimer

This app provides AI-powered analysis for educational and informational purposes only. Results should not be considered definitive scientific conclusions.
