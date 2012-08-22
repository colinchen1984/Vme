

@protocol OauthDelegate;

@interface SinaWeiBoOauth : NSObject
- (id) init;
- (void) oauthStart;
- (BOOL) expires;
- (BOOL) isLogining;
- (void) loadAccessToken;
- (void) handleOauthWebViewData:(NSString*) data;
- (void) cleanAccessToken;
@property (weak, nonatomic) id<OauthDelegate> delegate;
@property (strong, nonatomic, readonly) NSString* userID;
@property (strong, nonatomic, readonly) NSString* accessCode;
@end