


@protocol OauthDelegate<NSObject>
@required
- (void) OnOauthLoginSucessce;
- (void) OnOauthLoginFail;
- (void) OnAlreadyLogin;
@end

