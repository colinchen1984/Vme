//
//  TuDouSDK.m
//  VmeDemo
//
//  Created by user on 12-5-8.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "TuDouSDK.h"
#import "SBJSON.h"
#import "ImageManager.h"
#import "GTMBase64.h"
@interface TuDouSDK()
@property (strong, nonatomic) NSMutableSet* usingConnection;
@property (strong, nonatomic) NSMutableArray* freeConnection;
@property (strong, nonatomic) NSMutableSet* personalInfoRequest;
@property (strong, nonatomic) NSMutableSet* videoRequest;
@property (strong, nonatomic) NSString* userName;
@property (strong, nonatomic) NSString* athorize;
- (void) finishUserPersonalInfoRequest:(TuDouUserPersonalInfo*)userInfo;

- (void) finishVideoInfoRequest:(TudouVideoInfo*)videoInfo;
- (void) failToLoadVideoInfo:(TudouVideoInfo*) videoInfo URL:(NSString*) url;
@end

@interface TudouWeiRequest : WebRequest
{
@public
	TUDOU_SDK_REQUEST_OPERATION_TYPE operation;
};
@property (weak, nonatomic) id<TuDouSDKDelegate> tudouSDKDeletage;
@end


@implementation TudouWeiRequest
@synthesize tudouSDKDeletage = _tudouSDKDeletage;
- (void) cancelRequest
{
	[super cancelRequest];
	_tudouSDKDeletage = nil;
}
@end

@interface TuDouUserPersonalInfo()
@property (weak, nonatomic) id<TuDouSDKDelegate> delegate;
@property (weak, nonatomic) TuDouSDK* sdk;
@end

@implementation TuDouUserPersonalInfo
@synthesize userAvatarImage = _userAvatarImage;
@synthesize userNickName = _userNickName;
@synthesize delegate = _delegate;
@synthesize sdk = _sdk;

- (void) OnReceiveImage:(UIImage*)image ImageUrl:(NSString *)imageUrl
{
	_userAvatarImage = image;
	[_delegate OnReceiveUserPersonalInfo:self];
	[_sdk finishUserPersonalInfoRequest:self];
}

@end

@interface TudouVideoInfo()
@property (weak, nonatomic) id<TuDouSDKDelegate> delegate;
@property (weak, nonatomic) TuDouSDK* sdk;
@end

@implementation TudouVideoInfo

@synthesize itemId = _itemId;					//视频ID	
@synthesize itemCode = _itemCode;				//视频编码11位字符型编码,视频唯一标识
@synthesize title = _title;						//视频标题	
@synthesize tags = _tags;						//视频标签字符串,多个标签之间用逗号','分隔
@synthesize description = _description;			//视频描述	
@synthesize pic = _pic;							//视频截图	
@synthesize bigPicURL = _bigPicURL;				//高质量视频截图url地址
@synthesize bigPic = _bigPic;					//高质量视频截图
@synthesize itemUrl = _itemUrl;					//播放页URL
@synthesize delegate = _delegate;				
@synthesize sdk = _sdk;

- (void) OnReceiveImage:(UIImage*)image ImageUrl:(NSString *)imageUrl
{
	if(NO == [_bigPicURL isEqualToString:imageUrl])
	{
		_pic = image;
		[_delegate OnReceiveVideoInfo:self];
		[_sdk finishVideoInfoRequest:self];
	}
	else 
	{
		_bigPic = image;
	}
	
}

- (void) OnReceiveError:(NSString*)imageURL
{
	[_sdk failToLoadVideoInfo:self URL:imageURL];
}
@end


//appKey%@ userName%@
#define oauthAppKey @"f3db9710183157f4"
#define API4TUDOU2GETUSERPERSONALINFO @"http://api.tudou.com/v3/gw?method=user.info.get&appKey=%@&format=json&user=%@"
//appKey%@ userName%@ pageNo%d
#define API4TUDOU2GETUSERVIDEOINFO @"http://api.tudou.com/v3/gw?method=user.item.get&appKey=%@&format=&user=%@&pageNo=%d&pageSize=10"

@implementation TuDouSDK
@synthesize freeConnection = _freeConnection;
@synthesize usingConnection = _usingConnection;
@synthesize personalInfoRequest = _personalInfoRequest;
@synthesize videoRequest = _videoRequest;
@synthesize userName = _userName;
@synthesize athorize = _athorize;

#pragma mark - life cycle
- (id) initUserName:(NSString*) userName Pass:(NSString*)pass
{
	self = [super init];
	if (nil == self)
	{
		return nil;
	}
	_userName = userName;
	NSString* tempStr = [NSString stringWithFormat:@"%@:%@", userName, pass];
	_athorize = [GTMBase64 stringByEncodingBytes:[tempStr UTF8String] length:[tempStr length]];
	_freeConnection = [[NSMutableArray alloc] init];
	_usingConnection = [[NSMutableSet alloc] init];
	_personalInfoRequest = [[NSMutableSet alloc] init];
	_videoRequest = [[NSMutableSet alloc] init];
	return self;
}

#pragma  mark - tudou api
- (void) requireUserPersonalInfo:(id<TuDouSDKDelegate>) delegate
{
	TudouWeiRequest* request = [self getFreeRequest];	
	request->operation = TUDOU_SDK_REQUEST_USER_PERSONAL_INFO; 
	[request setDelegate:self];
	[request setTudouSDKDeletage:delegate];
	NSString* apiUrl = [[NSString alloc] initWithFormat:API4TUDOU2GETUSERPERSONALINFO, oauthAppKey, _userName];
	[request postUrlRequest:apiUrl];
}

