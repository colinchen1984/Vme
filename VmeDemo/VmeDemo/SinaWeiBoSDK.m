//
//  SinaWeiBoSDK.m
//  VmeDemo
//
//  Created by user on 12-5-24.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "SinaWeiBoSDK.h"
#import "WebRequest.h"
#import "SinaWeiBoOauth.h"
#import "SBJSON.h"
#import "SinaWeiBoSDK+HandleData.h"

typedef enum  
{
	SINA_WEIBO_REQUEST_USER_PERSONAL_INFO = 0,
	SINA_WEIBO_SEND_WEIBO = 1,
	SINA_WEIBO_GET_WEIBO_COMMENT = 2,
	SINA_WEIBO_GET_USER_ALL_WEIBO = 3,
	SINA_WEIBO_CREATE_COMMENT = 4,
	SINA_WEIBO_REPLY_COMMENT = 5,
	
	
} SINA_WEIBO_REQUEST_OPERATION_TYPE;

@interface SinaWeiBoRequest : WebRequest
{
@public
	SINA_WEIBO_REQUEST_OPERATION_TYPE operation;
}
@property (weak, nonatomic) id<SinaWeiBoSDKDelegate> weiBoSDKDelegate;
- (void) cancelRequest;
@end

@implementation SinaWeiBoRequest
@synthesize weiBoSDKDelegate = _weiBoSDKDelegate;
- (void) cancelRequest
{
	_weiBoSDKDelegate = nil;
	[super cancelRequest];
}
@end

@implementation SinaWeiBoUserPersonalInfo
@synthesize userID = _userID;
@synthesize userName = _userName;
@synthesize avatarImage = _avatarImage;
- (void) OnReceiveImage:(UIImage*)image
{
	_avatarImage = image;
}
@end

@implementation SinaWeiBoData
@synthesize annotation = _annotation;
@synthesize text = _text;
@synthesize weiBoID = _weiBoID;
@synthesize comments = _comments;
@synthesize userID = _userID;
@synthesize userInfo = _userInfo;
@end

@implementation SinaWeiBoComment
@synthesize text = _text;
@synthesize weiBoCommentID = _weiBoCommentID;
@synthesize userInfo = _userInfo;
@synthesize weiBoData = _weiBoData;
@end

@interface SinaWeiBoSDK()
@property (strong, nonatomic) NSMutableSet* usingConnection;
@property (strong, nonatomic) NSMutableArray* freeConnection;
@property (strong, nonatomic) SinaWeiBoOauth* sinaWeiBoOauth;
@property (strong, nonatomic) SinaWeiBoUserPersonalInfo* userPersonalInfo;
@end

@implementation SinaWeiBoSDK
@synthesize sinaWeiBoOauth = _sinaWeiBoOauth;
@synthesize usingConnection = _usingConnection;
@synthesize freeConnection = _freeConnection;
@synthesize userPersonalInfo = _userPersonalInfo;
#pragma mark - life cycle
- (id) initWithSinaWeiBoOauth:(SinaWeiBoOauth*)oauth
{
	self = [super init];
	if(nil == self)
	{
		return nil;
	}
	_sinaWeiBoOauth = oauth;
	_usingConnection = [[NSMutableSet alloc] init];
	_freeConnection = [[NSMutableArray alloc] init];
	return self;
}

#define VALID_OAUTH (YES == [_sinaWeiBoOauth isLogining] && NO == [_sinaWeiBoOauth expires])

#pragma mark - sdk interface

- (void) requireUserAllWeiBo:(BOOL)sendByThisApp Delegate:(id<SinaWeiBoSDKDelegate>)delegate
{
	if (YES != VALID_OAUTH) 
	{
		[delegate OnWeiBoOauthExpired]; 
		return;
	}
	
	NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
							[_sinaWeiBoOauth accessCode], @"access_token",
							[_sinaWeiBoOauth userID], @"uid", 
							@"200", @"count",
							YES == sendByThisApp ? @"1" : @"0", @"base_app",
							@"0", @"trim_user",
							nil];
	
	SinaWeiBoRequest* request = [self getFreeRequest];
	request.delegate = self;
	request.weiBoSDKDelegate = delegate;
	request.httpHeader = params;
	request->operation = SINA_WEIBO_GET_USER_ALL_WEIBO;
	[request postUrlRequest:@"https://api.weibo.com/2/statuses/user_timeline.json"];	
}

