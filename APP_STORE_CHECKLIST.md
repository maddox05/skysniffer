# App Store Submission Checklist

## ✅ Pre-Submission Checklist

### 1. App Assets & Icons
- [x] **App Icon (1024x1024)** - PNG format ✅
  - File: `imag.png` (1024x1024)
  - No transparency or rounded corners
  - Should look good on white AND black backgrounds

- [ ] **Screenshots** (Required for submission)
  - 6.7" display (iPhone 15 Pro Max): Need 3-5 screenshots
  - 6.5" display (iPhone 11 Pro Max): Need 3-5 screenshots
  - Screenshots should show:
    1. Onboarding screen
    2. Main screen with scan list
    3. Camera view
    4. Results screen
    5. Empty state (optional)

### 2. Privacy & Legal
- [x] **Privacy Policy** - Created in `PRIVACY_POLICY.md`
  - [x] Host on GitHub Pages: https://maddox05.github.io/skysniffer/privacy.html
  - [ ] Add URL to App Store Connect

- [x] **Usage Descriptions** in Info.plist
  - [x] Camera usage description
  - [x] Photo library usage description

- [x] **Disclaimer** in onboarding
  - [x] "Educational & Entertainment Use" added

- [x] **Support URL** (Required for App Store)
  - URL: https://github.com/maddox05/skysniffer/issues
  - Email: schmidlkoferbusiness@gmail.com

### 3. App Information

**App Store Connect - Required Fields:**
```
App Name: SkySniffer
Subtitle: AI-Powered Contrail Analysis (max 30 chars)
Category: Education (or Utilities)
Age Rating: 4+ (No objectionable content)

Description (max 4000 chars):
---
SkySniffer is an educational tool that uses advanced AI to help you
learn about contrail formation, persistence patterns, and atmospheric
conditions through analysis of your sky photos.

EDUCATIONAL FEATURES:
• AI-powered analysis using GPT-4 Vision technology
• Learn about contrail persistence and formation types
• Understand atmospheric conditions affecting vapor trails
• Pattern detection with scientific explanations
• Track observations with detailed scan history
• Beautiful, intuitive interface

PERFECT FOR:
• Aviation enthusiasts and students
• Weather watchers and sky observers
• Anyone curious about atmospheric science
• Educational purposes and learning

HOW IT WORKS:
1. Take a photo of the sky or choose from your library
2. AI analyzes contrail patterns, persistence, and atmospheric conditions
3. Learn from detailed scientific explanations
4. Save observations to review and compare later

SCIENTIFIC APPROACH:
SkySniffer provides educational analysis of contrail persistence
levels, formation patterns, and atmospheric phenomena. All analysis
is powered by AI and designed for learning about aviation weather
and atmospheric science.

PRIVACY & SECURITY:
• All photos stored locally on your device
• No tracking, no ads, no data collection
• Your privacy is our top priority

Discover the science of contrails and expand your knowledge of
atmospheric phenomena with SkySniffer!
---

Keywords (max 100 chars, comma-separated):
contrail, sky, weather, clouds, aviation, ai, analysis, atmosphere

Promotional Text (optional, max 170 chars):
Discover what's in the sky above you with AI-powered
contrail analysis. Educational and easy to use!
```

### 4. App Store Connect Setup

**Before You Submit:**
- [ ] Apple Developer Account ($99/year)
  - Sign up at: https://developer.apple.com

- [ ] Create App ID
  ```
  Bundle Identifier: com.yourname.skysniffer
  Name: SkySniffer
  ```

- [ ] Create App in App Store Connect
  - Go to: https://appstoreconnect.apple.com
  - Click "+ " to create new app
  - Fill in bundle ID, name, language (English)

- [ ] Version Information
  ```
  Version: 1.0.0
  Build: 1
  Copyright: 2025 [Your Name]
  ```

### 5. Build & Archive

**In Xcode:**
- [ ] **Update Bundle ID**
  - Project Settings → General → Bundle Identifier
  - Change from `com.yourcompany` to your actual ID

- [ ] **Fix App Icon Format**
  - Convert `imag.jpg` to PNG
  - Drag into AppIcon in Assets

