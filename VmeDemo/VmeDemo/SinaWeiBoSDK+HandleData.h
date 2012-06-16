//
//  SinaWeiBoSDK+HandleData.h
//  VmeDemo
//
//  Created by user on 12-5-31.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "SinaWeiBoSDK.h"

@interface SinaWeiBoSDK (HandleData)
- (void) handlerUserPersonalInfo:(NSDictionary*) dataDic Delegate:(id<SinaWeiBoSDKDelegate>)delegate;
- (void) handlerSendWeiBoData:(NSDictionary*) dataDic Delegate:(id<SinaWeiBoSDKDelegate>)delegate;
- (void) handlerGetWeiBoCommentsData:(NSDictionary*) dataDic Delegate:(id<SinaWeiBoSDKDelegate>)delegate;
- (void) handlerGetUserAllWeiBoData:(NSDictionary*) dataDic Delegate:(id<SinaWeiBoSDKDelegate>)delegate;
- (void) handlerCreateWeiBoComent:(NSDictionary*) dataDic Delegate:(id<SinaWeiBoSDKDelegate>)delegate;
- (void) handlerReplyCommentData:(NSDictionary*) dataDic Delegate:(id<SinaWeiBoSDKDelegate>)delegate;
@end
