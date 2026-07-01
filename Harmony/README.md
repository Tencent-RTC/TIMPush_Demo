English | [简体中文](./README_ZH.md)

# TIMPush HarmonyOS Demo

> For the overview and console prerequisites (create an app / obtain keys / enable push and configure the HarmonyOS channel), please read the parent document first: [../README.md](../README.md). This document focuses only on the HarmonyOS client-side integration.

The Tencent Cloud TIMPush offline-push HarmonyOS experience demo. **This project is a clean template with nothing configured**: the `bundleName`, SDKAppID, AppKey, and the HarmonyOS (Huawei) push channel **all need to be configured by you** as described below before it can build and run.

## Prerequisites

- You have completed the **Common Prerequisites (Console)** in the parent document, obtained the SDKAppID / AppKey, and enabled push and configured the HarmonyOS offline channel in the console.
- DevEco Studio is installed (compatible SDK 5.0.0(12), target SDK 6.0.0(20)), and a real HarmonyOS device is ready (push must be verified on a real device).

## Project Structure

```text
Harmony/
├── AppScope/                 # App config, bundleName = com.tencentcloud.imdemo
├── entry/                    # entry module (the PushDemo app)
│   ├── oh-package.json5      # depends on @tencentcloud/imsdk, @tencentcloud/timpush
│   └── src/main/
│       ├── module.json5      # declares INTERNET / GET_NETWORK_INFO permissions
│       └── ets/
│           ├── entryability/EntryAbility.ets   # initSDK + registerPush + push listener
│           └── pages/Index.ets                 # demo UI
├── build-profile.json5
├── hvigorfile.ts
└── oh-package.json5
```

## Configuration Steps

### 1. Install dependencies

Open the `Harmony/` directory with DevEco Studio; it syncs `ohpm` dependencies automatically. Or from the command line:

```bash
cd Harmony
ohpm install
```

The dependencies are pulled from the ohpm registry (see `entry/oh-package.json5`):

```json5
"dependencies": {
    "@tencentcloud/imsdk": "^9.0.7652",
    "@tencentcloud/timpush": "^8.7.7203"
}
```

### 2. Set the application bundleName

The `bundleName` in `AppScope/app.json5` is `"com.tencentcloud.imdemo"` by default. Change it to your own bundleName (must match the one registered in the console and in AppGallery Connect):

```json5
{
  "app": {
    "bundleName": "com.your.package"
  }
}
```

### 3. Fill in the SDKAppID and AppKey

The placeholders appear in **two** files. Change both to the actual values obtained in the **Prerequisites**:

- `entry/src/main/ets/entryability/EntryAbility.ets`
- `entry/src/main/ets/pages/Index.ets`

```typescript
const SDK_APP_ID: number = 0;   // change to your SDKAppID
const APP_KEY: string = '';     // change to your AppKey
```

### 4. Configure the HarmonyOS push channel

HarmonyOS offline push relies on the HarmonyOS (Huawei) Push Kit:

1. Register the app on [AppGallery Connect](https://developer.huawei.com/consumer/cn/service/josp/agc/index.html), enable **Push Kit**, and keep the `bundleName` consistent with Step 2.
2. Configure the HarmonyOS offline push channel in the IM console (fill in the certificate / channel information obtained from AGC).
3. If your integration requires it, place the `agconnect-services.json` downloaded from AGC into the project as instructed by the official documentation.

> For the fields and detailed steps, see [Vendor Configuration Index](https://cloud.tencent.com/document/product/269/100622).

### 5. Compile and run

Connect a real HarmonyOS device, select the `entry` module, and Run. After registration succeeds, the UI displays the RegistrationID; receiving a push means the whole flow works.

## Project Notes

- `EntryAbility.ets`: in `onCreate()` it registers the push listener (`addPushListener`), calls `initSDK`, then `registerPush`; `onDestroy()` calls `removePushListener`.
- `Index.ets`: demo UI that calls `registerPush` / `unRegisterPush` / `getRegistrationID` / `setRegistrationID` (register / unregister / get / set / reset the RegistrationID).
- `module.json5` declares the `ohos.permission.INTERNET` and `ohos.permission.GET_NETWORK_INFO` permissions.

> Note: `setRegistrationID` only takes effect when called **before** `registerPush`.

## References

- [HarmonyOS Integration Guide (Documentation Center)](https://cloud.tencent.com/document/product/269)
- [Vendor Configuration Index](https://cloud.tencent.com/document/product/269/100622)
