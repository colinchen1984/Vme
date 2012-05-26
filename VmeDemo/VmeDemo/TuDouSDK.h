//
//  TuDouSDK.h
//  VmeDemo
//
//  Created by user on 12-5-8.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WebRequest.h"

typedef enum  
{
	TUDOU_SDK_REQUEST_USER_PERSONAL_INFO = 0,
	TUDOU_SDK_REQUEST_USER_VIDEO_INFO  = 1,
	
} TUDOU_SDK_REQUEST_OPERATION_TYPE;

@class OauthEngine;
@class TuDouUserPersonalInfo;
@class TudouVideoInfo;
@protocol TuDouSDKDelegate

- (void) OnReceiveUserPersonalInfo:(TuDouUserPersonalInfo*) userPersonalInfo;
- (void) OnReceiveUserVideoInfo:(int)pageNo PageSize:(int)PageSize PageCount:(int)pageCount VideoCount:(int)videoCount;
- (void) OnReceiveVideoInfo:(TudouVideoInfo*) videoInfo;
- (void) OnReceiveError:(TUDOU_SDK_REQUEST_OPERATION_TYPE)operationType;
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
@property (strong, nonatomic) UIImage* pic;				//视频截图	
@property (strong, nonatomic) NSString* bigPicURL;		//高质量视频截图url地址
@property (strong, nonatomic) UIImage* bigPic;			//高质量视频截图
@property (copy, nonatomic) NSString* itemUrl;			//播放页URL
@end

@interface TuDouSDK : NSObject<WebRequestDelegate>

- (id) initWithOauthEngine:(OauthEngine*) engine UserName:(NSString*) userName;

- (void) requireUserPersonalInfo:(id<TuDouSDKDelegate>)delegate UserName:(NSString*)userName;

- (void) requireUserVideoInfo:(id<TuDouSDKDelegate>)delegate UserName:(NSString*)userName PageNo:(NSInteger)pageNo;

@end

