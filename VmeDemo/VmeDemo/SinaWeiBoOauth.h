#import "Oauth.h"

@protocol OauthDelegate;

@interface SinaWeiBoOauth : NSObject
- (id) init;
- (void) oauthStart;
- (BOOL) expires;
- (BOOL) isLogining;
- (void) loadAccessToken;
@property (weak, nonatomic) id<OauthDelegate> delegate;
@property (strong, nonatomic, readonly) NSString* userID;
@property (strong, nonatomic, readonly) NSString* accessCode;
@end