
#import "TuDouOauth.h"
#import <CommonCrypto/CommonHMAC.h>
#import "Utility.h"
#import "GTMBase64.h"
@interface TuDouOauth ()
@property (strong, nonatomic) NSString* serverName;
@property (strong, nonatomic) NSString* comsumerKey;
@property (strong, nonatomic) NSString* consumerSecrectKey;
@property (strong, nonatomic) NSString* requestTokenURL;
@property (strong, nonatomic) NSString* authorizeURL;
@property (strong, nonatomic) NSString* accessTokenURL;
@property (strong, nonatomic) NSString* token;
@property (strong, nonatomic) NSString* tokenSecrect;
@end 

@implementation TuDouOauth
@synthesize serverName = _serverName;
@synthesize comsumerKey = _comsumerKey;
@synthesize consumerSecrectKey = _consumerSecrectKey;
@synthesize requestTokenURL = _requestTokenURL;
@synthesize authorizeURL = _authorizeURL;
@synthesize accessTokenURL = _accessTokenURL;
@synthesize token = _token;
@synthesize tokenSecrect = _tokenSecrect;

#pragma mark - TuDouOauth life cycle
- (id) init
{
	self = [super init];
	if (nil == self)
	{
		return nil;
	}

	_serverName = @"TudouService";
	_comsumerKey = @"f3db9710183157f4";
	_consumerSecrectKey = @"83ba9687ec4f174279bb74ced70de0f2";
	_requestTokenURL = @"http://api.tudou.com/auth/request_token.oauth";
	_authorizeURL = @"http://api.tudou.com/auth/authorize.oauth";
	_accessTokenURL = @"http://api.tudou.com/auth/access_token.oauth";
	_token = nil;
	_tokenSecrect = nil;
	return self;
}

#pragma mark - implementation protocol

- (NSString*) OauthServiceProviderGetServiceName
{
	return  _serverName;
}

- (NSString*) OauthServiceProviderGetAppKey
{
	return _comsumerKey;
}

- (NSString*) OauthServiceProviderGetRequestUrl:(OauthEngine*)engine Status:(OAUTHACCESSTATUS) status
{
	NSString* ret = nil;
	switch(status)
	{
		case OAUTH_STATUS_REQUEST_TOKEN:
		{
			ret = [self requestTokenURLString:engine];
		}
		break;
		case OAUTH_STATUS_AUTHORIZE:
		{
			ret = [[NSString alloc] initWithFormat:@"%@?oauth_token=%@&oauth_callback=http://", _authorizeURL, _token];
		}
		break;
		case OAUTH_STATUS_ACCESS_TOKEN:
		{
			ret = [self requestAccessTokenURLString:engine];
		}
		break;
	}
	return ret;
}

- (int) OauthServiceProviderHandleData:(OauthEngine*)engine Status:(OAUTHACCESSTATUS) status Data:(NSData*) data
{
	switch(status)
	{
		case OAUTH_STATUS_REQUEST_TOKEN:
		{
			return [self handleRequireTokenData:data];
		}
		break;
		case OAUTH_STATUS_AUTHORIZE:
		{
			return [self handlerAthorizeData:data];
		}
		break;
		case OAUTH_STATUS_ACCESS_TOKEN:
		{
			return [self handlerAccesssTokenData:data];
		}
		break;
	}
	return 0;
}

- (NSString*) OauthServiceProviderGetAccessToken
{
	return _token;
}

- (NSString*) OauthServiceProviderGetAccessTokenSecret
{
	return _tokenSecrect;
}
#pragma mark - handling incoming data
- (int) handleRequireTokenData:(NSData*) data
{
	NSString* ret = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	NSRange findToken = [ret rangeOfString:@"oauth_token="];
	NSRange findTokenSecret = [ret rangeOfString:@"&oauth_token_secret="];
	if (NSNotFound == findToken.location || NSNotFound == findTokenSecret.location) 
	{
		return -1;
	}
	findToken.location =  findToken.length;
	findToken.length = findTokenSecret.location - findToken.location;
	_token = [ret substringWithRange:findToken];
	findTokenSecret.location = findTokenSecret.location + findTokenSecret.length;
	findTokenSecret.length = [ret length] - findTokenSecret.location;
	_tokenSecrect = [ret substringWithRange:findTokenSecret];
	return 0;
}

- (int) handlerAthorizeData:(NSData*)data
{
	NSString* ret = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	NSRange findLable = [ret rangeOfString:@"http://localhost/?oauth_token="];
	if (NSNotFound == findLable.location || 0 != findLable.location) 
	{
		return -1;
	}
	return 0;
}

- (int) handlerAccesssTokenData:(NSData*)data
{
	//目前测试结果发现在参数正确情况下
	//accesstoken返回的数据和从request token的数据一样
	//所以目前采用直接使用其数据处理方法
	return [self handleRequireTokenData:data];
}

