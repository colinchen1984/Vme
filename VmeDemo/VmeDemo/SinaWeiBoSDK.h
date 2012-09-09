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
@class TudouVideoInfo;

typedef enum  
{
	SINA_WEIBO_REQUEST_USER_PERSONAL_INFO = 0,
	SINA_WEIBO_SEND_WEIBO = 1,
	SINA_WEIBO_GET_WEIBO_COMMENT = 2,
	SINA_WEIBO_GET_USER_ALL_WEIBO = 3,
	SINA_WEIBO_CREATE_COMMENT = 4,
	SINA_WEIBO_REPLY_COMMENT = 5,
	SINA_WEIBO_GET_BATCH_WEIBO_COMMENT = 6,
	
	SINA_WEIBO_OPERATION_TYPE,
	
} SINA_WEIBO_REQUEST_OPERATION_TYPE;

@protocol SinaWeiBoSDKDelegate <NSObject>
- (void) OnWeiBoOauthExpired;
- (void) OnReceiveUserAllWeiBo:(NSArray*) weiBoArray;
- (void) OnRecevieWeiBoUserPersonalInfo:(SinaWeiBoUserPersonalInfo*) userInfo;
- (void) OnReceiveSendWeiBoResult:(SinaWeiBoData*) sendResult;
- (void) OnReceiveCommentForWeiBo:(SinaWeiBoData*) weiBo Comments:(NSArray*)comments;
- (void) OnReceiveCommentReplyResult:(SinaWeiBoComment*)result;
- (void) OnRateLimitate;
- (void) OnError:(NSString*)data;
@end

@interface SinaWeiBoUserPersonalInfo : NSObject
@property (strong, nonatomic) NSString* userID;
@property (strong, nonatomic) NSString* userName;
@property (strong, nonatomic) UIImage* avatarImage;
@property (strong, nonatomic) NSDate* createTime;
@end

@interface SinaWeiBoData : NSObject
@property (strong, nonatomic) NSArray* annotation;
@property (strong, nonatomic) NSString* text;
@property (strong, nonatomic) NSString* weiBoID;
@property (strong, nonatomic) NSArray* comments;
@property (strong, nonatomic) NSString* userID;
@property (strong, nonatomic) NSDate* createTime;
@property (weak, nonatomic) SinaWeiBoUserPersonalInfo* userInfo;
@end

@interface SinaWeiBoComment : NSObject
@property (strong, nonatomic) NSString* text;
@property (strong, nonatomic) NSString* weiBoCommentID;
@property (strong, nonatomic) NSDate* createTime;
@property (weak, nonatomic) SinaWeiBoUserPersonalInfo* userInfo;
@property (weak, nonatomic) SinaWeiBoData* weiBoData;
@end

@interface SinaWeiBoSDK : NSObject

- (id) initWithSinaWeiBoOauth:(SinaWeiBoOauth*)oauth;
- (void) requireUserAllWeiBo:(BOOL)sendByThisApp UserInfo:(BOOL)userInfo Delegate:(id<SinaWeiBoSDKDelegate>)delegate;
- (void) requireUserPersonalInfo:(id<SinaWeiBoSDKDelegate>)delegate;
- (void) sendWeiBo:(NSString*) text VideoInfo:(TudouVideoInfo*)videoInfo Delegate:(id<SinaWeiBoSDKDelegate>)delegate;
- (void) sendWeiBo:(NSString*) text Annotations:(NSString*)annotations Delegate:(id<SinaWeiBoSDKDelegate>)delegate;
- (void) requireWeiBoComment:(SinaWeiBoData*)weiBoData Delegate:(id<SinaWeiBoSDKDelegate>)delegate;
- (void) requireBatchWeiBoComment:(NSArray*)weiBoData Delegate:(id<SinaWeiBoSDKDelegate>)delegate;
- (void) createCommentForWeiBo:(SinaWeiBoData*) weibo CommentText:(NSString*)commentText Delegate:(id<SinaWeiBoSDKDelegate>)delegate;
- (void) replyComment:(SinaWeiBoComment*) weiBoComment CommentText:(NSString*)commentText Delegate:(id<SinaWeiBoSDKDelegate>)delegate;
@end
