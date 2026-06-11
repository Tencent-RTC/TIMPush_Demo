[English](./README.md) | 简体中文

# TIMPush Android Demo

> 整体介绍与控制台前置准备（创建应用 / 获取密钥 / 开通推送并配置厂商通道）请先阅读上级文档：[../README_ZH.md](../README_ZH.md)。本文仅聚焦 Android 端客户端接入。

腾讯云 TIMPush 离线推送 Android 端体验 Demo。**本工程是一份未做任何配置的纯净模板**：包名、SDKAppID、AppKey、厂商推送通道、`services.json`、`timpush-configs.json` 等**均需你按下文自行配置**后才能编译运行。

## 前提

- 已完成上级文档中的【通用前置准备（控制台）】，拿到 SDKAppID / AppKey，并在控制台开通推送、配置好需要支持的厂商离线通道。
- 本机已安装 Android Studio，并准备一台 Android 真机（推送需在真机验证）。

## 配置步骤

### 1. 设置应用包名

`app/build.gradle` 中的 `namespace` / `applicationId` 默认是占位符 `"xxxxx"`，改为你自己的包名（须与控制台及各厂商后台登记的包名一致）：

```groovy
android {
    defaultConfig {
        namespace "com.your.package"
        applicationId "com.your.package"
    }
}
```

### 2. 填写 SDKAppID 与 AppKey

打开 `app/src/main/java/com/tencent/qcloud/tim/tuikit/MainActivity.java`，把占位值改为 **前置准备** 中获取的实际值：

```java
public static final int SDK_APP_ID = 0;   // 改为你的 SDKAppID
public static final String APP_KEY = "";  // 改为你的 AppKey
```

### 3. 启用需要的厂商推送通道

本工程默认只集成了 TIMPush 基础能力，各厂商通道均以**注释**形式预留。按你要支持的厂商取消对应注释并补充配置：

**a. 仓库与插件**

- 根 `build.gradle`：取消对应厂商的 maven 仓库与 classpath 注释（如华为、荣耀）。
- `app/build.gradle`：取消对应厂商的 `apply plugin` 与依赖项注释（小米 / 华为 / 荣耀 / OPPO / vivo / 魅族 / FCM）。

**b. vivo / 荣耀 占位参数**

在 `app/build.gradle` 的 `manifestPlaceholders` 中填入对应厂商参数（未启用的厂商留空即可）：

```groovy
manifestPlaceholders = [
    "VIVO_APPKEY" : "你的 vivo AppKey",
    "VIVO_APPID"  : "你的 vivo AppID",
    "HONOR_APPID" : "你的荣耀 AppID"
]
```

**c. 厂商 `services.json`（放到 `app/` 目录）**

从对应厂商后台下载并放入工程 `app/` 目录：

| 启用条件 | 文件名 | 下载入口 |
|---|---|---|
| 启用了华为推送 | `agconnect-services.json` | https://developer.huawei.com/consumer/cn/service/josp/agc/index.html |
| 启用了 FCM 推送 | `google-services.json` | https://console.firebase.google.com/ |
| 启用了荣耀推送 | `mcs-services.json` | https://developer.honor.com/ |

> 未启用的厂商**无需**放置对应文件。

### 4. 配置 `timpush-configs.json`

在 `app/src/main/assets/` 目录下新建 `timpush-configs.json`，按官方文档格式填入各厂商的推送配置（厂商 AppID / AppKey / AppSecret 等）。配置字段与示例请参见 [Android 厂商配置](https://cloud.tencent.com/document/product/269/100623)。

### 5. 编译运行

用 Android Studio 打开 `Android/` 目录，连接真机直接 Run。注册成功后界面会显示 RegistrationID，收到推送即说明全流程已打通。

## 工程说明

- `MainActivity.java`：演示 `registerPush` / `unRegisterPush` / `getRegistrationID` / `setRegistrationID` 的调用。
- `DemoApplication.java`：演示推送消息监听与通知点击回调（`TIMPushListener`）。

## 参考文档

- [Android 快速入门](https://cloud.tencent.com/document/product/269/100626)
- [Android 厂商配置](https://cloud.tencent.com/document/product/269/100623)
- [厂商配置索引](https://cloud.tencent.com/document/product/269/100622)
