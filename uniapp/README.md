English | [简体中文](./README_ZH.md)

# TIMPush uni-app Demo

> For the overview and console prerequisites (create an app / obtain keys / enable push and configure vendor channels), please read the parent document first: [../README.md](../README.md). This document focuses only on the uni-app client-side integration.

The Tencent Cloud TIMPush offline-push uni-app experience demo. **This project is a clean template with nothing configured**: the SDKAppID, AppKey, vendor channels, and the config files under `nativeResources/` **all need to be configured by you** as described below before it can build and run.

## Prerequisites

- You have completed the **Common Prerequisites (Console)** in the parent document, obtained the SDKAppID / AppKey, and enabled push and configured the vendor offline channels you need in the console.
- HBuilderX is installed (recommended 4.36–4.63 or 4.66+, **avoid the buggy 4.64 / 4.65**), and a real device is ready (push must be verified on a real device).

## Configuration Steps

### 1. Import the push plugin

The `TencentCloud-Push` native plugin is already located under `uni_modules/`. If you need to update it, download it from the [uni-app Tencent Cloud Push plugin](https://ext.dcloud.net.cn/plugin?id=20169) and import it into HBuilderX (plugin version 1.1.0+, HarmonyOS push requires 1.3.0+).

### 2. Fill in the SDKAppID and AppKey

Open `App.vue` and change the placeholders to the actual values obtained in the **Prerequisites**:

```javascript
// setRegistrationID('<#YOUR_USER_ID#>', () => {});  // optional: bind with the Chat login userID
registerPush(0, '', (data) => { /* ... */ });        // change 0 to your SDKAppID, '' to your AppKey
```

> ⚠️ Do not commit real keys to the repository. `setRegistrationID(userID)` (if used) must be called **before** `registerPush`, and `userID` must match exactly the one used for Chat login.

### 3. Place the config files (`nativeResources/`)

Config files go under the `nativeResources` directory (at the same level as `uni_modules`; create it if missing):

| Platform | File | Path |
|---|---|---|
| Android | `timpush-configs.json` | `nativeResources/android/assets/` |
| Android · Huawei | `agconnect-services.json` | `nativeResources/android/assets/` |
| Android · FCM | `google-services.json` | `nativeResources/android/` (**not** assets) |
| Android · Honor | `mcs-services.json` | `nativeResources/android/` (**not** assets) |
| Android · Honor / vivo | `HONOR_APPID` / `VIVO_APPKEY` / `VIVO_APPID` | `nativeResources/android/manifestPlaceholders.json` |
| iOS | `timpush-configs.json` (with businessID) | `nativeResources/ios/Resources/` |

For vendor dependencies (Honor / vivo / FCM), edit `uni_modules/TencentCloud-Push/utssdk/app-android/config.json`.

### 4. Build a custom debugging base and run

uni-app offline push does not work under the standard base. Build a custom debugging base (自定义调试基座) for Android / iOS in HBuilderX, then run to the real device. Receiving a push means the whole flow works.

## Project Notes

- `App.vue`: demonstrates `registerPush` / `getRegistrationID` / `setRegistrationID`, and listens to `EVENT.NOTIFICATION_CLICKED` / `EVENT.MESSAGE_RECEIVED` / `EVENT.MESSAGE_REVOKED` via `addPushListener`.
- Call `registerPush` after the App launches and the user agrees to the privacy policy.

## References

- [uni-app Quick Start](https://cloud.tencent.com/document/product/269/103522)
- [Vendor Configuration Index](https://cloud.tencent.com/document/product/269/100622)
