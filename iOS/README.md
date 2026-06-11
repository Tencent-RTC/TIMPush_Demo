English | [简体中文](./README_ZH.md)

# TIMPush iOS Demo

> For the overview and console prerequisites (create an app / obtain keys / enable push and configure the APNs channel), please read the parent document first: [../README.md](../README.md). This document focuses only on the iOS client-side integration.

The Tencent Cloud TIMPush offline-push iOS experience demo. **This project is a clean template with nothing configured**: the SDKAppID, AppKey, APNs BusinessID, signing, Bundle ID, App Group, and `pod install` **all need to be configured by you** as described below before it can build and run.

## Prerequisites

- You have completed the **Common Prerequisites (Console)** in the parent document, obtained the SDKAppID / AppKey, and configured the APNs push certificate and BusinessID in the console.
- macOS + Xcode, CocoaPods installed, and a real iOS device ready (the simulator does not support APNs and cannot verify push).

## Configuration Steps

### 1. Install dependencies

```bash
cd iOS
pod install
```

> If CocoaPods is not installed, run `sudo gem install cocoapods` first. This generates `Pods/` and `Podfile.lock`.

### 2. Open `pushdemo.xcworkspace` with Xcode

> ⚠️ You must open the `.xcworkspace`, **not** the `.xcodeproj`, otherwise the Pod dependencies won't be found.

### 3. Fill in the SDKAppID and AppKey

Open `pushdemo/TestPushViewController.m` and change the placeholders to the actual values obtained in the **Prerequisites**:

```objc
static const int kTIMPushSDKAppID = 0;       // change to your SDKAppID
static NSString * const kTIMPushAppKey = @"";// change to your AppKey
```

### 4. Fill in the APNs BusinessID and App Group

Open `pushdemo/PushConstants.h` and modify the placeholders in the DEBUG branch:

```objc
#ifdef DEBUG
#define kAPNSBusiId 11111             // change to the BusinessID of the APNs channel in the console
#define kTIMPushAppGorupKey @"xxxx"   // change to your App Group Identifier (see Step 5.2)
```

> The `BUILDAPPSTORE` / enterprise-certificate branches only take effect for Release builds; keep the defaults for normal experience.

### 5. Configure signing / Bundle ID / App Group

#### 5.1 Configure signing and Bundle ID

For both the `pushdemo` and `pushservice` targets, in `Signing & Capabilities`:

- `Team`: select your own Apple Developer Team.
- `Bundle Identifier`: change to your own Bundle ID.
  - `pushdemo` main App: e.g. `com.your-company.timpush.demo`
  - `pushservice` push extension: **must** be the main App Bundle ID followed by `.pushservice`, e.g. `com.your-company.timpush.demo.pushservice`

#### 5.2 Configure App Group

App Group lets the main App share data with the `pushservice` push extension and is required by TIMPush.

1. **Create it in Apple Developer**: log in to https://developer.apple.com/account → Identifiers, switch to `App Groups`, click `+` to create one. The Identifier must start with `group.`, e.g. `group.com.your-company.timpush.demo`.
2. **Enable it in Xcode**: for both the `pushdemo` and `pushservice` targets, `Signing & Capabilities` → `+ Capability` to add `App Groups`, then tick the `group.xxx` you just created. If it can't be ticked, click the refresh button to let Xcode regenerate the profile.
3. **Fill it back into `PushConstants.h`**: set `kTIMPushAppGorupKey` in the DEBUG branch to that `group.xxx` (i.e. Step 4).

### 6. Run on a real device

iOS push can only be verified on a **real device**. Connect a device, select the `pushdemo` scheme, and Run. Receiving a push means the whole flow works.

## FAQ

**Q: Build fails with `'TIMPushManager.h' file not found`?**
Did you run `pod install`? Did you open the `.xcworkspace` or the `.xcodeproj`? It must be the former.

**Q: It runs on the device, but no push is received?**
Troubleshoot in this order:
1. Is the `Push Notifications` capability enabled in `Signing & Capabilities`?
2. Is the App Group **exactly the same** in all three places: Apple Developer / Xcode (both pushdemo + pushservice targets) / `PushConstants.h` (DEBUG branch)?
3. Has the app on the device granted notification permission?
4. Did you obtain the RegistrationID? (Check the `TestPushViewController` UI and logs.)

**Q: `Provisioning profile doesn't include the com.apple.security.application-groups entitlement`?**
The App Groups capability wasn't enabled successfully in Xcode. Redo Step 5.2, and click the refresh button to regenerate the profile if needed.

## References

- [iOS Integration Guide (Documentation Center)](https://cloud.tencent.com/document/product/269)
- [Vendor Configuration Index](https://cloud.tencent.com/document/product/269/100622)