- (void) requireUserPersonalInfo:(id<SinaWeiBoSDKDelegate>)delegate
{
	if (YES != VALID_OAUTH) 
	{
		[delegate OnWeiBoOauthExpired]; 
		return;
	}

	NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
							[_sinaWeiBoOauth accessCode], @"access_token",
							[_sinaWeiBoOauth userID], @"uid", nil];
	
	SinaWeiBoRequest* request = [self getFreeRequest];
	request.delegate = self;
	request.weiBoSDKDelegate = delegate;
	request.httpHeader = params;
	request->operation = SINA_WEIBO_REQUEST_USER_PERSONAL_INFO;
	[request postUrlRequest:@"https://api.weibo.com/2/users/show.json"];
}

- (void) sendWeiBo:(NSString*) text Annotations:(NSString*)annotations Delegate:(id<SinaWeiBoSDKDelegate>)delegate
{
	if (YES != VALID_OAUTH) 
	{
		[delegate OnWeiBoOauthExpired]; 
		return;
	}
	
	if (nil == text) 
	{
		return;
	}
	NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
							[_sinaWeiBoOauth accessCode], @"access_token",
							text, @"status", 
							nil];
	if (nil != annotations) 
	{
		[params setObject:annotations forKey:@"annotations"];
	}
	SinaWeiBoRequest* request = [self getFreeRequest];
	request.delegate = self;
	request.weiBoSDKDelegate = delegate;
	request.httpBody = params;
	request.httpMethod = @"POST";
	request->operation = SINA_WEIBO_SEND_WEIBO;
	[request postUrlRequest:@"https://api.weibo.com/2/statuses/update.json"];
}

- (void) requireWeiBoComment:(SinaWeiBoData*)weiBoData Delegate:(id<SinaWeiBoSDKDelegate>)delegate
{
	if (YES != VALID_OAUTH) 
	{
		[delegate OnWeiBoOauthExpired]; 
		return;
	}
	if (nil == weiBoData) 
	{
		return;
	}
	NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
								   [_sinaWeiBoOauth accessCode], @"access_token",
								   weiBoData.weiBoID, @"id",
								   @"200", @"count", 
								   nil];	
	
	SinaWeiBoRequest* request = [self getFreeRequest];
	request.delegate = self;
	request.weiBoSDKDelegate = delegate;
	request.httpHeader = params;
	request->operation = SINA_WEIBO_GET_WEIBO_COMMENT;
	[request postUrlRequest:@"https://api.weibo.com/2/comments/show.json"];
	
}
- (void) createCommentForWeiBo:(SinaWeiBoData*)weibo CommentText:(NSString*)commentText Delegate:(id<SinaWeiBoSDKDelegate>)delegate
{
	if (YES != VALID_OAUTH) 
	{
		[delegate OnWeiBoOauthExpired]; 
		return;
	}
	if (nil == weibo) 
	{
		return;
	}
	NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
							[_sinaWeiBoOauth accessCode], @"access_token",
							weibo.weiBoID, @"id",
							commentText, @"comment",
							nil];		
	SinaWeiBoRequest* request = [self getFreeRequest];
	request.delegate = self;
	request.weiBoSDKDelegate = delegate;
	request.httpBody = params;
	request.httpMethod = @"POST";
	request->operation = SINA_WEIBO_CREATE_COMMENT;
	[request postUrlRequest:@"https://api.weibo.com/2/comments/create.json"];
	
}

