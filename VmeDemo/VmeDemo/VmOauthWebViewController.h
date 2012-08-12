//
//  VmOauthWebViewController.h
//  VmeDemo
//
//  Created by user on 12-5-6.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
@class SinaWeiBoOauth;

@interface VmOauthWebViewController : UIViewController <UIWebViewDelegate>

- (void) loadUrl:(NSString*) url OauthEngine:(SinaWeiBoOauth*) engine;
@end
