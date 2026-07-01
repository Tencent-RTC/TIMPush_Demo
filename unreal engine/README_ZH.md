[English](./README.md) | 简体中文

# TIMPush Unreal Engine Demo

> 整体介绍与控制台前置准备（创建应用 / 获取密钥 / 开通推送并配置厂商通道）请先阅读上级文档：[../README_ZH.md](../README_ZH.md)。本文仅聚焦 Unreal Engine 端客户端接入。

腾讯云 TIMPush 离线推送 UE5 端体验 Demo（工程位于 `pushdemo/`）。**本工程是一份未做任何配置的纯净模板**：SDKAppID、AppKey、Android 厂商通道、iOS businessID / App Group 等**均需你按下文自行配置**后才能编译运行。

## 前提

- 已完成上级文档中的【通用前置准备（控制台）】，拿到 SDKAppID / AppKey，并在控制台开通推送、配置好需要支持的厂商离线通道。
- 本机已安装 Unreal Engine 5 及 Android / iOS 打包环境，并准备一台真机（推送需在真机验证）。

## 工程结构

```text
ue/pushdemo/
├── Config/                    # DefaultEngine.ini 等
├── Content/                   # Demo 蓝图 / UMG 界面
├── Plugins/TIMPush/           # TIMPush 插件（Source/TIMPush、TIMPush_APL.xml）
├── Source/pushdemo/           # 主模块（pushdemo.Build.cs、MyUserWidget.cpp）
└── pushdemo.uproject
```

## 配置步骤

### 1. 集成 TIMPush 插件

`Plugins/TIMPush` 插件已放置就位，主模块 `Source/pushdemo/pushdemo.Build.cs` 已引入 `TIMPush`：

```csharp
PublicDependencyModuleNames.AddRange(new string[] { "Core", "CoreUObject", "Engine", "InputCore", "EnhancedInput", "TIMPush" });
```

### 2. 填写 SDKAppID 与 AppKey

打开 `Source/pushdemo/MyUserWidget.cpp`，把 `CallRegisterPush()` 中的占位值改为 **前置准备** 中获取的实际值：

```cpp
int appID = 0;        // 改为你的 SDKAppID
FString appKey = "";  // 改为你的 AppKey
```

### 3. Android 端配置

在 `Plugins/TIMPush/Source/TIMPush/TIMPush_APL.xml` 中配置：

- `buildGradleAdditions` 中添加推送主包 `com.tencent.timpush:tpush:VERSION` 及按需的厂商包（huawei / xiaomi / oppo / vivo / honor / meizu / fcm）。
- `buildscriptGradleAdditions` 中添加华为 / 荣耀 / FCM 的 classpath。
- `manifestPlaceholders` 中填写 vivo / 荣耀的 APPID / APPKEY。
- 将 `timpush-configs.json` 放到 `Source/ThirdParty/TIMPushLibrary/Android/TIMPush/Assets`，厂商 json 文件放到 `Source/ThirdParty/TIMPushLibrary/Android/TIMPush/`。

### 4. iOS 端配置

- 在 `项目设置 > Additional Plist Data` 中填写 `businessID` 与 `TIMPushAppGroupID`。
- 在 `Config/DefaultEngine.ini` 中开启远程推送：`bEnableRemoteNotificationsSupport=True`。

### 5. 编译运行

打包到真机运行，在 Demo 界面调用 `RegisterPush`，收到推送即说明全流程已打通。

## 工程说明

- `MyUserWidget.cpp`：通过 `PushManager::GetInstance()` 演示 `RegisterPush` / `UnRegisterPush` / `GetRegistrationID` / `SetRegistrationID` / `AddPushListener` / `RemovePushListener` / `ForceUseFCMPushChannel` / `DisablePostNotificationInForeground`。
- 推送监听（`AddPushListener`）需在程序入口注册，回调为 `OnRecvPushMessage` / `OnRevokePushMessage` / `OnNotificationClicked`。

## 参考文档

- [UE 快速入门](https://cloud.tencent.com/document/product/269/123437)
- [UE 厂商配置](https://cloud.tencent.com/document/product/269/123436)
- [UE 客户端 API](https://cloud.tencent.com/document/product/269/123438)

## 联系我们

[zhiliao](https://zhiliao.qq.com/)
