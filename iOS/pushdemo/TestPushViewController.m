//
//  TestPushViewController.m
//  TUIKitDemo
//
//  Created by cologne on 2024/7/4.
//  Copyright © 2024 Tencent. All rights reserved.
//

#import "TestPushViewController.h"

#import <TIMPush/TIMPushManager.h>

#import <Masonry/Masonry.h>
#import <UserNotifications/UserNotifications.h>

static const int kTIMPushSDKAppID = 0;
static NSString * const kTIMPushAppKey = @"";

@interface TestPushViewController ()
@property (nonatomic, strong) UILabel *pushIdLabel;
@property (nonatomic, strong) UILabel *statusLabel;
@property (nonatomic, strong) UIView *statusDotView;
@property (nonatomic, strong) UILabel *sdkAppIdLabel;
@property (nonatomic, strong) UITextField *registrationIDTextField;
@property (nonatomic, strong) UILabel *resultLabel;
@property (nonatomic, assign) BOOL isLastAuthorizationStatusDenied;
@end

@implementation TestPushViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"TIMPush Demo";
    self.view.backgroundColor = [self colorWithHex:0xF5F7FA];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(checkNotificationAuthorizationStatus)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];

    [self setupUI];
    [self updateRegisterStatus:@"未注册" color:[self colorWithHex:0x98A2B3]];
    [self registerPushWithToast:NO];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - UI

