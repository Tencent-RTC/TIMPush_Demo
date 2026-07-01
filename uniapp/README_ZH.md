[English](./README.md) | 简体中文

# TIMPush uni-app Demo

> 整体介绍与控制台前置准备（创建应用 / 获取密钥 / 开通推送并配置厂商通道）请先阅读上级文档：[../README_ZH.md](../README_ZH.md)。本文仅聚焦 uni-app 端客户端接入。

腾讯云 TIMPush 离线推送 uni-app 端体验 Demo。**本工程是一份未做任何配置的纯净模板**：SDKAppID、AppKey、厂商通道、`nativeResources/` 下的配置文件等**均需你按下文自行配置**后才能编译运行。

## 前提

- 已完成上级文档中的【通用前置准备（控制台）】，拿到 SDKAppID / AppKey，并在控制台开通推送、配置好需要支持的厂商离线通道。
- 本机已安装 HBuilderX（推荐 4.36~4.63 或 4.66 及以上，**避开有 bug 的 4.64 / 4.65**），并准备一台真机（推送需在真机验证）。

## 配置步骤

### 1. 导入推送插件

`TencentCloud-Push` 原生插件已位于 `uni_modules/` 目录。如需更新，可从 [uni-app 腾讯云推送服务插件](https://ext.dcloud.net.cn/plugin?id=20169) 下载并导入 HBuilderX（插件版本 1.1.0 及以上，Harmony 推送需 1.3.0 及以上）。

### 2. 填写 SDKAppID 与 AppKey

打开 `App.vue`，把占位值改为 **前置准备** 中获取的实际值：

```javascript
// setRegistrationID('<#YOUR_USER_ID#>', () => {});  // 可选：与 Chat 登录 userID 打通
registerPush(0, '', (data) => { /* ... */ });        // 将 0 改为你的 SDKAppID，'' 改为你的 AppKey
```

> ⚠️ 切勿在代码仓库中提交真实密钥。若使用 `setRegistrationID(userID)`，必须在 `registerPush` **之前**调用，且 `userID` 须与 Chat 登录使用的完全一致。

### 3. 放置配置文件（`nativeResources/`）

配置文件统一放在与 `uni_modules` 平级的 `nativeResources` 目录下（不存在需手动新建）：

| 平台 | 文件 | 路径 |
|---|---|---|
| Android | `timpush-configs.json` | `nativeResources/android/assets/` |
| Android · 华为 | `agconnect-services.json` | `nativeResources/android/assets/` |
| Android · FCM | `google-services.json` | `nativeResources/android/`（**非** assets） |
| Android · 荣耀 | `mcs-services.json` | `nativeResources/android/`（**非** assets） |
| Android · 荣耀 / vivo | `HONOR_APPID` / `VIVO_APPKEY` / `VIVO_APPID` | `nativeResources/android/manifestPlaceholders.json` |
| iOS | `timpush-configs.json`（含 businessID） | `nativeResources/ios/Resources/` |

厂商依赖（荣耀 / vivo / FCM）需编辑 `uni_modules/TencentCloud-Push/utssdk/app-android/config.json`。

### 4. 制作自定义调试基座并运行

uni-app 离线推送在标准基座下不工作。在 HBuilderX 中为 Android / iOS 制作自定义调试基座后运行到真机，收到推送即说明全流程已打通。

## 工程说明

- `App.vue`：演示 `registerPush` / `getRegistrationID` / `setRegistrationID`，并通过 `addPushListener` 监听 `EVENT.NOTIFICATION_CLICKED` / `EVENT.MESSAGE_RECEIVED` / `EVENT.MESSAGE_REVOKED`。
- 应在 App 启动、用户同意隐私政策后调用 `registerPush`。

## 参考文档

- [uni-app 快速入门](https://cloud.tencent.com/document/product/269/103522)
- [厂商配置索引](https://cloud.tencent.com/document/product/269/100622)
