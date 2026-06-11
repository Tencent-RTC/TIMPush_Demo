//
//  PushConstants.h
//  PushDemo
//
//  Created by cologne on 2024/7/12.
//

#ifndef PushConstants_h
#define PushConstants_h

#ifdef DEBUG
#define kAPNSBusiId 11111 // 本地调试
#else
#if BUILDAPPSTORE
#define kAPNSBusiId 11111 // 蓝盾appstore编译，用 keystore 申请的蓝盾发布证书
#define kAPNSBusiId 11111 // 蓝盾企业证书编译，用 keystore 申请的蓝盾发布证书
#endif
#endif

#ifdef DEBUG
#define kTIMPushAppGorupKey @"xxxx" // 本地调试 key
#else
#if BUILDAPPSTORE
#define kTIMPushAppGorupKey @"xxxx" // 蓝盾appstore编译，key
#else
#define kTIMPushAppGorupKey @"xxxx" // 蓝盾企业证书编译
#endif
#endif

#endif /* PushConstants_h */
