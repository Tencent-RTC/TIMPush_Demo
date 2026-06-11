English | [简体中文](./README_ZH.md)

# Push Service (TIMPush) Demo

## Product Introduction
Push Service is a one-stop App message push solution that delivers cross-platform, highly reliable message reach without building your own infrastructure. After integrating the TIMPush offline push plugin, messages can still be delivered to the user's notification bar through each handset vendor's system-level channel even when the App process is killed or in the background, reaching active users within the last 30 days.

**Use Cases**

- **App online & offline push**: Reach users instantly while online, and wake up active users within 30 days while offline.
- **IM message push** (requires the IM SDK): Notification-bar push that opens the chat conversation when tapped.
- **Audio/Video call invitation** (requires the Call SDK): Supports both notification-bar push and VoIP.

**Supported Offline Push Vendors**

- **China**: Xiaomi, Huawei, Honor, OPPO, vivo, Meizu, APNs (including OnePlus, realme, iQOO and other sub-brands).
- **Overseas**: Google FCM.
- **Frameworks**: Android, iOS, Flutter, uni-app, React-Native, WeChat Mini Program, HarmonyOS, Unity, Unreal Engine.

> For more product details, see the official documentation: [Push Service Overview](https://cloud.tencent.com/document/product/269/100621).

## Project Structure
This project is the experience demo for TIMPush offline push, split into two independent sub-projects by platform. For the client-side integration steps, configuration items, and troubleshooting of each platform, see the README in the corresponding directory:

| Directory | Platform | Integration Guide |
|---|---|---|
| `Android/` | Android (Android Studio project) | [Android Integration Guide](./Android/README.md) |
| `iOS/` | iOS (Xcode project) | [iOS Integration Guide](./iOS/README.md) |

## Common Prerequisites (Console)
No matter which platform you run, you must first complete the following account- and vendor-related setup in the console. After that, go to the corresponding platform directory to continue the client-side configuration.

### Step 1. Create an App
1. Log in to the [IM console](https://console.cloud.tencent.com/im).
 >If you already have an app, record its SDKAppID and go to **step 2**.
 >
2. On the **Application List** page, click **Create Application**.
3. In the **Create Application** dialog box, enter the app information and click **Confirm**.
 After the app is created, an app ID (SDKAppID) will be automatically generated, which should be noted down.

### Step 2: Obtain Key Information
1. Click **Application Configuration** in the row of the target app to enter the app details page.
2. Click **View Key** and copy and save the SDKAppID, SecretKey, and AppKey.
 > Please store the key information properly to prevent leakage.

### Step 3: Enable Push and Configure Vendor Offline Channels
1. Enable the push capability on the **Push Service** page in the console.
2. Configure the offline push channels of the handset vendors you need (Xiaomi / Huawei / Honor / OPPO / vivo / Meizu / FCM / APNs), filling in the certificate and channel information obtained from each vendor's portal.
 >Only configure the vendors you plan to support. There is no need to place files for vendors you have not configured.
3. After the vendor channels are configured, the console generates the push configuration (`timpush-configs.json`) and the service configuration files required by each vendor.

> For how to apply for and configure each vendor channel, see the official documentation: [Push Service Documentation](https://cloud.tencent.com/document/product/269).

## Platform Integration
After completing the console prerequisites above, go to the corresponding platform directory and follow its guide:

- **Android**: Fill the SDKAppID / AppKey into the project and place the vendor services.json. See the [Android Integration Guide](./Android/README.md).
- **iOS**: Run `pod install`, and configure signing / Bundle ID / App Group. See the [iOS Integration Guide](./iOS/README.md).

Receiving a push means the whole flow works.

## Security Notice
This demo configures the key directly in the client code, which is only suitable for locally running a demo and feature debugging. In production, integrate the calculation code of `UserSig` into your server and issue it dynamically from the server. For details, see [How do I calculate UserSig on the server?](https://cloud.tencent.com/document/product/269/32688#GeneratingdynamicUserSig).
