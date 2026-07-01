[English](./README.md) | 简体中文

# TIMPush HarmonyOS Demo

> 整体介绍与控制台前置准备（创建应用 / 获取密钥 / 开通推送并配置鸿蒙通道）请先阅读上级文档：[../README_ZH.md](../README_ZH.md)。本文仅聚焦 HarmonyOS 端客户端接入。

腾讯云 TIMPush 离线推送 HarmonyOS 端体验 Demo。**本工程是一份未做任何配置的纯净模板**：`bundleName`、SDKAppID、AppKey、鸿蒙（华为）推送通道等**均需你按下文自行配置**后才能编译运行。

## 前提

- 已完成上级文档中的【通用前置准备（控制台）】，拿到 SDKAppID / AppKey，并在控制台开通推送、配置好鸿蒙离线通道。
- 本机已安装 DevEco Studio（compatible SDK 5.0.0(12)，target SDK 6.0.0(20)），并准备一台 HarmonyOS 真机（推送需在真机验证）。

## 工程结构

```text
Harmony/
├── AppScope/                 # App 配置，bundleName = com.tencentcloud.imdemo
├── entry/                    # entry 模块（PushDemo 主体）
│   ├── oh-package.json5      # 依赖 @tencentcloud/imsdk、@tencentcloud/timpush
│   └── src/main/
│       ├── module.json5      # 声明 INTERNET / GET_NETWORK_INFO 权限
│       └── ets/
│           ├── entryability/EntryAbility.ets   # initSDK + registerPush + 推送监听
│           └── pages/Index.ets                 # Demo 界面
├── build-profile.json5
├── hvigorfile.ts
└── oh-package.json5
```

## 配置步骤

### 1. 安装依赖

用 DevEco Studio 打开 `Harmony/` 目录，会自动同步 `ohpm` 依赖。或使用命令行：

```bash
cd Harmony
ohpm install
```

依赖从 ohpm 仓库拉取（见 `entry/oh-package.json5`）：

```json5
"dependencies": {
    "@tencentcloud/imsdk": "^9.0.7652",
    "@tencentcloud/timpush": "^8.7.7203"
}
```

### 2. 设置应用 bundleName

`AppScope/app.json5` 中的 `bundleName` 默认是 `"com.tencentcloud.imdemo"`，改为你自己的 bundleName（须与控制台及 AppGallery Connect 登记的一致）：

```json5
{
  "app": {
    "bundleName": "com.your.package"
  }
}
```

### 3. 填写 SDKAppID 与 AppKey

占位值出现在**两个**文件中，都要改为 **前置准备** 中获取的实际值：

- `entry/src/main/ets/entryability/EntryAbility.ets`
- `entry/src/main/ets/pages/Index.ets`

```typescript
const SDK_APP_ID: number = 0;   // 改为你的 SDKAppID
const APP_KEY: string = '';     // 改为你的 AppKey
```

### 4. 配置鸿蒙推送通道

鸿蒙离线推送依赖 HarmonyOS（华为）Push Kit：

1. 在 [AppGallery Connect](https://developer.huawei.com/consumer/cn/service/josp/agc/index.html) 注册应用并开通 **Push Kit**，`bundleName` 与步骤 2 保持一致。
2. 在 IM 控制台配置鸿蒙离线推送通道（填入从 AGC 申请到的证书 / 通道信息）。
3. 若接入需要，按官方文档指引把从 AGC 下载的 `agconnect-services.json` 放入工程。

> 配置字段与详细步骤请参见 [厂商配置索引](https://cloud.tencent.com/document/product/269/100622)。

### 5. 编译运行

连接 HarmonyOS 真机，选择 `entry` 模块直接 Run。注册成功后界面会显示 RegistrationID，收到推送即说明全流程已打通。

## 工程说明

- `EntryAbility.ets`：`onCreate()` 中先注册推送监听（`addPushListener`），再 `initSDK`，最后 `registerPush`；`onDestroy()` 调用 `removePushListener`。
- `Index.ets`：演示 `registerPush` / `unRegisterPush` / `getRegistrationID` / `setRegistrationID` 的调用（注册 / 注销 / 获取 / 设置 / 重置 RegistrationID）。
- `module.json5`：声明 `ohos.permission.INTERNET` 与 `ohos.permission.GET_NETWORK_INFO` 权限。

> 注意：`setRegistrationID` 必须在 `registerPush` **之前**调用才会生效。

## 参考文档

- [HarmonyOS 接入指引（文档中心）](https://cloud.tencent.com/document/product/269)
- [厂商配置索引](https://cloud.tencent.com/document/product/269/100622)