- (void) requireUserVideoInfo:(id<TuDouSDKDelegate>)delegate PageNo:(NSInteger)pageNo
{
	TudouWeiRequest* request = [self getFreeRequest];	
	request->operation = TUDOU_SDK_REQUEST_USER_VIDEO_INFO; 
	[request setDelegate:self];
	[request setTudouSDKDeletage:delegate];
	NSString* apiUrl = [[NSString alloc] initWithFormat:API4TUDOU2GETUSERVIDEOINFO, oauthAppKey, _userName, pageNo];
	[request postUrlRequest:apiUrl];

}

#pragma mark - private interface 
- (void) finishUserPersonalInfoRequest:(TuDouUserPersonalInfo*)userInfo
{
	[_personalInfoRequest removeObject:userInfo];
}

- (void) finishVideoInfoRequest:(TudouVideoInfo*)videoInfo
{
	[_videoRequest removeObject:videoInfo];
}

- (void) failToLoadVideoInfo:(TudouVideoInfo*) videoInfo URL:(NSString*) url
{
	[[ImageManager sharedImageManager] postURL2DownLoadImage:url Delegate:(id<URLImageDelegate>)videoInfo];
}

- (void) freeRequest:(TudouWeiRequest*) request
{
	[_freeConnection addObject:request];
	[_usingConnection removeObject:request];
	[request cancelRequest];
}

- (TudouWeiRequest*) getFreeRequest
{
	TudouWeiRequest* request = nil;
	int freeConnectionCount = [_freeConnection count];
	if (0 != freeConnectionCount)
	{
		request = [_freeConnection objectAtIndex:(freeConnectionCount - 1)];
		[_freeConnection removeObjectAtIndex:(freeConnectionCount - 1)];
	}
	else 
	{
		request = [[TudouWeiRequest alloc] init];
	}
	[_usingConnection addObject:request];
	return request;
}

#pragma mark - WebRequest Delegate Methods

- (void) OnReceiveData:(WebRequest*) request Data:(NSData*)data;

{
	TudouWeiRequest* tudouRequest = (TudouWeiRequest*)request;
	NSString* str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	SBJSON *jsonParser = [[SBJSON alloc]init];
	
	NSError* parseError = nil;
	NSDictionary* result = [jsonParser objectWithString:str error:&parseError];
	
	if (parseError)
    {
        NSLog(@"%@\t%s\t%d", str, __FILE__, __LINE__);
		return;
	}
	
	switch (tudouRequest->operation) 
	{
		case TUDOU_SDK_REQUEST_USER_PERSONAL_INFO:
		{
			NSDictionary* userInfo = [result objectForKey:@"userInfo"];
			TuDouUserPersonalInfo* personalInfo = [[TuDouUserPersonalInfo alloc] init];
			personalInfo.userNickName = [userInfo objectForKey:@"nickname"];
			NSString* userPicPath = [userInfo objectForKey:@"userpicurl"];
			[personalInfo setDelegate:tudouRequest.tudouSDKDeletage];
			[[ImageManager sharedImageManager] postURL2DownLoadImage:userPicPath Delegate:(id<URLImageDelegate>)personalInfo];
			[_personalInfoRequest addObject:personalInfo];
		}
		break;
		case TUDOU_SDK_REQUEST_USER_VIDEO_INFO:
		{
			NSDictionary* pageInfo = [[result objectForKey:@"multiPageResult"]  objectForKey:@"page"];
			
			NSDecimalNumber* pageNo= [pageInfo objectForKey:@"pageNo"];
			NSDecimalNumber* pageSize = [pageInfo objectForKey:@"pageSize"];
			NSDecimalNumber* pageCount = [pageInfo objectForKey:@"pageCount"];
			NSDecimalNumber* videoCount = [pageInfo objectForKey:@"totalCount"];
			[tudouRequest.tudouSDKDeletage OnReceiveUserVideoInfo:[pageNo doubleValue] 
			PageSize:[pageSize doubleValue] 
			PageCount:[pageCount doubleValue] 
			VideoCount:[videoCount doubleValue]];
			
			NSArray* videoInfos = [[result objectForKey:@"multiPageResult"] objectForKey:@"results"];
			for (NSDictionary* v in videoInfos) 
			{
				TudouVideoInfo* video = [[TudouVideoInfo alloc] init];	
				video.itemId = [v objectForKey:@"itemId"];
				video.itemCode = [v objectForKey:@"itemCode"];
				video.title = [v objectForKey:@"title"];
				video.tags = [v objectForKey:@"tags"];
				video.description = [v objectForKey:@"description"];
				video.itemUrl = [v objectForKey:@"itemUrl"];
				video.bigPicURL = [v objectForKey:@"bigPicUrl"];
				video.delegate = tudouRequest.tudouSDKDeletage;
				video.sdk = self;
				NSString* pictureURL = [v objectForKey:@"picUrl"];
				[[ImageManager sharedImageManager] postURL2DownLoadImage:pictureURL Delegate:(id<URLImageDelegate>)video];
				[[ImageManager sharedImageManager] postURL2DownLoadImage:video.bigPicURL Delegate:(id<URLImageDelegate>)video];
				[_videoRequest addObject:video];
			}
		}
		break;
	}
	[self freeRequest:tudouRequest];
}

- (void) OnReceiveError:(WebRequest*) request;
{
	TudouWeiRequest* tudouRequest = (TudouWeiRequest*)request;
	[self freeRequest:tudouRequest];
	[[tudouRequest tudouSDKDeletage] OnReceiveError:tudouRequest->operation];
}

@end