- (void) replyComment:(SinaWeiBoComment*) weiBoComment CommentText:(NSString*)commentText Delegate:(id<SinaWeiBoSDKDelegate>)delegate
{
	if (YES != VALID_OAUTH) 
	{
		[delegate OnWeiBoOauthExpired]; 
		return;
	}
	if (nil == weiBoComment) 
	{
		return;
	}
	NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
							[_sinaWeiBoOauth accessCode], @"access_token",
							weiBoComment.weiBoData.weiBoID, @"id",
							weiBoComment.weiBoCommentID, @"cid", 
							commentText, @"comment",
							nil];	
	
	SinaWeiBoRequest* request = [self getFreeRequest];
	request.delegate = self;
	request.weiBoSDKDelegate = delegate;
	request.httpBody = params;
	request.httpMethod = @"POST";
	request->operation = SINA_WEIBO_REPLY_COMMENT;
	[request postUrlRequest:@"https://api.weibo.com/2/comments/reply.json"];
	
}

#pragma mark - WebRequest Delegate Methods

- (void) OnReceiveData:(WebRequest*) request Data:(NSData*)data;

{
	SinaWeiBoRequest* weiBoRequest = (SinaWeiBoRequest*)request;
	NSString* str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	if (NSNotFound != [str rangeOfString:@"error"].location) 
	{
		[self freeRequest:weiBoRequest];
		return;
	}
	SBJSON *jsonParser = [[SBJSON alloc]init];
	
	NSError* parseError = nil;
	NSDictionary* dataDic = [jsonParser objectWithString:str error:&parseError];
	
	if (parseError)
    {
		;
	}
	
	switch (weiBoRequest->operation) 
	{
		case SINA_WEIBO_REQUEST_USER_PERSONAL_INFO:
		{
			[self handlerUserPersonalInfo:dataDic Delegate:weiBoRequest.weiBoSDKDelegate];
		}
		break;
		case SINA_WEIBO_SEND_WEIBO:
		{
			[self handlerSendWeiBoData:dataDic Delegate:weiBoRequest.weiBoSDKDelegate];
		}
		break;
		case SINA_WEIBO_GET_WEIBO_COMMENT:
		{
			[self handlerGetWeiBoCommentsData:dataDic Delegate:weiBoRequest.weiBoSDKDelegate];
		}
		break;
		case SINA_WEIBO_GET_USER_ALL_WEIBO:
		{
			[self handlerGetUserAllWeiBoData:dataDic Delegate:weiBoRequest.weiBoSDKDelegate];
		}
		break;
		case SINA_WEIBO_CREATE_COMMENT:
		{
			[self handlerCreateWeiBoComent:dataDic Delegate:weiBoRequest.weiBoSDKDelegate];
		}
		break;
		case SINA_WEIBO_REPLY_COMMENT:
		{
			[self handlerReplyCommentData:dataDic Delegate:weiBoRequest.weiBoSDKDelegate];
		}
		break;
	}
	
	[self freeRequest:weiBoRequest];
}

- (void) OnReceiveError:(WebRequest*) request;
{
	SinaWeiBoRequest* sinaRequest = (SinaWeiBoRequest*)request;
	//[[sinaRequest weiBoSDKDelegate] OnReceiveError:sinaRequest->operation];
	[self freeRequest:sinaRequest];
}

#pragma mark - request pool interface
- (void) freeRequest:(SinaWeiBoRequest*) request
{
	[_freeConnection addObject:request];
	[_usingConnection removeObject:request];
	[request cancelRequest];
}

- (SinaWeiBoRequest*) getFreeRequest
{
	SinaWeiBoRequest* request = nil;
	int freeConnectionCount = [_freeConnection count];
	if (0 != freeConnectionCount)
	{		request = [_freeConnection objectAtIndex:(freeConnectionCount - 1)];
		[_freeConnection removeObjectAtIndex:(freeConnectionCount - 1)];
	}
	else 
	{
		request = [[SinaWeiBoRequest alloc] init];
	}
	[_usingConnection addObject:request];
	return request;
}
@end
