//
//  AppDelegate.m
//  PushDemo
//
//  Created by cologne on 2024/7/11.
//

#import "AppDelegate.h"
#import <TIMPush/TIMPushManager.h>
#import "TestPushViewController.h"
#import "PushConstants.h"
@interface AppDelegate ()<TIMPushDelegate>

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    TestPushViewController *ltabVC = [[TestPushViewController alloc] init];
    self.window.rootViewController = ltabVC;
    [self.window makeKeyAndVisible];
    return YES;
}



#pragma mark - TIMPush
// TIMPush
- (int)businessID {
    return kAPNSBusiId;
}

- (NSString *)applicationGroupID {
    return kTIMPushAppGorupKey;
}



@end