#pragma mark - provide url string
- (NSString*) getBaseStringWithDic:(NSDictionary*) dic URL:(NSString*) url
{
	NSArray *sortedArray = [[dic allKeys] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
	NSMutableArray* params = [[NSMutableArray alloc] init];
	for(NSString* key in sortedArray)
	{
		NSString* value = [dic objectForKey:key];
     	NSString* param = [[NSString alloc] initWithFormat:@"%@=%@", key, value];
		[params addObject:param];
	}
	NSString *normalizedRequestParameters = [params componentsJoinedByString:@"&"];
	NSString *ret = [NSString stringWithFormat:@"%@&%@&%@",
					 @"GET",
					 [url URLEncodedString],
					 [normalizedRequestParameters URLEncodedString]];
	return ret;
}

- (NSString*) getSignature:(NSDictionary*) dic  Key:(NSString*)key URL:(NSString*) url
{
	NSString* baseString = [self getBaseStringWithDic:dic URL:url];
	NSData *secretData = [key dataUsingEncoding:NSUTF8StringEncoding];
    NSData *clearTextData = [baseString dataUsingEncoding:NSUTF8StringEncoding];
    unsigned char result[20] = {0};
	CCHmac(kCCHmacAlgSHA1, [secretData bytes], [secretData length], [clearTextData bytes], [clearTextData length], result);
    
    //Base64 Encoding

    NSData *theData = [GTMBase64 encodeBytes:result length:20];
    
    NSString *base64EncodedResult = [[NSString alloc] initWithData:theData encoding:NSUTF8StringEncoding];
    
    return [base64EncodedResult URLEncodedString];	
}

- (NSString*) requestTokenURLString:(OauthEngine*) engine
{
	NSString* onceString = [engine oauthOnceString];
	NSString* timeStamp = [engine oauthTimeStamp];
	NSMutableDictionary* dic = [[NSMutableDictionary alloc] init];
	[dic setObject:onceString forKey:@"oauth_nonce"];
	[dic setObject:timeStamp forKey:@"oauth_timestamp"];
	[dic setObject:_comsumerKey forKey:@"oauth_consumer_key"];
	[dic setObject:@"HMAC-SHA1" forKey:@"oauth_signature_method"];
	[dic setObject:@"1.0" forKey:@"oauth_version"];
	NSString* signature = [self getSignature:dic Key:[[NSString alloc] initWithFormat:@"%@&", _consumerSecrectKey] URL:_requestTokenURL];
	[dic setObject:signature forKey:@"oauth_signature"];

	NSArray *sortedArray = [[dic allKeys] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
	NSMutableArray* params = [[NSMutableArray alloc] init];
	for(NSString* key in sortedArray)
	{
		NSString* value = [dic objectForKey:key];
     	NSString* param = [[NSString alloc] initWithFormat:@"%@=%@", key, value];
		[params addObject:param];
	}
    NSString* urlpart = [params componentsJoinedByString:@"&"];
    NSString* ret = [[NSString alloc] initWithFormat:@"%@?%@", _requestTokenURL, urlpart];
	return ret;
}

- (NSString*) requestAccessTokenURLString:(OauthEngine*) engine
{
	NSString* onceString = [engine oauthOnceString];
	NSString* timeStamp = [engine oauthTimeStamp];
	NSMutableDictionary* dic = [[NSMutableDictionary alloc] init];
	[dic setObject:onceString forKey:@"oauth_nonce"];
	[dic setObject:timeStamp forKey:@"oauth_timestamp"];
	[dic setObject:_comsumerKey forKey:@"oauth_consumer_key"];
	[dic setObject:@"HMAC-SHA1" forKey:@"oauth_signature_method"];
	[dic setObject:@"1.0" forKey:@"oauth_version"];
	[dic setObject:_token forKey:@"oauth_token"];
	NSString* signature = [self getSignature:dic Key:[[NSString alloc] initWithFormat:@"%@&%@", _consumerSecrectKey, _tokenSecrect] URL:_accessTokenURL];
	[dic setObject:signature forKey:@"oauth_signature"];
	
	NSArray *sortedArray = [[dic allKeys] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
	NSMutableArray* params = [[NSMutableArray alloc] init];
	for(NSString* key in sortedArray)
	{
		NSString* value = [dic objectForKey:key];
     	NSString* param = [[NSString alloc] initWithFormat:@"%@=%@", key, value];
		[params addObject:param];
	}
    NSString* urlpart = [params componentsJoinedByString:@"&"];
    NSString* ret = [[NSString alloc] initWithFormat:@"%@?%@", _accessTokenURL, urlpart];
	return ret;
}

@end
