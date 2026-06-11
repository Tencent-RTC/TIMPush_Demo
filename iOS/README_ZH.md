[English](./README.md) | 简体中文

# TIMPush iOS Demo

> 整体介绍与控制台前置准备（创建应用 / 获取密钥 / 开通推送并配置 APNs 通道）请先阅读上级文档：[../README_ZH.md](../README_ZH.md)。本文仅聚焦 iOS 端客户端接入。

腾讯云 TIMPush 离线推送 iOS 端体验 Demo。**本工程是一份未做任何配置的纯净模板**：SDKAppID、AppKey、APNs BusinessID、签名、Bundle ID、App Group、`pod install` 等**均需你按下文自行配置**后才能编译运行。

## 前提

- 已完成上级文档中的【通用前置准备（控制台）】，拿到 SDKAppID / AppKey，并在控制台配置好 APNs 推送证书与 BusinessID。
- macOS + Xcode，已安装 CocoaPods，并准备一台 iOS 真机（模拟器不支持 APNs，无法验证推送）。

## 配置步骤

### 1. 安装依赖

```bash
cd iOS
pod install
```

> 未安装 CocoaPods 请先 `sudo gem install cocoapods`。完成后会生成 `Pods/` 与 `Podfile.lock`。

### 2. 用 Xcode 打开 `pushdemo.xcworkspace`

> ⚠️ 必须打开 `.xcworkspace`，**不要**打开 `.xcodeproj`，否则找不到 Pod 依赖。

### 3. 填写 SDKAppID 与 AppKey

打开 `pushdemo/TestPushViewController.m`，把占位值改为 **前置准备** 中获取的实际值：

```objc
static const int kTIMPushSDKAppID = 0;       // 改为你的 SDKAppID
static NSString * const kTIMPushAppKey = @"";// 改为你的 AppKey
```

### 4. 填写 APNs BusinessID 与 App Group

打开 `pushdemo/PushConstants.h`，修改 DEBUG 分支的占位值：

```objc
#ifdef DEBUG
#define kAPNSBusiId 11111             // 改为控制台 APNs 推送通道的 BusinessID
#define kTIMPushAppGorupKey @"xxxx"   // 改为你的 App Group Identifier（见步骤 5.2）
```

> `BUILDAPPSTORE` / 企业证书分支仅 Release 构建生效，普通体验保持默认即可。

### 5. 配置签名 / Bundle ID / App Group

#### 5.1 配置签名与 Bundle ID

对 `pushdemo` 和 `pushservice` 两个 target 都做：`Signing & Capabilities` →

- `Team`：选你自己的 Apple Developer Team。
- `Bundle Identifier`：改为你自己的 Bundle ID。
  - `pushdemo` 主 App：例 `com.your-company.timpush.demo`
  - `pushservice` 推送扩展：**必须**是主 App Bundle ID 后接 `.pushservice`，例 `com.your-company.timpush.demo.pushservice`

#### 5.2 配置 App Group

App Group 用于让主 App 与 `pushservice` 推送扩展共享数据，TIMPush 必需。

1. **在 Apple Developer 后台创建**：登录 https://developer.apple.com/account → Identifiers，切到 `App Groups` 点 `+` 新建，Identifier 必须以 `group.` 开头，例 `group.com.your-company.timpush.demo`。
2. **在 Xcode 勾选**：对 `pushdemo` 和 `pushservice` 两个 target，`Signing & Capabilities` → `+ Capability` 添加 `App Groups`，并勾选上一步创建的 `group.xxx`。若勾不上，点刷新按钮让 Xcode 重新生成 profile。
3. **填回 `PushConstants.h`**：把 DEBUG 分支的 `kTIMPushAppGorupKey` 改为该 `group.xxx`（即步骤 4）。

### 6. 真机 Run

iOS 推送只能在**真机**上验证。连接真机，选 `pushdemo` scheme，Run。收到推送说明全流程已打通。

## 常见问题

**Q：编译报 `'TIMPushManager.h' file not found`？**
跑了 `pod install` 吗？打开的是 `.xcworkspace` 还是 `.xcodeproj`？必须是前者。

**Q：真机 Run 起来了，但没收到推送？**
按以下顺序排查：
1. `Signing & Capabilities` 的 `Push Notifications` capability 是否启用？
2. App Group 是否在 Apple Developer / Xcode（pushdemo + pushservice 两个 target）/ `PushConstants.h`（DEBUG 分支）三处**完全一致**？
3. 真机上是否同意了通知权限？
4. 是否拿到了 RegistrationID？（看 `TestPushViewController` 的界面与日志）

**Q：`Provisioning profile doesn't include the com.apple.security.application-groups entitlement`？**
Xcode 里 App Groups capability 没勾选成功。重做步骤 5.2，必要时点刷新按钮重新生成 profile。

## 参考文档

- [iOS 接入指引（文档中心）](https://cloud.tencent.com/document/product/269)
- [厂商配置索引](https://cloud.tencent.com/document/product/269/100622)
