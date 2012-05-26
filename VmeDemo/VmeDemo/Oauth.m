#import "Oauth.h"
#import <CommonCrypto/CommonDigest.h>
#import "GTMBase64.h"
#import "VmOauthWebViewController.h"
#import "SFHFKeychainUtils.h"

#define SEVICE_NAME @"Service_Name"
#define ACCESS_TOKEN @"Access_Token"
#define ACCESS_TOKEN_SECRET @"Access_Token_Secret"

@interface OauthEngine ()
{
	OAUTHACCESSTATUS currentStatus;
}

@property (strong, nonatomic) NSString* timeStamp;
@property (strong, nonatomic) NSString* onceString;
@property (strong, nonatomic) id<OauthServiceProvider> provider;
@property (strong, nonatomic) id<OauthDelegate> delegate;
@property (strong, nonatomic) NSURLConnection* connection;
@property (strong, nonatomic) NSMutableData* responseData;
@property (strong, nonatomic) VmOauthWebViewController* webViewController;
@property (weak, nonatomic) id swapController;
@property (copy, nonatomic) NSString* accessToken;
@property (copy, nonatomic) NSString* accessTokenSecrect;
@end

@implementation OauthEngine

@synthesize timeStamp = _timeStamp;
@synthesize onceString = _onceString;
@synthesize provider = _provider;
@synthesize connection = _connection;
@synthesize responseData = _responseData;
@synthesize webViewController = _webViewController;
@synthesize swapController = _swapController;
@synthesize accessToken = _accessToken;
@synthesize accessTokenSecrect = _accessTokenSecrect;
@synthesize delegate = _delegate;

#pragma mark - OauthEngine life cycle
- (id) initWithProvider:(id<OauthServiceProvider>) provider Delegate:(id<OauthDelegate>)delegate;

{
	self = [super init];
	if(nil == self)
	{
		return nil;
	}
	_timeStamp = nil;
	_onceString = nil;
	_provider = provider;
	_delegate = delegate;
	_connection = nil;
	currentStatus = OAUTH_STATUS_REQUEST_TOKEN;
	_responseData = nil;
	_webViewController = [[VmOauthWebViewController alloc] initWithNibName:nil bundle:nil];
	_responseData = [[NSMutableData alloc] init];
	_accessToken = @"";
	_accessTokenSecrect = @"";
	return self;
}

#pragma mark - OauthEngine Get oauth request param
- (NSString*) oauthTimeStamp
{
	NSString* t = [[NSString alloc] initWithFormat:@"%d", time(NULL)];
	[self setTimeStamp:t];
	return [self timeStamp];
}

- (NSString*) oauthOnceString
{
	_onceString = [[NSString alloc] initWithFormat:@"x%@", [self oauthTimeStamp]];
    return [self onceString];
}

#pragma mark - OauthEngine interface for app sdk
- (BOOL) isLogining
{
	BOOL ret = 0 != [_accessToken length] && 0 != [_accessTokenSecrect length] ? YES : NO;
	return ret;
}

- (NSString*) oauthAppKey
{
	return [_provider OauthServiceProviderGetAppKey];
}

#pragma mark - OauthEngine action
- (void) oauthStart
{
	if (YES != [self isLogining]) 
	{
		[self loadAccessToken];
	}
	
	if (NO != [self isLogining]) 
	{
		[self requestToken];
	}
	else 
	{
		[_delegate OnAlreadyLogin];
	}
	
}

- (void) requestToken
{
	NSString* url = [_provider OauthServiceProviderGetRequestUrl:self Status:currentStatus];
	NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL URLWithString: url]
                                            cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                        timeoutInterval:60.0];
	_connection = [[NSURLConnection alloc] initWithRequest: request
											delegate: self
											startImmediately: YES];
}

- (void) authorize
{
	[self cancelConnection];
	NSString* url = [_provider OauthServiceProviderGetRequestUrl:self Status:currentStatus];
	//采用UIWebView进行授权
	__weak UIViewController* c = [UIApplication sharedApplication].delegate.window.rootViewController;
	[c presentModalViewController:_webViewController animated:NO];
	[_webViewController loadUrl:url OauthEngine:self];

}

- (void) getAccessToken
{
	[self cancelConnection];
	NSString* url = [_provider OauthServiceProviderGetRequestUrl:self Status:currentStatus];
	NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL URLWithString: url]
											 cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
										 timeoutInterval:60.0];
	_connection = [[NSURLConnection alloc] initWithRequest: request
												  delegate: self
										  startImmediately: YES];	
}

- (void) saveAccessToken
{
	NSString *serviceName = [_provider OauthServiceProviderGetServiceName];
    [SFHFKeychainUtils storeUsername:ACCESS_TOKEN andPassword:_accessToken forServiceName:serviceName updateExisting:YES error:nil];
	[SFHFKeychainUtils storeUsername:ACCESS_TOKEN_SECRET andPassword:_accessTokenSecrect forServiceName:serviceName updateExisting:YES error:nil];
}

- (void) loadAccessToken
{
	NSString *serviceName = [_provider OauthServiceProviderGetServiceName];
    _accessToken = [SFHFKeychainUtils getPasswordForUsername:ACCESS_TOKEN andServiceName:serviceName error:nil];
    _accessTokenSecrect = [SFHFKeychainUtils getPasswordForUsername:ACCESS_TOKEN_SECRET andServiceName:serviceName error:nil];
}

- (void) handleResponseData
{
	int ret = [_provider OauthServiceProviderHandleData:self Status:currentStatus Data:_responseData];
	if (0 != ret) 
	{
		return;
	}
	
	switch(currentStatus)
	{
		case OAUTH_STATUS_REQUEST_TOKEN:
		{
			currentStatus = OAUTH_STATUS_AUTHORIZE;
			[self authorize];
		}
		break;
		case OAUTH_STATUS_AUTHORIZE:
		{
			currentStatus = OAUTH_STATUS_ACCESS_TOKEN;
			[self getAccessToken];
		}
		break;
		case OAUTH_STATUS_ACCESS_TOKEN:
		{
			//保存access_token
			_accessToken = [_provider OauthServiceProviderGetAccessToken];
			_accessTokenSecrect = [_provider OauthServiceProviderGetAccessTokenSecret];
			[self saveAccessToken];
			[_delegate OnOauthLoginSucessce];
			
		}
		break;
	}
}

- (void) cancelConnection
{
    [_connection cancel];
	_connection = nil;
}

- (void) handleOauthWebViewData:(NSString*) data
{
	[_responseData setLength:0];
	[_responseData appendData:[data dataUsingEncoding:NSUTF8StringEncoding]];
	[self handleResponseData];
}

#pragma mark - NSURLConnection Delegate Methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
	[_responseData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
	[_responseData appendData:data];
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection
				  willCacheResponse:(NSCachedURLResponse*)cachedResponse 
{
	return nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)theConnection 
{
	[self handleResponseData];
    
	[self cancelConnection];

}

- (void)connection:(NSURLConnection *)theConnection didFailWithError:(NSError *)error
{
	//[self failedWithError:error];
	[self cancelConnection];
}


@end

