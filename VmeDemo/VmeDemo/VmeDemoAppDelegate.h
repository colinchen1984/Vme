//
//  VmeDemoAppDelegate.h
//  VmeDemo
//
//  Created by user on 12-4-29.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Oauth.h"

@class VmeDemoViewController;
@class VmeStartUpController;

@interface VmeDemoAppDelegate : UIResponder <UIApplicationDelegate, OauthDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) VmeDemoViewController *viewController;

@property (strong, nonatomic) VmeStartUpController* startUpController;
@end
