#import "Oauth.h"

@interface TuDouOauth : NSObject <OauthServiceProvider>
- (id) init;
- (NSString*) OauthServiceProviderGetServiceName;
- (NSString*) OauthServiceProviderGetAppKey;
- (NSString*) OauthServiceProviderGetRequestUrl:(OauthEngine*)engine Status:(OAUTHACCESSTATUS) status;
- (int) OauthServiceProviderHandleData:(OauthEngine*)engine Status:(OAUTHACCESSTATUS) status Data:(NSData*) data;
@end