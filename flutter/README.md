English | [简体中文](./README_ZH.md)

# TIMPush Flutter Demo

> For the overview and console prerequisites (create an app / obtain keys / enable push and configure vendor channels), please read the parent document first: [../README.md](../README.md). This document focuses only on the Flutter client-side integration.

The Tencent Cloud TIMPush offline-push Flutter experience demo. **This project is a clean template with nothing configured**: the SDKAppID, AppKey, APNs certificate ID, Android vendor channels, and iOS signing / App Group **all need to be configured by you** as described below before it can build and run.

## Prerequisites

- You have completed the **Common Prerequisites (Console)** in the parent document, obtained the SDKAppID / AppKey, and enabled push and configured the vendor offline channels you need in the console.
- Flutter SDK (`>= 3.7`) is installed, plus Android Studio / Xcode + CocoaPods, and a real device is ready (push must be verified on a real device).

## Configuration Steps

### 1. Install dependencies

```bash
cd flutter
flutter pub get
```

The push plugin is declared in `pubspec.yaml`:

```yaml
dependencies:
  tencent_cloud_chat_push: ^9.0.7652
```

### 2. Fill in the SDKAppID and AppKey

Open `lib/main.dart` and change the placeholders to the actual values obtained in the **Prerequisites**:

```dart
const int sdkAppId = 0;               // change to your SDKAppID
const String appKey = '';             // change to your AppKey
const int apnsCertificateId = 11111;  // iOS: change to the APNs certificate ID from the console (Android can ignore)
```

### 3. Android native configuration

- The application class extends `TencentCloudChatPushApplication` (already wired via `android/app/src/main/AndroidManifest.xml`).
- Place the console-generated `timpush-configs.json` under `android/app/src/main/assets/`.
- Enable the vendor channels you need in `android/app/build.gradle` (Xiaomi / Huawei / Honor / OPPO / vivo / Meizu / FCM), and place the vendor services files:
  - Huawei: `agconnect-services.json`
  - FCM: `google-services.json` (in `android/app/`, **not** assets)
  - Honor: `mcs-services.json`

### 4. iOS native configuration

- Run `pod install`:

  ```bash
  cd flutter/ios
  pod install
  ```

- `ios/Runner/AppDelegate.swift` adds `TIMPushDelegate` and implements `businessID()`, `applicationGroupID()`, `onRemoteNotificationReceived(_:)`.
- In Xcode, enable the `Push Notifications` capability and configure signing / Bundle ID / App Group, keeping the App Group consistent with `applicationGroupID()`.

### 5. Compile and run

```bash
flutter run
```

Connect a real device and run. After registration succeeds, the UI displays the RegistrationID; receiving a push means the whole flow works.

## Project Notes

- `lib/main.dart`: demonstrates `registerPush` / `unRegisterPush` / `getRegistrationID` / `setRegistrationID`, plus the `onNotificationClicked` callback.
- `setRegistrationID` only takes effect when called **before** `registerPush`.
- Do not call `registerPush` in the `main` entry point; call it after the user agrees to the privacy policy (for the Chat / TUIKit offline-push scenario, call it after IM login succeeds).

## References

- [Flutter Quick Start](https://cloud.tencent.com/document/product/269/101961)
- [Vendor Configuration Index](https://cloud.tencent.com/document/product/269/100622)
