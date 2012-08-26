//
//  TuDouSDK.h
//  VmeDemo
//
//  Created by user on 12-5-8.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WebRequest.h"


@class TuDouUserPersonalInfo;
@class TudouVideoInfo;
typedef enum
{
	TUDOU_SDK_REQUEST_USER_PERSONAL_INFO = 0,
	TUDOU_SDK_REQUEST_USER_VIDEO_INFO  = 1,
	TUDOU_SDK_REQUEST_UPLOAD_ADDRESS = 2,
	TUDOU_SDK_REQUEST_CHECK_USER_NAME_PASS = 3,
	
} TUDOU_SDK_REQUEST_OPERATION_TYPE;
@protocol TuDouSDKDelegate

- (void) OnReceiveUserPersonalInfo:(TuDouUserPersonalInfo*) userPersonalInfo;
- (void) OnReceiveUserVideoInfo:(int)pageNo PageSize:(int)PageSize PageCount:(int)pageCount VideoCount:(int)videoCount;
- (void) OnReceiveVideoInfo:(TudouVideoInfo*) videoInfo;
- (void) OnReceiveError:(TUDOU_SDK_REQUEST_OPERATION_TYPE)operationType;
- (void) OnReceiveCheckUserNamePass:(BOOL)result;
@end

@interface TuDouUserPersonalInfo : NSObject
@property (copy, nonatomic) NSString* userNickName;
@property (strong, nonatomic) UIImage* userAvatarImage;
@end

@interface TudouVideoInfo : NSObject

@property (nonatomic) NSString* itemId;					//视频ID	
@property (nonatomic) NSString* itemCode;				//视频编码11位字符型编码,视频唯一标识
@property (copy, nonatomic) NSString* title;			//视频标题	
@property (strong, nonatomic) NSString* tags;			//视频标签字符串,多个标签之间用逗号','分隔
@property (copy, nonatomic) NSString* description;		//视频描述	
@property (weak, nonatomic) UIImage* pic;				//视频截图	
@property (strong, nonatomic) NSString* bigPicURL;		//高质量视频截图url地址
@property (weak, nonatomic) UIImage* bigPic;			//高质量视频截图
@property (copy, nonatomic) NSString* itemUrl;			//播放页URL
@end

@interface TuDouSDK : NSObject<WebRequestDelegate>

- (id) initUserName:(NSString*) userName Pass:(NSString*)pass;

- (void) requireUserPersonalInfo:(id<TuDouSDKDelegate>)delegate;

- (void) requireUserVideoInfo:(id<TuDouSDKDelegate>)delegate PageNo:(NSInteger)pageNo;

- (void) setUserName:(NSString*)userName Pass:(NSString*)pass;

- (void) requireUploadVideo:(NSString*)filepath Delegate:(id<TuDouSDKDelegate>)delegate;

- (void) checkUserName:(NSString*)username Pass:(NSString*)pass Delegate:(id<TuDouSDKDelegate>)delegate;
@end