- [ ] **Select "Any iOS Device"** in Xcode
- [ ] **Product → Archive**
- [ ] **Validate** the archive
- [ ] **Distribute** to App Store Connect

### 6. Testing Checklist

**Test on Real Device:**
- [ ] App launches without crashes
- [ ] Camera permission prompt appears
- [ ] Photo library permission prompt appears
- [ ] Can take photo and analyze it
- [ ] Can select photo from library
- [ ] Results display correctly
- [ ] Can save scans
- [ ] Can delete scans
- [ ] Can view past scans
- [ ] Error handling works (try with no internet)
- [ ] Onboarding shows on first launch only

**Test Different Scenarios:**
- [ ] First time user (fresh install)
- [ ] Camera denied permission
- [ ] Photo library denied permission
- [ ] No internet connection
- [ ] Invalid images (non-sky photos)
- [ ] Very large images
- [ ] Multiple scans in quick succession

### 7. App Store Connect - Compliance

- [ ] **Export Compliance**
  - Question: Does your app use encryption?
  - Answer: No (unless you add it)

- [ ] **Content Rights**
  - Confirm you own all content and have rights to publish

- [ ] **Advertising Identifier (IDFA)**
  - Question: Does your app use IDFA?
  - Answer: No (you don't use ads or tracking)

- [ ] **App Privacy Details** (Very Important!)
  ```
  Data Collected:
  - Photos: Yes
    - Used for: App functionality (analysis)
    - Linked to user: No
    - Used for tracking: No

  Data Not Collected:
  - Location, Contacts, Identifiers, Usage Data, etc.

  Privacy Policy URL: https://maddox05.github.io/skysniffer/privacy.html
  ```

### 8. Pricing & Availability

- [ ] **Price:** Free (or set your price)
- [ ] **Availability:** All countries (or select specific)
- [ ] **Release:** Manual release (after approval) recommended

### 9. Review Information

**For Apple Reviewers:**
```
Notes:
This app analyzes sky photos for contrail patterns using AI.
It's for educational and entertainment purposes.

Demo Account: Not applicable (no login required)

Contact Information:
First Name: [Your Name]
Last Name: [Your Name]
Phone: [Your Phone]
Email: [Your Email]
```

### 10. Final Checks

- [ ] All text uses proper capitalization
- [ ] No typos in app description
- [ ] Privacy policy URL is live and accessible
- [ ] Support URL/email is working
- [ ] Screenshots show the current version
- [ ] App name doesn't infringe trademarks
- [ ] All images/assets are your own or properly licensed

---

## 🚨 Common Rejection Reasons & How to Avoid

### Reason 1: Missing/Broken Privacy Policy
- **Fix:** Ensure privacy policy URL works and covers all data usage

### Reason 2: App Crashes on Launch
- **Fix:** Test thoroughly on real device before submitting

### Reason 3: Misleading Claims
- **Fix:** Don't promise medical/scientific accuracy (we added disclaimers ✓)

### Reason 4: Incomplete App Information
- **Fix:** Fill out ALL fields in App Store Connect

### Reason 5: Poor Screenshots
- **Fix:** Use high-quality screenshots showing actual app features

### Reason 6: Permission Descriptions Too Vague
- **Fix:** Be specific why you need camera/photos (already done ✓)

---

## 📱 After Approval

- [ ] Respond to user reviews
- [ ] Monitor crash reports in App Store Connect
- [ ] Plan for updates (bug fixes, new features)
- [ ] Consider adding:
  - Share functionality
  - Export/import scans
  - Settings page
  - More detailed analysis

---

## 🔗 Useful Links

- App Store Connect: https://appstoreconnect.apple.com
- Developer Portal: https://developer.apple.com
- Review Guidelines: https://developer.apple.com/app-store/review/guidelines/
- Human Interface Guidelines: https://developer.apple.com/design/human-interface-guidelines/

---

## ⏱️ Timeline

Typical review times:
- First submission: 2-7 days
- Re-submissions (after rejection): 1-3 days
- Expedited review (special circumstances): 1-2 days

---

**Good luck with your submission! 🚀**
