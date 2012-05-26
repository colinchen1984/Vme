

#import <Foundation/Foundation.h>

typedef enum 
{
	OAUTH_STATUS_REQUEST_TOKEN = 0,
	OAUTH_STATUS_AUTHORIZE = 1,
	OAUTH_STATUS_ACCESS_TOKEN = 2,
} OAUTHACCESSTATUS;

@class OauthEngine;

@protocol OauthServiceProvider
@required
- (NSString*) OauthServiceProviderGetServiceName;
- (NSString*) OauthServiceProviderGetAppKey;
- (NSString*) OauthServiceProviderGetAccessToken;
- (NSString*) OauthServiceProviderGetAccessTokenSecret;
- (NSString*) OauthServiceProviderGetRequestUrl:(OauthEngine*)engine Status:(OAUTHACCESSTATUS) status;
- (int) OauthServiceProviderHandleData:(OauthEngine*)engine Status:(OAUTHACCESSTATUS) status Data:(NSData*) data;
@end

@protocol OauthDelegate
@required
- (void) OnOauthLoginSucessce;
- (void) OnOauthLoginFail;
- (void) OnAlreadyLogin;
@end

@interface OauthEngine : NSObject

//life cycle
-(id) initWithProvider:(id<OauthServiceProvider>)provider Delegate:(id<OauthDelegate>)delegate;

//interface for service provider
- (NSString*) oauthTimeStamp;
- (NSString*) oauthOnceString;

//interface for oauth web view controller
- (void) handleOauthWebViewData:(NSString*) data;

//oauth interface
- (void) oauthStart;

//interface for app sdk, such as tudou sdk, wei xin sdk
- (NSString*) oauthAppKey;
@end

