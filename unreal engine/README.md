English | [简体中文](./README_ZH.md)

# TIMPush Unreal Engine Demo

> For the overview and console prerequisites (create an app / obtain keys / enable push and configure vendor channels), please read the parent document first: [../README.md](../README.md). This document focuses only on the Unreal Engine client-side integration.

The Tencent Cloud TIMPush offline-push UE5 experience demo (project under `pushdemo/`). **This project is a clean template with nothing configured**: the SDKAppID, AppKey, Android vendor channels, and iOS businessID / App Group **all need to be configured by you** as described below before it can build and run.

## Prerequisites

- You have completed the **Common Prerequisites (Console)** in the parent document, obtained the SDKAppID / AppKey, and enabled push and configured the vendor offline channels you need in the console.
- Unreal Engine 5 is installed, plus the Android / iOS packaging environment, and a real device is ready (push must be verified on a real device).

## Project Structure

```text
ue/pushdemo/
├── Config/                    # DefaultEngine.ini etc.
├── Content/                   # demo blueprints / UMG widget
├── Plugins/TIMPush/           # TIMPush plugin (Source/TIMPush, TIMPush_APL.xml)
├── Source/pushdemo/           # main module (pushdemo.Build.cs, MyUserWidget.cpp)
└── pushdemo.uproject
```

## Configuration Steps

### 1. Integrate the TIMPush plugin

The `Plugins/TIMPush` plugin is already in place, and the main module `Source/pushdemo/pushdemo.Build.cs` already references `TIMPush`:

```csharp
PublicDependencyModuleNames.AddRange(new string[] { "Core", "CoreUObject", "Engine", "InputCore", "EnhancedInput", "TIMPush" });
```

### 2. Fill in the SDKAppID and AppKey

Open `Source/pushdemo/MyUserWidget.cpp` and change the placeholders in `CallRegisterPush()` to the actual values obtained in the **Prerequisites**:

```cpp
int appID = 0;        // change to your SDKAppID
FString appKey = "";  // change to your AppKey
```

### 3. Android configuration

Configure in `Plugins/TIMPush/Source/TIMPush/TIMPush_APL.xml`:

- In `buildGradleAdditions`, add the push main package `com.tencent.timpush:tpush:VERSION` and the vendor packages you need (huawei / xiaomi / oppo / vivo / honor / meizu / fcm).
- In `buildscriptGradleAdditions`, add the Huawei / Honor / FCM classpath.
- Fill vivo / Honor APPID / APPKEY in `manifestPlaceholders`.
- Place `timpush-configs.json` under `Source/ThirdParty/TIMPushLibrary/Android/TIMPush/Assets`, and the vendor json files under `Source/ThirdParty/TIMPushLibrary/Android/TIMPush/`.

### 4. iOS configuration

- In `Project Settings > Additional Plist Data`, fill in `businessID` and `TIMPushAppGroupID`.
- In `Config/DefaultEngine.ini`, enable remote notifications: `bEnableRemoteNotificationsSupport=True`.

### 5. Compile and run

Package to a real device and run. Call `RegisterPush` from the demo UI; receiving a push means the whole flow works.

## Project Notes

- `MyUserWidget.cpp`: demonstrates `RegisterPush` / `UnRegisterPush` / `GetRegistrationID` / `SetRegistrationID` / `AddPushListener` / `RemovePushListener` / `ForceUseFCMPushChannel` / `DisablePostNotificationInForeground` via `PushManager::GetInstance()`.
- Register the push listener (`AddPushListener`) in the program entry; the callbacks are `OnRecvPushMessage` / `OnRevokePushMessage` / `OnNotificationClicked`.

## References

- [UE Quick Start](https://cloud.tencent.com/document/product/269/123437)
- [UE Vendor Configuration](https://cloud.tencent.com/document/product/269/123436)
- [UE Client API](https://cloud.tencent.com/document/product/269/123438)

## Contact Us

[zhiliao](https://zhiliao.qq.com/)
