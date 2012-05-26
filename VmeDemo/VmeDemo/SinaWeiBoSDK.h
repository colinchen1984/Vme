//
//  SinaWeiBoSDK.h
//  VmeDemo
//
//  Created by user on 12-5-24.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
@class SinaWeiBoOauth;
@class SinaWeiBoUserPersonalInfo;
@class SinaWeiBOSendWeiBoResult;
@protocol SinaWeiBoSDKDelegate
- (void) OnWeiBoOauthExpired;
- (void) OnRecevieWeiBoUserPersonalInfo:(SinaWeiBoUserPersonalInfo*) userInfo;
- (void) OnReceiveSendWeiBoResult:(SinaWeiBOSendWeiBoResult*) sendResult;
@end

@interface SinaWeiBoUserPersonalInfo : NSObject
@property (strong, nonatomic) NSString* userName;

@end

@interface SinaWeiBoSDK : NSObject

- (id) initWithSinaWeiBoOauth:(SinaWeiBoOauth*)oauth;
- (void) requireUserPersonalInfo:(id<SinaWeiBoSDKDelegate>)delegate;
- (void) sendWeiBo:(NSString*) text Annotations:(NSString*)annotations Delegate:(id<SinaWeiBoSDKDelegate>)delegate;
@end