- (void)setupUI {
    UIScrollView *scrollView = [[UIScrollView alloc] init];
    scrollView.alwaysBounceVertical = YES;
    [self.view addSubview:scrollView];
    [scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];

    UIView *contentView = [[UIView alloc] init];
    [scrollView addSubview:contentView];
    [contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(scrollView);
        make.width.equalTo(scrollView);
    }];

    UIView *headerView = [[UIView alloc] init];
    headerView.backgroundColor = [self colorWithHex:0x006EFF];
    [contentView addSubview:headerView];
    [headerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.leading.trailing.equalTo(contentView);
    }];

    UILabel *titleLabel = [self labelWithText:@"TIMPush Demo" fontSize:22 textColor:UIColor.whiteColor bold:YES];
    [headerView addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(headerView).offset(24);
        make.leading.trailing.equalTo(headerView).insets(UIEdgeInsetsMake(0, 20, 0, 20));
    }];

    UILabel *subTitleLabel = [self labelWithText:@"启动后自动注册，获取推送 ID 用于发送测试" fontSize:13 textColor:[self colorWithHex:0xD7E8FF] bold:NO];
    [headerView addSubview:subTitleLabel];
    [subTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(titleLabel.mas_bottom).offset(6);
        make.leading.trailing.equalTo(titleLabel);
        make.bottom.equalTo(headerView).offset(-20);
    }];

    UIView *pushIdCard = [self cardView];
    [contentView addSubview:pushIdCard];
    [pushIdCard mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(headerView.mas_bottom).offset(16);
        make.leading.trailing.equalTo(contentView).insets(UIEdgeInsetsMake(0, 16, 0, 16));
    }];

    UILabel *pushIdTitleLabel = [self labelWithText:@"推送 ID" fontSize:16 textColor:[self colorWithHex:0x1F2937] bold:YES];
    [pushIdCard addSubview:pushIdTitleLabel];
    [pushIdTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.leading.trailing.equalTo(pushIdCard).insets(UIEdgeInsetsMake(16, 16, 0, 16));
    }];

    UILabel *descLabel = [self labelWithText:@"将该 ID 填入控制台或服务端接口，即可向当前设备发送测试推送。" fontSize:13 textColor:[self colorWithHex:0x667085] bold:NO];
    descLabel.numberOfLines = 0;
    [pushIdCard addSubview:descLabel];
    [descLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(pushIdTitleLabel.mas_bottom).offset(6);
        make.leading.trailing.equalTo(pushIdTitleLabel);
    }];

    self.pushIdLabel = [self labelWithText:@"正在获取..." fontSize:15 textColor:[self colorWithHex:0x1F2937] bold:NO];
    self.pushIdLabel.numberOfLines = 0;
    self.pushIdLabel.backgroundColor = [self colorWithHex:0xF8FAFC];
    self.pushIdLabel.layer.cornerRadius = 10;
    self.pushIdLabel.layer.masksToBounds = YES;
    [pushIdCard addSubview:self.pushIdLabel];
    [self.pushIdLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(descLabel.mas_bottom).offset(14);
        make.leading.trailing.equalTo(pushIdTitleLabel);
        make.height.mas_greaterThanOrEqualTo(72);
    }];

    self.statusDotView = [[UIView alloc] init];
    self.statusDotView.layer.cornerRadius = 4;
    self.statusDotView.layer.masksToBounds = YES;
    [pushIdCard addSubview:self.statusDotView];
    [self.statusDotView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.pushIdLabel.mas_bottom).offset(14);
        make.leading.equalTo(pushIdTitleLabel);
        make.size.mas_equalTo(CGSizeMake(8, 8));
    }];

    self.statusLabel = [self labelWithText:@"未注册" fontSize:13 textColor:[self colorWithHex:0x98A2B3] bold:NO];
    [pushIdCard addSubview:self.statusLabel];
    [self.statusLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.statusDotView);
        make.leading.equalTo(self.statusDotView.mas_trailing).offset(8);
    }];

    self.sdkAppIdLabel = [self labelWithText:[NSString stringWithFormat:@"SDKAppID: %d", kTIMPushSDKAppID] fontSize:12 textColor:[self colorWithHex:0x667085] bold:NO];
    [pushIdCard addSubview:self.sdkAppIdLabel];
    [self.sdkAppIdLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.statusLabel);
        make.trailing.equalTo(pushIdTitleLabel);
        make.leading.greaterThanOrEqualTo(self.statusLabel.mas_trailing).offset(12);
    }];

    UIButton *copyButton = [self buttonWithTitle:@"复制" primary:YES action:@selector(copyRegistrationIDAction)];
    UIButton *refreshButton = [self buttonWithTitle:@"刷新" primary:NO action:@selector(getRegistrationIDTPushBtnAction)];
    [pushIdCard addSubview:copyButton];
    [pushIdCard addSubview:refreshButton];
    [copyButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.statusLabel.mas_bottom).offset(14);
        make.leading.equalTo(pushIdTitleLabel);
        make.height.mas_equalTo(44);
        make.bottom.equalTo(pushIdCard).offset(-16);
    }];
    [refreshButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.height.width.equalTo(copyButton);
        make.leading.equalTo(copyButton.mas_trailing).offset(12);
        make.trailing.equalTo(pushIdTitleLabel);
    }];
    [copyButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(refreshButton);
    }];

    UIView *actionCard = [self cardView];
    [contentView addSubview:actionCard];
    [actionCard mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(pushIdCard.mas_bottom).offset(12);
        make.leading.trailing.equalTo(pushIdCard);
    }];

    UILabel *actionTitleLabel = [self labelWithText:@"更多操作" fontSize:16 textColor:[self colorWithHex:0x1F2937] bold:YES];
    [actionCard addSubview:actionTitleLabel];
    [actionTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.leading.trailing.equalTo(actionCard).insets(UIEdgeInsetsMake(16, 16, 0, 16));
    }];

    self.registrationIDTextField = [[UITextField alloc] init];
    self.registrationIDTextField.placeholder = @"输入新的推送 ID";
    self.registrationIDTextField.font = [UIFont systemFontOfSize:14];
    self.registrationIDTextField.textColor = [self colorWithHex:0x1F2937];
    self.registrationIDTextField.backgroundColor = UIColor.whiteColor;
    self.registrationIDTextField.layer.cornerRadius = 10;
    self.registrationIDTextField.layer.borderWidth = 1;
    self.registrationIDTextField.layer.borderColor = [self colorWithHex:0xE5E8EF].CGColor;
    self.registrationIDTextField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 12, 1)];
    self.registrationIDTextField.leftViewMode = UITextFieldViewModeAlways;
    [actionCard addSubview:self.registrationIDTextField];
    [self.registrationIDTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(actionTitleLabel.mas_bottom).offset(14);
        make.leading.trailing.equalTo(actionTitleLabel);
        make.height.mas_equalTo(46);
    }];

    UIButton *setButton = [self buttonWithTitle:@"更新推送 ID" primary:NO action:@selector(setRegistrationIDTPushBtnAction)];
    [actionCard addSubview:setButton];
    [setButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.registrationIDTextField.mas_bottom).offset(12);
        make.leading.trailing.equalTo(actionTitleLabel);
        make.height.mas_equalTo(44);
    }];

    UIButton *registerButton = [self buttonWithTitle:@"重新注册" primary:NO action:@selector(registerTPushAction)];
    UIButton *unregisterButton = [self buttonWithTitle:@"注销推送" primary:NO action:@selector(unregisterTPushBtnAction)];
    [actionCard addSubview:registerButton];
    [actionCard addSubview:unregisterButton];
    [registerButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(setButton.mas_bottom).offset(12);
        make.leading.equalTo(actionTitleLabel);
        make.height.mas_equalTo(44);
        make.bottom.equalTo(actionCard).offset(-16);
    }];
    [unregisterButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.height.width.equalTo(registerButton);
        make.leading.equalTo(registerButton.mas_trailing).offset(12);
        make.trailing.equalTo(actionTitleLabel);
    }];
    [registerButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(unregisterButton);
    }];

    UIView *resultCard = [self cardView];
    [contentView addSubview:resultCard];
    [resultCard mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(actionCard.mas_bottom).offset(12);
        make.leading.trailing.equalTo(pushIdCard);
        make.bottom.equalTo(contentView).offset(-20);
    }];

    UILabel *resultTitleLabel = [self labelWithText:@"结果" fontSize:16 textColor:[self colorWithHex:0x1F2937] bold:YES];
    [resultCard addSubview:resultTitleLabel];
    [resultTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.leading.equalTo(resultCard).offset(16);
    }];

    UIButton *clearButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [clearButton setTitle:@"清空" forState:UIControlStateNormal];
    clearButton.titleLabel.font = [UIFont systemFontOfSize:13];
    [clearButton setTitleColor:[self colorWithHex:0x667085] forState:UIControlStateNormal];
    [clearButton addTarget:self action:@selector(clearResultAction) forControlEvents:UIControlEventTouchUpInside];
    [resultCard addSubview:clearButton];
    [clearButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(resultTitleLabel);
        make.trailing.equalTo(resultCard).offset(-16);
        make.width.mas_equalTo(48);
        make.height.mas_equalTo(32);
    }];

    self.resultLabel = [self labelWithText:@"暂无结果" fontSize:13 textColor:[self colorWithHex:0x1F2937] bold:NO];
    self.resultLabel.numberOfLines = 0;
    self.resultLabel.backgroundColor = [self colorWithHex:0xF8FAFC];
    self.resultLabel.layer.cornerRadius = 10;
    self.resultLabel.layer.masksToBounds = YES;
    [resultCard addSubview:self.resultLabel];
    [self.resultLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(resultTitleLabel.mas_bottom).offset(10);
        make.leading.trailing.equalTo(resultCard).insets(UIEdgeInsetsMake(0, 16, 0, 16));
        make.height.mas_greaterThanOrEqualTo(56);
        make.bottom.equalTo(resultCard).offset(-16);
    }];
}

