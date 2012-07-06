//
//  VmeStartUp.h
//  VmeDemo
//
//  Created by user on 12-5-5.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
@class OauthEngine;
@class SinaWeiBoOauth;
@protocol StartUpDelegate
- (void) OnSinaWeiBoLogin:(SinaWeiBoOauth*)sinaOauth;
- (void) OnSinaWeiBoLogInFail;
- (void) OnTudouLogin:(NSString*)userName TuDouOauth:(OauthEngine*)tudouOuath;
@end;

@interface VmeStartUpController : UIViewController
@property (weak, nonatomic) id<StartUpDelegate> startUpDelegate;
@property (strong, nonatomic) IBOutlet UIView *startUpView;
@end
