English | [简体中文](./README_ZH.md)

# TIMPush Unity Demo

> For the overview and console prerequisites (create an app / obtain keys / enable push and configure vendor channels), please read the parent document first: [../README.md](../README.md). This document focuses only on the Unity client-side integration.

The Tencent Cloud TIMPush offline-push Unity experience demo (project under `pushdemo/`). **This project is a clean template with nothing configured**: the SDKAppID, AppKey, Android vendor channels, and iOS certificate ID / App Group **all need to be configured by you** as described below before it can build and run.

## Prerequisites

- You have completed the **Common Prerequisites (Console)** in the parent document, obtained the SDKAppID / AppKey, and enabled push and configured the vendor offline channels you need in the console.
- Unity is installed, plus the Android / iOS build environment, and a real device is ready (the Editor cannot verify push; it must be a real device).

## Project Structure

```text
unity/pushdemo/
├── Assets/
│   ├── TIMPush/         # TIMPush SDK source (PushManager / platform impl)
│   ├── TIMPushExample/  # demo scene (Scenes/PushDemo.unity) + Scripts/PushTest.cs
│   └── Plugins/         # Android gradle templates / iOS UnityIMPush.mm
├── Packages/
└── ProjectSettings/
```

## Configuration Steps

### 1. Open the project

Open `unity/pushdemo/` with Unity, and open the `Assets/TIMPushExample/Assets/Scenes/PushDemo.unity` scene. The TIMPush SDK is already integrated as source under `Assets/TIMPush/`.

### 2. Fill in the SDKAppID and AppKey

`Assets/TIMPushExample/Assets/Scripts/PushTest.cs` reads the SDKAppID / AppKey / RegistrationID from the on-screen input fields at runtime, then calls:

```csharp
PushManager.RegisterPush(sdkAppId, appKey, new PushCallback(onSuccess, onError));
```

Enter your SDKAppID and AppKey in the running demo UI, or change the defaults in the scene's input fields.

### 3. Android configuration

- Enable the vendor channels you need in `Assets/Plugins/Android/launcherTemplate.gradle`, add the classpath / repositories in `baseProjectTemplate.gradle` and `settingsTemplate.gradle` (Xiaomi / Huawei / Honor / OPPO / vivo / Meizu / FCM), and fill Honor / vivo APPID / APPKEY.
- Place `timpush-configs.json` under `Assets/Plugins/Android/`, and the Huawei / Honor / FCM json files under `Assets/Plugins/Android/JsonConfigs/`.
- In `Player Settings > Publishing Settings > Build`, tick `Custom Main Gradle Template` / `Custom Base Gradle Template` / `Custom Gradle Settings Template`.

### 4. iOS configuration

- Implement `businessID` (the certificate ID from the console) and `applicationGroupID` in `Assets/Plugins/iOS/UnityIMPush.mm`.
- After exporting the Xcode project, enable the `Push Notifications` capability; for delivery statistics configure the Notification Service Extension.

### 5. Build and run

Build to a real device. After registration succeeds, the demo UI shows the RegistrationID; receiving a push means the whole flow works.

## Project Notes

- `PushTest.cs`: demonstrates `RegisterPush` / `UnRegisterPush` / `GetRegistrationID` / `SetRegistrationID` / `AddPushListener` / `RemovePushListener` / `ForceUseFCMPushChannel` / `DisablePostNotificationInForeground`.
- The push listener callbacks are `onRecvPushMessage` / `onRevokePushMessage` / `onNotificationClicked`.
- If you have integrated IM and call `RegisterPush` after IM login succeeds, pass `appKey` as null to avoid kicking the IM account offline.

## References

- [Unity Quick Start](https://cloud.tencent.com/document/product/269/123769)
- [Push Service](https://cloud.tencent.com/document/product/269/100621)
- [Vendor Configuration Index](https://cloud.tencent.com/document/product/269/100622)

## Contact Us

[zhiliao](https://zhiliao.qq.com/)