#pragma mark - Actions

- (void)registerTPushAction {
    [self registerPushWithToast:YES];
}

- (void)registerPushWithToast:(BOOL)showToast {
    [self updateRegisterStatus:@"注册中" color:[self colorWithHex:0xFF8A00]];
    [self showResultWithTitle:@"注册推送" detail:@"正在注册..."];
    [TIMPushManager registerPush:kTIMPushSDKAppID appKey:kTIMPushAppKey succ:^(NSData * _Nonnull deviceToken) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (showToast) {
                [self showToast:@"registerPush success"];
            }
            [self updateRegisterStatus:@"已注册" color:[self colorWithHex:0x00A870]];
            [self showResultWithTitle:@"注册成功" detail:@"正在获取推送 ID..."];
            [self refreshRegistrationIDWithResultTitle:@"注册成功"];
        });
    } fail:^(int code, NSString * _Nonnull desc) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (showToast) {
                [self showToast:[NSString stringWithFormat:@"registerPush error code=%d", code]];
            }
            [self updateRegisterStatus:@"注册失败" color:[self colorWithHex:0xE34D59]];
            [self showResultWithTitle:@"注册失败" detail:[NSString stringWithFormat:@"code=%d, msg=%@", code, desc]];
        });
    }];
}

- (void)getRegistrationIDTPushBtnAction {
    [self showResultWithTitle:@"刷新推送 ID" detail:@"正在获取..."];
    [self refreshRegistrationIDWithResultTitle:@"获取成功"];
}

- (void)refreshRegistrationIDWithResultTitle:(NSString *)resultTitle {
    [TIMPushManager getRegistrationID:^(NSString * _Nonnull value) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *pushId = value.length > 0 ? value : @"--";
            self.pushIdLabel.text = pushId;
            [self showResultWithTitle:resultTitle detail:[NSString stringWithFormat:@"推送 ID: %@", pushId]];
        });
    }];
}

- (void)setRegistrationIDTPushBtnAction {
    NSString *registrationID = [self.registrationIDTextField.text stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet];
    if (registrationID.length == 0) {
        [self showToast:@"RegistrationID is empty"];
        [self showResultWithTitle:@"设置失败" detail:@"推送 ID 不能为空"];
        return;
    }

    [self showResultWithTitle:@"设置推送 ID" detail:@"正在设置..."];
    [TIMPushManager setRegistrationID:registrationID callback:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            self.pushIdLabel.text = registrationID;
            [self showToast:@"setRegistrationID success"];
            [self showResultWithTitle:@"设置成功" detail:[NSString stringWithFormat:@"推送 ID: %@", registrationID]];
        });
    }];
}

