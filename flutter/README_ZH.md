[English](./README.md) | 简体中文

# TIMPush Flutter Demo

> 整体介绍与控制台前置准备（创建应用 / 获取密钥 / 开通推送并配置厂商通道）请先阅读上级文档：[../README_ZH.md](../README_ZH.md)。本文仅聚焦 Flutter 端客户端接入。

腾讯云 TIMPush 离线推送 Flutter 端体验 Demo。**本工程是一份未做任何配置的纯净模板**：SDKAppID、AppKey、APNs 证书 ID、Android 厂商通道、iOS 签名 / App Group 等**均需你按下文自行配置**后才能编译运行。

## 前提

- 已完成上级文档中的【通用前置准备（控制台）】，拿到 SDKAppID / AppKey，并在控制台开通推送、配置好需要支持的厂商离线通道。
- 本机已安装 Flutter SDK（`>= 3.7`）、Android Studio / Xcode + CocoaPods，并准备一台真机（推送需在真机验证）。

## 配置步骤

### 1. 安装依赖

```bash
cd flutter
flutter pub get
```

推送插件在 `pubspec.yaml` 中声明：

```yaml
dependencies:
  tencent_cloud_chat_push: ^9.0.7652
```

### 2. 填写 SDKAppID 与 AppKey

打开 `lib/main.dart`，把占位值改为 **前置准备** 中获取的实际值：

```dart
const int sdkAppId = 0;               // 改为你的 SDKAppID
const String appKey = '';             // 改为你的 AppKey
const int apnsCertificateId = 11111;  // iOS：改为控制台的 APNs 证书 ID（Android 可忽略）
```

### 3. Android 端配置

- 应用 Application 已继承 `TencentCloudChatPushApplication`（通过 `android/app/src/main/AndroidManifest.xml` 接入）。
- 将控制台生成的 `timpush-configs.json` 放到 `android/app/src/main/assets/`。
- 在 `android/app/build.gradle` 中按需启用厂商通道（小米 / 华为 / 荣耀 / OPPO / vivo / 魅族 / FCM），并放置厂商 services 文件：
  - 华为：`agconnect-services.json`
  - FCM：`google-services.json`（放 `android/app/`，**非** assets）
  - 荣耀：`mcs-services.json`

### 4. iOS 端配置

- 执行 `pod install`：

  ```bash
  cd flutter/ios
  pod install
  ```

- `ios/Runner/AppDelegate.swift` 已添加 `TIMPushDelegate`，并实现 `businessID()`、`applicationGroupID()`、`onRemoteNotificationReceived(_:)`。
- 在 Xcode 中开启 `Push Notifications` capability，配置签名 / Bundle ID / App Group，并使 App Group 与 `applicationGroupID()` 保持一致。

### 5. 编译运行

```bash
flutter run
```

连接真机直接运行。注册成功后界面会显示 RegistrationID，收到推送即说明全流程已打通。

## 工程说明

- `lib/main.dart`：演示 `registerPush` / `unRegisterPush` / `getRegistrationID` / `setRegistrationID`，以及 `onNotificationClicked` 通知点击回调。
- `setRegistrationID` 必须在 `registerPush` **之前**调用才会生效。
- 不要在 `main` 入口中调用 `registerPush`，应在用户同意隐私政策后调用（Chat / TUIKit 离线推送场景应在 IM 登录成功后调用）。

## 参考文档

- [Flutter 快速入门](https://cloud.tencent.com/document/product/269/101961)
- [厂商配置索引](https://cloud.tencent.com/document/product/269/100622)
