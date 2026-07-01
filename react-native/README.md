English | [简体中文](./README_ZH.md)

# TIMPush React Native Demo

> For the overview and console prerequisites (create an app / obtain keys / enable push and configure vendor channels), please read the parent document first: [../README.md](../README.md). This document focuses only on the React Native client-side integration.

The Tencent Cloud TIMPush offline-push React Native experience demo. **This project is a clean template with nothing configured**: the SDKAppID, AppKey, Android vendor channels, and iOS signing / certificate ID **all need to be configured by you** as described below before it can build and run.

## Prerequisites

- You have completed the **Common Prerequisites (Console)** in the parent document, obtained the SDKAppID / AppKey, and enabled push and configured the vendor offline channels you need in the console.
- Node.js (`>= 18`), the React Native environment, plus Android Studio / Xcode + CocoaPods, and a real device is ready (push must be verified on a real device).

## Configuration Steps

### 1. Install dependencies

```bash
cd react-native
npm install
# iOS additionally
cd ios && pod install && cd ..
```

The push plugin is declared in `package.json`:

```json
"@tencentcloud/react-native-push": "^1.4.0"
```

### 2. Fill in the SDKAppID and AppKey

Open `App.tsx` and change the placeholders to the actual values obtained in the **Prerequisites**:

```typescript
const SDK_APP_ID = 0;   // change to your SDKAppID
const APP_KEY = '';     // change to your AppKey
```

### 3. Android native configuration

- The entry class `MainApplication.kt` extends `TencentCloudPushApplication`, and `android/app/src/main/AndroidManifest.xml` points `android:name` to it.
- Add the vendor maven repositories and classpath in `android/build.gradle`, and enable the vendor channels you need in `android/app/build.gradle` (Xiaomi / Huawei / Honor / OPPO / vivo / Meizu / FCM).
- Place the vendor config files:
  - `timpush-configs.json` → `android/app/src/main/assets/`
  - Huawei `agconnect-services.json` → `android/app/src/main/assets/`
  - FCM `google-services.json` → `android/app/` (**not** assets)
  - Honor `mcs-services.json` → `android/app/` (**not** assets)
- Fill Honor / vivo `manifestPlaceholders` in `android/app/build.gradle`.

### 4. iOS native configuration

- Open `ios/PushDemo.xcworkspace` with Xcode (**not** the `.xcodeproj`).
- In `Signing & Capabilities`, add the `Push Notifications` capability and configure signing / Bundle ID.
- Fill the APNs certificate ID into `timpush-configs.json` under `ios/.../Resources/`.

### 5. Compile and run

```bash
npm run android
# or
npm run ios
```

Connect a real device and run. After registration succeeds, the UI displays the RegistrationID; receiving a push means the whole flow works.

## Project Notes

- `App.tsx`: demonstrates `registerPush` / `unRegisterPush` / `getRegistrationID` / `setRegistrationID`, and listens to `NOTIFICATION_CLICKED` / `MESSAGE_RECEIVED` / `MESSAGE_REVOKED` via `addPushListener`.
- `setRegistrationID` only takes effect when called **before** `registerPush`.
- If you have integrated IM and call `registerPush` after IM login succeeds, pass `appKey` as null to avoid kicking the IM account offline.

## References

- [React Native Quick Start](https://cloud.tencent.com/document/product/269/104005)
- [Vendor Configuration Index](https://cloud.tencent.com/document/product/269/100622)