- (void)unregisterTPushBtnAction {
    [self showResultWithTitle:@"注销推送" detail:@"正在注销..."];
    [TIMPushManager unRegisterPush:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            self.pushIdLabel.text = @"--";
            [self updateRegisterStatus:@"未注册" color:[self colorWithHex:0x98A2B3]];
            [self showToast:@"unRegisterPush success"];
            [self showResultWithTitle:@"注销成功" detail:@"推送注册已注销"];
        });
    } fail:^(int code, NSString * _Nonnull desc) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self showToast:[NSString stringWithFormat:@"unRegisterPush error code=%d", code]];
            [self showResultWithTitle:@"注销失败" detail:[NSString stringWithFormat:@"code=%d, msg=%@", code, desc]];
        });
    }];
}

- (void)copyRegistrationIDAction {
    NSString *pushId = self.pushIdLabel.text ?: @"";
    if (pushId.length == 0 || [pushId isEqualToString:@"--"] || [pushId isEqualToString:@"正在获取..."]) {
        [self showToast:@"Push ID is empty"];
        return;
    }

    [UIPasteboard generalPasteboard].string = pushId;
    [self showToast:@"已复制"];
    [self showResultWithTitle:@"复制成功" detail:@"推送 ID 已复制到剪贴板"];
}

- (void)clearResultAction {
    self.resultLabel.text = @"暂无结果";
}

#pragma mark - Notification Permission

- (void)checkNotificationAuthorizationStatus {
    [[UNUserNotificationCenter currentNotificationCenter] getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings * _Nonnull settings) {
        switch (settings.authorizationStatus) {
            case UNAuthorizationStatusAuthorized:
                if (self.isLastAuthorizationStatusDenied) {
                    [self registerTPushAction];
                }
                break;
            case UNAuthorizationStatusDenied:
                [self promptUserToEnableNotifications];
                self.isLastAuthorizationStatusDenied = YES;
                break;
            default:
                break;
        }
    }];
}

- (void)promptUserToEnableNotifications {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"通知已关闭"
                                                                   message:@"请前往系统设置中开启通知权限"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:nil]];
    [alert addAction:[UIAlertAction actionWithTitle:@"去设置" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        if ([[UIApplication sharedApplication] canOpenURL:url]) {
            [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
        }
    }]];

    dispatch_async(dispatch_get_main_queue(), ^{
        UIViewController *rootViewController = UIApplication.sharedApplication.windows.firstObject.rootViewController;
        [rootViewController presentViewController:alert animated:YES completion:nil];
    });
}

#pragma mark - Helpers

- (UIView *)cardView {
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = UIColor.whiteColor;
    view.layer.cornerRadius = 14;
    view.layer.shadowColor = [UIColor colorWithWhite:0 alpha:0.08].CGColor;
    view.layer.shadowOpacity = 1;
    view.layer.shadowOffset = CGSizeMake(0, 1);
    view.layer.shadowRadius = 3;
    return view;
}

- (UILabel *)labelWithText:(NSString *)text fontSize:(CGFloat)fontSize textColor:(UIColor *)textColor bold:(BOOL)bold {
    UILabel *label = [[UILabel alloc] init];
    label.text = text;
    label.textColor = textColor;
    label.font = bold ? [UIFont boldSystemFontOfSize:fontSize] : [UIFont systemFontOfSize:fontSize];
    return label;
}

- (UIButton *)buttonWithTitle:(NSString *)title primary:(BOOL)primary action:(SEL)action {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:title forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightMedium];
    button.layer.cornerRadius = 10;
    button.layer.masksToBounds = YES;
    button.layer.borderWidth = primary ? 0 : 1;
    button.layer.borderColor = [self colorWithHex:0x006EFF].CGColor;
    button.backgroundColor = primary ? [self colorWithHex:0x006EFF] : UIColor.whiteColor;
    [button setTitleColor:(primary ? UIColor.whiteColor : [self colorWithHex:0x006EFF]) forState:UIControlStateNormal];
    [button addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    return button;
}

- (void)updateRegisterStatus:(NSString *)status color:(UIColor *)color {
    self.statusLabel.text = status;
    self.statusLabel.textColor = color;
    self.statusDotView.backgroundColor = color;
}

- (void)showResultWithTitle:(NSString *)title detail:(NSString *)detail {
    self.resultLabel.text = detail.length > 0 ? [NSString stringWithFormat:@"%@\n%@", title, detail] : title;
}

- (void)showToast:(NSString *)message {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:message preferredStyle:UIAlertControllerStyleAlert];
    [self presentViewController:alert animated:NO completion:nil];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [alert dismissViewControllerAnimated:YES completion:nil];
    });
}

- (UIColor *)colorWithHex:(NSUInteger)hex {
    return [UIColor colorWithRed:((hex >> 16) & 0xFF) / 255.0
                           green:((hex >> 8) & 0xFF) / 255.0
                            blue:(hex & 0xFF) / 255.0
                           alpha:1.0];
}

@end
