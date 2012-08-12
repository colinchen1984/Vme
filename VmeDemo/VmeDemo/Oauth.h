

#import <Foundation/Foundation.h>

@protocol OauthDelegate
@required
- (void) OnOauthLoginSucessce;
- (void) OnOauthLoginFail;
- (void) OnAlreadyLogin;
@end

