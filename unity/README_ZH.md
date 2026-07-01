[English](./README.md) | 简体中文

# TIMPush Unity Demo

> 整体介绍与控制台前置准备（创建应用 / 获取密钥 / 开通推送并配置厂商通道）请先阅读上级文档：[../README_ZH.md](../README_ZH.md)。本文仅聚焦 Unity 端客户端接入。

腾讯云 TIMPush 离线推送 Unity 端体验 Demo（工程位于 `pushdemo/`）。**本工程是一份未做任何配置的纯净模板**：SDKAppID、AppKey、Android 厂商通道、iOS 证书 ID / App Group 等**均需你按下文自行配置**后才能编译运行。

## 前提

- 已完成上级文档中的【通用前置准备（控制台）】，拿到 SDKAppID / AppKey，并在控制台开通推送、配置好需要支持的厂商离线通道。
- 本机已安装 Unity 及 Android / iOS 构建环境，并准备一台真机（Editor 无法验证推送，需真机）。

## 工程结构

```text
unity/pushdemo/
├── Assets/
│   ├── TIMPush/         # TIMPush SDK 源码（PushManager / 各平台实现）
│   ├── TIMPushExample/  # 示例场景（Scenes/PushDemo.unity）+ Scripts/PushTest.cs
│   └── Plugins/         # Android gradle 模板 / iOS UnityIMPush.mm
├── Packages/
└── ProjectSettings/
```

## 配置步骤

### 1. 打开工程

用 Unity 打开 `unity/pushdemo/`，打开 `Assets/TIMPushExample/Assets/Scenes/PushDemo.unity` 场景。TIMPush SDK 已以源码形式集成在 `Assets/TIMPush/`。

### 2. 填写 SDKAppID 与 AppKey

`Assets/TIMPushExample/Assets/Scripts/PushTest.cs` 在运行时从界面输入框读取 SDKAppID / AppKey / RegistrationID，再调用：

```csharp
PushManager.RegisterPush(sdkAppId, appKey, new PushCallback(onSuccess, onError));
```

在运行的 Demo 界面中输入你的 SDKAppID 与 AppKey，或修改场景输入框的默认值。

### 3. Android 端配置

- 在 `Assets/Plugins/Android/launcherTemplate.gradle` 按需启用厂商通道，在 `baseProjectTemplate.gradle`、`settingsTemplate.gradle` 添加 classpath / 仓库（小米 / 华为 / 荣耀 / OPPO / vivo / 魅族 / FCM），并填写荣耀 / vivo 的 APPID / APPKEY。
- 将 `timpush-configs.json` 放到 `Assets/Plugins/Android/`，华为 / 荣耀 / FCM 的 json 文件放到 `Assets/Plugins/Android/JsonConfigs/`。
- 在 `Player Settings > Publishing Settings > Build` 中勾选 `Custom Main Gradle Template` / `Custom Base Gradle Template` / `Custom Gradle Settings Template`。

### 4. iOS 端配置

- 在 `Assets/Plugins/iOS/UnityIMPush.mm` 中实现 `businessID`（控制台分配的证书 ID）与 `applicationGroupID`。
- 导出 Xcode 工程后开启 `Push Notifications` capability；如需触达统计，配置 Notification Service Extension。

### 5. 编译运行

构建到真机运行。注册成功后 Demo 界面会显示 RegistrationID，收到推送即说明全流程已打通。

## 工程说明

- `PushTest.cs`：演示 `RegisterPush` / `UnRegisterPush` / `GetRegistrationID` / `SetRegistrationID` / `AddPushListener` / `RemovePushListener` / `ForceUseFCMPushChannel` / `DisablePostNotificationInForeground`。
- 推送监听回调为 `onRecvPushMessage` / `onRevokePushMessage` / `onNotificationClicked`。
- 若已集成 IM 并在 IM 登录成功后调用 `RegisterPush`，请将 `appKey` 传 null，否则会将 IM 账号踢下线。

## 参考文档

- [Unity 快速入门](https://cloud.tencent.com/document/product/269/123769)
- [Push 服务](https://cloud.tencent.com/document/product/269/100621)
- [厂商配置索引](https://cloud.tencent.com/document/product/269/100622)

## 联系我们

[zhiliao](https://zhiliao.qq.com/)
