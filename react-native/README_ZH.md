[English](./README.md) | 简体中文

# TIMPush React Native Demo

> 整体介绍与控制台前置准备（创建应用 / 获取密钥 / 开通推送并配置厂商通道）请先阅读上级文档：[../README_ZH.md](../README_ZH.md)。本文仅聚焦 React Native 端客户端接入。

腾讯云 TIMPush 离线推送 React Native 端体验 Demo。**本工程是一份未做任何配置的纯净模板**：SDKAppID、AppKey、Android 厂商通道、iOS 签名 / 证书 ID 等**均需你按下文自行配置**后才能编译运行。

## 前提

- 已完成上级文档中的【通用前置准备（控制台）】，拿到 SDKAppID / AppKey，并在控制台开通推送、配置好需要支持的厂商离线通道。
- 本机已安装 Node.js（`>= 18`）、React Native 环境、Android Studio / Xcode + CocoaPods，并准备一台真机（推送需在真机验证）。

## 配置步骤

### 1. 安装依赖

```bash
cd react-native
npm install
# iOS 额外执行
cd ios && pod install && cd ..
```

推送插件在 `package.json` 中声明：

```json
"@tencentcloud/react-native-push": "^1.4.0"
```

### 2. 填写 SDKAppID 与 AppKey

打开 `App.tsx`，把占位值改为 **前置准备** 中获取的实际值：

```typescript
const SDK_APP_ID = 0;   // 改为你的 SDKAppID
const APP_KEY = '';     // 改为你的 AppKey
```

### 3. Android 端配置

- 入口类 `MainApplication.kt` 已继承 `TencentCloudPushApplication`，且 `android/app/src/main/AndroidManifest.xml` 的 `android:name` 指向它。
- 在 `android/build.gradle` 添加厂商 maven 仓库与 classpath，在 `android/app/build.gradle` 按需启用厂商通道（小米 / 华为 / 荣耀 / OPPO / vivo / 魅族 / FCM）。
- 放置厂商配置文件：
  - `timpush-configs.json` → `android/app/src/main/assets/`
  - 华为 `agconnect-services.json` → `android/app/src/main/assets/`
  - FCM `google-services.json` → `android/app/`（**非** assets）
  - 荣耀 `mcs-services.json` → `android/app/`（**非** assets）
- 在 `android/app/build.gradle` 填写荣耀 / vivo 的 `manifestPlaceholders`。

### 4. iOS 端配置

- 用 Xcode 打开 `ios/PushDemo.xcworkspace`（**不要**打开 `.xcodeproj`）。
- 在 `Signing & Capabilities` 添加 `Push Notifications` capability，并配置签名 / Bundle ID。
- 把 APNs 证书 ID 填入 `ios/.../Resources/` 下的 `timpush-configs.json`。

### 5. 编译运行

```bash
npm run android
# 或
npm run ios
```

连接真机直接运行。注册成功后界面会显示 RegistrationID，收到推送即说明全流程已打通。

## 工程说明

- `App.tsx`：演示 `registerPush` / `unRegisterPush` / `getRegistrationID` / `setRegistrationID`，并通过 `addPushListener` 监听 `NOTIFICATION_CLICKED` / `MESSAGE_RECEIVED` / `MESSAGE_REVOKED`。
- `setRegistrationID` 必须在 `registerPush` **之前**调用才会生效。
- 若已集成 IM 并在 IM 登录成功后调用 `registerPush`，请将 `appKey` 传 null，否则会将 IM 账号踢下线。

## 参考文档

- [React Native 快速入门](https://cloud.tencent.com/document/product/269/104005)
- [厂商配置索引](https://cloud.tencent.com/document/product/269/100622)
