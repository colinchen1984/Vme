//
//  SinaWeiBoOauth.m
//  VmeDemo
//
//  Created by user on 12-5-23.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "SinaWeiBoOauth.h"
#import <CommonCrypto/CommonHMAC.h>
#import "GTMBase64.h"
#import "WebRequest.h"
#import "VmOauthWebViewController.h"
#import "SFHFKeychainUtils.h"
#import "JSON.h"
#import "Utility.h"


#define ACCESS_TOKEN @"Access_Token"
#define USER_ID @"USER_ID"
#define EXPIRES_ABSOLUTE_IME @"EXPIRES_ABSOLUTE_IME"
@interface SinaWeiBoOauth ()
{
	NSUInteger expiresAbsoluteTime;
}
@property (strong, nonatomic) NSString* serverName;
@property (strong, nonatomic) NSString* consumerKey;
@property (strong, nonatomic) NSString* consumerSecrectKey;
@property (strong, nonatomic) NSString* callBackUrl;
@property (strong, nonatomic) VmOauthWebViewController* webOauth;
@property (strong, nonatomic) WebRequest* webRequest;
@property (weak, nonatomic) id swapedController;
@end 

@implementation SinaWeiBoOauth
@synthesize serverName = _serviceName;
@synthesize consumerKey = _consumerKey;
@synthesize consumerSecrectKey = _consumerSecrectKey;
@synthesize webOauth = _webOauth;
@synthesize callBackUrl = _callBackUrl;
@synthesize delegate = _delegate;
@synthesize accessCode = _accessCode;
@synthesize webRequest = _webRequest;
@synthesize userID = _userID;
@synthesize swapedController = _swapedController;

#pragma mark - TuDouOauth life cycle
- (id) init
{
	self = [super init];
	if (nil == self)
	{
		return nil;
	}
	_serviceName = @"SinaWeiBoService";
	_consumerKey = @"3702859613";
	[self loadAccessToken];
	return self;
}

- (BOOL) expires
{
	if (YES != [self isLogining]) 
	{
		return YES;
	}
	
	if (-1 == self->expiresAbsoluteTime) 
	{
		return YES;
	}
	time_t current = time(NULL);
	if (current > self->expiresAbsoluteTime)
	{
		return YES;
	}
	return NO;
}

- (void) oauthStart
{
	if (NO == [self expires]) 
	{
		[_delegate OnAlreadyLogin];
		return;
	}
	else 
	{
		[self loadAccessToken];
	}
	
	if ([self isLogining] && NO == [self expires]) 
	{
		[_delegate OnAlreadyLogin];
		return;
	}
	
	_consumerSecrectKey = @"95881335a0dea9ab28afa9888071d9be";
	_webRequest = [[WebRequest alloc] init];
	_callBackUrl = @"http://";
	_webRequest.delegate = (id<WebRequestDelegate>)self;
	
	NSString* urlStr = [[NSString alloc] initWithFormat:@"https://api.weibo.com/oauth2/authorize?display=mobile&response_type=code&redirect_uri=%@&client_id=%@", [_callBackUrl URLEncodedString], _consumerKey];
	__weak UIViewController* c = [UIApplication sharedApplication].delegate.window.rootViewController;
	if (nil == _webOauth) 
	{
		_webOauth = [[VmOauthWebViewController alloc] init];
	}
	[c presentViewController:_webOauth animated:YES	completion:nil];
	[_webOauth loadUrl:urlStr OauthEngine:(OauthEngine*)self];
	
}

#pragma mark - private interface
- (BOOL) isLogining
{
	BOOL ret = (nil != _accessCode && 0 != [_accessCode length]) ? YES : NO;
	return ret;
}

- (void) getAccessToken
{	
	NSString* urlStr = @"https://api.weibo.com/oauth2/access_token";
	
	NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
							_consumerKey, @"client_id",
							_consumerSecrectKey, @"client_secret",
							@"authorization_code", @"grant_type",
							_callBackUrl, @"redirect_uri",
							_accessCode, @"code", nil];
	
	[_webRequest setHttpMethod:@"POST"];
	[_webRequest setHttpBody:params];
	[_webRequest postUrlRequest:urlStr]; 
}

#pragma mark - oauth web view delegate
- (void) handleOauthWebViewData:(NSString*) data
{
	
	NSRange fail2Access = [data rangeOfString:@"error=access_denied"];
	if (NSNotFound != fail2Access.location) 
	{
		[_delegate OnOauthLoginFail];
		
		__weak UIViewController* c = [UIApplication sharedApplication].delegate.window.rootViewController;
		[c dismissViewControllerAnimated:YES completion:nil];
		return;
	}
	
	NSRange accessCodeLocation = [ data rangeOfString:@"code="];
	if (NSNotFound != accessCodeLocation.location)
	{
		accessCodeLocation.location += accessCodeLocation.length;
		accessCodeLocation.length = [data length] - accessCodeLocation.location;
		_accessCode = [data substringWithRange:accessCodeLocation];
		[self getAccessToken];
		__weak UIViewController* c = [UIApplication sharedApplication].delegate.window.rootViewController;
		[c dismissViewControllerAnimated:YES completion:nil];
		return;
	}

}

#pragma mark - save and load access key
- (void) saveAccessToken
{
    [SFHFKeychainUtils storeUsername:ACCESS_TOKEN andPassword:_accessCode forServiceName:_serviceName updateExisting:YES error:nil];
	[SFHFKeychainUtils storeUsername:USER_ID andPassword:_userID forServiceName:_serviceName updateExisting:YES error:nil];
	NSString* expiresTime = [[NSString alloc] initWithFormat:@"%u", self->expiresAbsoluteTime];
	[SFHFKeychainUtils storeUsername:EXPIRES_ABSOLUTE_IME andPassword: expiresTime forServiceName:_serviceName updateExisting:YES error:nil];
	
}

- (void) loadAccessToken
{
    _accessCode = [SFHFKeychainUtils getPasswordForUsername:ACCESS_TOKEN andServiceName:_serviceName error:nil];
   _userID = [SFHFKeychainUtils getPasswordForUsername:USER_ID andServiceName:_serviceName error:nil];
    NSString* expiresTime = [SFHFKeychainUtils getPasswordForUsername:EXPIRES_ABSOLUTE_IME andServiceName:_serviceName error:nil];
	self->expiresAbsoluteTime = nil != expiresTime ? [expiresTime longLongValue] : -1;
}

#pragma mark - WebRequest Delegate Methods
- (void) OnReceiveData:(WebRequest*) request Data:(NSData*)data;
{	
	NSString* str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	if (NSNotFound != [str rangeOfString:@"error"].location) 
	{
		[_delegate OnOauthLoginFail];
		return;
	}
	
	SBJSON *jsonParser = [[SBJSON alloc]init];
	
	NSError* parseError = nil;
	NSDictionary* result = [jsonParser objectWithString:str error:&parseError];
	
	if (parseError)
    {
		;
	}
	_accessCode = [result objectForKey:@"access_token"];
	_userID = [result objectForKey:@"uid"];
	NSInteger seconds = [[result objectForKey:@"expires_in"] intValue];
	time_t current = time(NULL);
	self->expiresAbsoluteTime = current + seconds;
	[self saveAccessToken];
	[_delegate OnOauthLoginSucessce];
}

- (void) OnReceiveError:(WebRequest*) request;
{
	[_delegate OnOauthLoginFail];
}

@end
