import Flutter
import TIMPush
import tencent_cloud_chat_push
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, TIMPushDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  @objc func offlinePushCertificateID() -> Int32 {
    return TencentCloudChatPushFlutterModal.shared.offlinePushCertificateID()
  }

  @objc func businessID() -> Int32 {
    return TencentCloudChatPushFlutterModal.shared.businessID()
  }

  @objc func applicationGroupID() -> String {
    return TencentCloudChatPushFlutterModal.shared.applicationGroupID()
  }

  @objc func onRemoteNotificationReceived(_ notice: String?) -> Bool {
    TencentCloudChatPushPlugin.shared.tryNotifyDartOnNotificationClickEvent(notice)
    return true
  }
}
