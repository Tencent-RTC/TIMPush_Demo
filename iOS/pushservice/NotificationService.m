//
//  NotificationService.m
//  pushservice
//
//  Created by cologne on 2024/7/12.
//

#import "NotificationService.h"
#import <TIMPush/TIMPushManager.h>
#import "PushConstants.h"
@interface NotificationService ()

@property (nonatomic, strong) void (^contentHandler)(UNNotificationContent *contentToDeliver);
@property (nonatomic, strong) UNMutableNotificationContent *bestAttemptContent;

@end

@implementation NotificationService

- (void)didReceiveNotificationRequest:(UNNotificationRequest *)request withContentHandler:(void (^)(UNNotificationContent * _Nonnull))contentHandler {
    self.contentHandler = contentHandler;

    //appGroup identifies the APP Group shared between the current main APP and Extension. The App Groups capability needs to be configured in the Capability of the main APP.
    //The format is group + [main bundleID] + key
    //Such as group.com.tencent.im.pushkey
    NSString * appGroupID = kTIMPushAppGorupKey;
    
    __weak typeof(self) weakSelf = self;
    [TIMPushManager handleNotificationServiceRequest:request appGroupID:appGroupID callback:^(UNNotificationContent *content) {
        weakSelf.bestAttemptContent = [content mutableCopy];
        // Modify the notification content here...
        // self.bestAttemptContent.title = [NSString stringWithFormat:@"%@ [modified]", self.bestAttemptContent.title];
        
        NSString * attachmentPath = self.bestAttemptContent.userInfo[@"image"];
         //if exist
         if (attachmentPath) {
           //download
           NSURL *fileURL = [NSURL URLWithString:attachmentPath];
           [self downloadAndSave:fileURL handler:^(NSString *localPath) {
               if (localPath) {
               UNNotificationAttachment * attachment = [UNNotificationAttachment attachmentWithIdentifier:@"myAttachment" URL:[NSURL fileURLWithPath:localPath] options:nil error:nil];
               weakSelf.bestAttemptContent.attachments = @[attachment];
               weakSelf.contentHandler(weakSelf.bestAttemptContent);
             }
           }];
         }
         else {
             weakSelf.contentHandler(weakSelf.bestAttemptContent);
         }

    }];
}

- (void)downloadAndSave:(NSURL *)fileURL handler:(void (^)(NSString *))handler {NSURLSession * session = [NSURLSession sharedSession];
  NSURLSessionDownloadTask *task = [session downloadTaskWithURL:fileURL completionHandler:^(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error) {
    NSString *localPath = nil;
      if (!error) {
          NSString* localURL = [NSString stringWithFormat:@"%@/%@", NSTemporaryDirectory(), fileURL.lastPathComponent];
          [[NSFileManager defaultManager] moveItemAtPath:location.path toPath:localURL error:nil];
          localPath = localURL;
      }
      handler(localPath);
  }];
  [task resume];
  
}

- (void)serviceExtensionTimeWillExpire {
    // Called just before the extension will be terminated by the system.
    // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
    self.contentHandler(self.bestAttemptContent);
}

@end
