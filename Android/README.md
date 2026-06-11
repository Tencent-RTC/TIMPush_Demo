English | [简体中文](./README_ZH.md)

# TIMPush Android Demo

> For the overview and console prerequisites (create an app / obtain keys / enable push and configure vendor channels), please read the parent document first: [../README.md](../README.md). This document focuses only on the Android client-side integration.

The Tencent Cloud TIMPush offline-push Android experience demo. **This project is a clean template with nothing configured**: the package name, SDKAppID, AppKey, vendor push channels, `services.json`, and `timpush-configs.json` **all need to be configured by you** as described below before it can build and run.

## Prerequisites

- You have completed the **Common Prerequisites (Console)** in the parent document, obtained the SDKAppID / AppKey, and enabled push and configured the vendor offline channels you need in the console.
- Android Studio is installed, and a real Android device is ready (push must be verified on a real device).

## Configuration Steps

### 1. Set the application package name

The `namespace` / `applicationId` in `app/build.gradle` are the placeholder `"xxxxx"` by default. Change them to your own package name (must match the one registered in the console and each vendor's portal):

```groovy
android {
    defaultConfig {
        namespace "com.your.package"
        applicationId "com.your.package"
    }
}
```

### 2. Fill in the SDKAppID and AppKey

Open `app/src/main/java/com/tencent/qcloud/tim/tuikit/MainActivity.java` and change the placeholders to the actual values obtained in the **Prerequisites**:

```java
public static final int SDK_APP_ID = 0;   // change to your SDKAppID
public static final String APP_KEY = "";  // change to your AppKey
```

### 3. Enable the vendor push channels you need

By default this project only integrates the basic TIMPush capability; all vendor channels are reserved as **comments**. Uncomment and configure them for the vendors you want to support:

**a. Repositories and plugins**

- Root `build.gradle`: uncomment the maven repository and classpath for the relevant vendors (e.g. Huawei, Honor).
- `app/build.gradle`: uncomment the `apply plugin` and dependency entries for the relevant vendors (Xiaomi / Huawei / Honor / OPPO / vivo / Meizu / FCM).

**b. vivo / Honor placeholder parameters**

Fill in the vendor parameters in `manifestPlaceholders` of `app/build.gradle` (leave the unused vendors empty):

```groovy
manifestPlaceholders = [
    "VIVO_APPKEY" : "your vivo AppKey",
    "VIVO_APPID"  : "your vivo AppID",
    "HONOR_APPID" : "your Honor AppID"
]
```

**c. Vendor `services.json` (place in the `app/` directory)**

Download from the corresponding vendor portal and place into the project's `app/` directory:

| Condition | File Name | Download Portal |
|---|---|---|
| Huawei push enabled | `agconnect-services.json` | https://developer.huawei.com/consumer/cn/service/josp/agc/index.html |
| FCM push enabled | `google-services.json` | https://console.firebase.google.com/ |
| Honor push enabled | `mcs-services.json` | https://developer.honor.com/ |

> There is no need to place files for vendors you have not enabled.

### 4. Configure `timpush-configs.json`

Create `timpush-configs.json` under `app/src/main/assets/` and fill in the push configuration of each vendor (vendor AppID / AppKey / AppSecret, etc.) following the official format. For the fields and examples, see [Android Vendor Configuration](https://cloud.tencent.com/document/product/269/100623).

### 5. Compile and run

Open the `Android/` directory with Android Studio, connect a real device, and Run. After registration succeeds, the UI displays the RegistrationID; receiving a push means the whole flow works.

## Project Notes

- `MainActivity.java`: demonstrates calling `registerPush` / `unRegisterPush` / `getRegistrationID` / `setRegistrationID`.
- `DemoApplication.java`: demonstrates the push message listener and notification-click callback (`TIMPushListener`).

## References

- [Android Quick Start](https://cloud.tencent.com/document/product/269/100626)
- [Android Vendor Configuration](https://cloud.tencent.com/document/product/269/100623)
- [Vendor Configuration Index](https://cloud.tencent.com/document/product/269/100622)
