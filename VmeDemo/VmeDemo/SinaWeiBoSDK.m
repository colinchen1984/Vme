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

typedef enum  
{
	SINA_WEIBO_REQUEST_USER_PERSONAL_INFO = 0,
	SINA_WEIBO_SEND_WEIBO = 1,
	
} SINA_WEIBO_REQUEST_OPERATION_TYPE;

@interface SinaWeiBoRequest : WebRequest
{
@public
	SINA_WEIBO_REQUEST_OPERATION_TYPE operation;
}
@property (weak, nonatomic) id weiBoSDKDelegate;
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

#pragma mark - WebRequest Delegate Methods

- (void) OnReceiveData:(WebRequest*) request Data:(NSData*)data;

{
	SinaWeiBoRequest* sinaRequest = (SinaWeiBoRequest*)request;
	NSString* str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	SBJSON *jsonParser = [[SBJSON alloc]init];
	
	NSError* parseError = nil;
	NSDictionary* result = [jsonParser objectWithString:str error:&parseError];
	
	if (parseError)
    {
		;
	}
	
	switch (sinaRequest->operation) 
	{
		case SINA_WEIBO_REQUEST_USER_PERSONAL_INFO:
		{
			NSDictionary* userInfo = [result objectForKey:@"userInfo"];
		}
		break;
		case SINA_WEIBO_SEND_WEIBO:
		{
			NSDictionary* userInfo = [result objectForKey:@"userInfo"];
		}
		break;
	}
	
	[self freeRequest:sinaRequest];
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
	{
		request = [_freeConnection objectAtIndex:(freeConnectionCount - 1)];
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
