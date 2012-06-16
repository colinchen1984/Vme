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
@class SinaWeiBoData;
@class SinaWeiBoComment;
@protocol SinaWeiBoSDKDelegate
@required
- (void) OnWeiBoOauthExpired;
- (void) OnReceiveUserAllWeiBo:(NSArray*) weiBoArray;
- (void) OnRecevieWeiBoUserPersonalInfo:(SinaWeiBoUserPersonalInfo*) userInfo;
- (void) OnReceiveSendWeiBoResult:(SinaWeiBoData*) sendResult;
- (void) OnReceiveCommentForWeiBo:(SinaWeiBoData*) weiBo Comments:(NSMutableArray*)comments;
- (void) OnReceiveCommentReplyResult:(SinaWeiBoComment*)result;
@end

@interface SinaWeiBoUserPersonalInfo : NSObject
@property (strong, nonatomic) NSString* userID;
@property (strong, nonatomic) NSString* userName;
@property (strong, nonatomic) UIImage* avatarImage;
@end

@interface SinaWeiBoData : NSObject
@property (strong, nonatomic) NSArray* annotation;
@property (strong, nonatomic) NSString* text;
@property (strong, nonatomic) NSString* weiBoID;
@property (strong, nonatomic) NSArray* comments;
@property (strong, nonatomic) NSString* userID;
@property (weak, nonatomic) SinaWeiBoUserPersonalInfo* userInfo;
@end

@interface SinaWeiBoComment : NSObject
@property (strong, nonatomic) NSString* text;
@property (strong, nonatomic) NSString* weiBoCommentID;
@property (weak, nonatomic) SinaWeiBoUserPersonalInfo* userInfo;
@property (weak, nonatomic) SinaWeiBoData* weiBoData;
@end

@interface SinaWeiBoSDK : NSObject

- (id) initWithSinaWeiBoOauth:(SinaWeiBoOauth*)oauth;
- (void) requireUserAllWeiBo:(BOOL)sendByThisApp Delegate:(id<SinaWeiBoSDKDelegate>)delegate;
- (void) requireUserPersonalInfo:(id<SinaWeiBoSDKDelegate>)delegate;
- (void) sendWeiBo:(NSString*) text Annotations:(NSString*)annotations Delegate:(id<SinaWeiBoSDKDelegate>)delegate;
- (void) requireWeiBoComment:(SinaWeiBoData*)weiBoData Delegate:(id<SinaWeiBoSDKDelegate>)delegate;
- (void) createCommentForWeiBo:(SinaWeiBoData*) weibo CommentText:(NSString*)commentText Delegate:(id<SinaWeiBoSDKDelegate>)delegate;
- (void) replyComment:(SinaWeiBoComment*) weiBoComment CommentText:(NSString*)commentText Delegate:(id<SinaWeiBoSDKDelegate>)delegate;
@end
