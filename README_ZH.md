[English](./README.md) | 简体中文

# 推送服务 Push（TIMPush）Demo

## 产品简介
推送服务（Push）是一站式 App 消息推送解决方案，无需自建基础设施即可实现跨平台、高可靠的消息触达。集成 TIMPush 离线推送插件后，App 进程被杀或退到后台时，仍可通过各手机厂商的系统级通道把消息推送到用户的通知栏，唤醒 30 天内的活跃用户。

**适用场景**

- **App 在线 & 离线推送**：在线即时触达，离线可唤醒 30 天内活跃用户。
- **IM 类消息推送**（需集成 IM SDK）：通知栏推送，点击跳转聊天会话。
- **音视频通话呼叫**（需集成音视频通话 SDK）：支持通知栏推送和 VoIP 两种形式。

**离线推送厂商支持**

- **国内**：小米、华为、荣耀、OPPO、vivo、魅族、APNs（含一加、realme、iQOO 等子品牌）。
- **境外**：Google FCM。
- **开发框架**：Android、iOS、Flutter、uni-app、React-Native、微信小程序、HarmonyOS、Unity、Unreal Engine。

> 更多产品介绍请参见官方文档：[推送服务 产品概述](https://cloud.tencent.com/document/product/269/100621)。

## 工程结构
本工程是 TIMPush 离线推送的体验 Demo，按平台拆分为两个独立子工程。各平台的客户端接入步骤、配置项与常见问题排查，请进入对应目录的 README 查看：

| 目录 | 平台 | 接入指引 |
|---|---|---|
| `Android/` | Android（Android Studio 工程） | [Android 接入指引](./Android/README.md) |
| `iOS/` | iOS（Xcode 工程） | [iOS 接入指引](./iOS/README.md) |

## 通用前置准备（控制台）
无论跑通哪个平台，都需要先在控制台完成以下与账号、厂商相关的准备工作。完成后再进入对应平台目录继续客户端配置。

### 步骤1：创建应用
1. 登录即时通信 IM [控制台](https://console.cloud.tencent.com/im)。
 >如果您已有应用，请记录其 SDKAppID 并转到 **步骤2**。
 >
2. 在【应用列表】页，单击【创建应用接入】。
3. 在【创建新应用】对话框中，填写新建应用的信息，单击【确认】。
 应用创建完成后，自动生成一个应用标识 SDKAppID，请记录 SDKAppID 信息。

### 步骤2：获取密钥信息
1. 单击目标应用所在行的【应用配置】，进入应用详情页面。
2. 单击【查看密钥】，拷贝并保存 SDKAppID、密钥（SecretKey）与 AppKey 等信息。
 >请妥善保管密钥信息，谨防泄露。

### 步骤3：开通推送并配置厂商离线通道
1. 在控制台【推送服务】页开通推送能力。
2. 按需配置各手机厂商的离线推送通道（小米 / 华为 / 荣耀 / OPPO / vivo / 魅族 / FCM / APNs），填写从各厂商后台申请到的证书与通道信息。
 >仅需配置您计划支持的厂商，未配置的厂商在 Demo 中无需放置对应文件。
3. 厂商通道配置完成后，控制台会生成推送配置（`timpush-configs.json`）及各厂商所需的服务配置文件。

> 各厂商通道的申请与配置步骤请参考官方文档：[推送服务 文档中心](https://cloud.tencent.com/document/product/269)。

## 平台接入
完成上述控制台准备后，进入对应平台目录按文档继续：

- **Android**：将 SDKAppID / AppKey 等写入工程、放置厂商 services.json，详见 [Android 接入指引](./Android/README.md)。
- **iOS**：执行 `pod install`、配置签名 / Bundle ID / App Group，详见 [iOS 接入指引](./iOS/README.md)。

收到推送即说明全流程已打通。

## 安全提示
本 Demo 在客户端代码中直接配置密钥，仅适合本地跑通 Demo 与功能调试。生产环境请将 UserSig 的计算代码集成到您的服务端，由服务端动态签发，详情参见 [服务端生成 UserSig](https://cloud.tencent.com/document/product/269/32688#GeneratingdynamicUserSig)。
