//
//  VmeDemoAppDelegate.m
//  VmeDemo
//
//  Created by user on 12-4-29.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "VmeDemoAppDelegate.h"
#import "VmeDemoViewController.h"
#import "VmeStartUp.h"
#import "Oauth.h"
#import "TuDouOauth.h"
#import "TuDouSDK.h"
#import "SinaWeiBoOauth.h"
#import "SinaWeiBoSDK.h"

@class SinaWeiBoOauth;

@interface VmeDemoAppDelegate()
@property (strong, nonatomic) TuDouSDK* tudouSDK;
@property (strong, nonatomic) SinaWeiBoSDK* sinaWeiboSDK;
@property (strong, nonatomic) UINavigationController* navigationController;
@end

@implementation VmeDemoAppDelegate

@synthesize window = _window;
@synthesize viewController = _viewController;
@synthesize startUpController = _startUpController;
@synthesize tudouSDK = _tudouSDK;
@synthesize sinaWeiboSDK = _sinaWeiboSDK;
@synthesize navigationController = _navigationController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
	self.viewController = [[VmeDemoViewController alloc] initWithNibName:@"VmeDemoViewController" bundle:nil];
	
	self.startUpController = [[VmeStartUpController alloc] initWithNibName:@"VmeStartUp" bundle:nil];
	self.startUpController.startUpDelegate = self;
	self.window.rootViewController = _startUpController;
	
	_navigationController = [[UINavigationController alloc] initWithRootViewController:_viewController];
	_navigationController.navigationBar.tintColor = [UIColor colorWithRed:205.0f / 256.0f green:44.0f / 256.0f blue:36.0f / 256.0f alpha:1.0f];
	[self.window makeKeyAndVisible];

    return YES;
}



#pragma mark - OauthEngine delegate

- (void) OnSinaWeiBoLogin:(SinaWeiBoOauth*)sinaOauth
{
	_sinaWeiboSDK = [[SinaWeiBoSDK alloc] initWithSinaWeiBoOauth:sinaOauth];
}

- (void) OnSinaWeiBoLogInFail
{
	
}

- (void) OnTudouLogin:(NSString*)userName TuDouOauth:(OauthEngine*)tudouOuath;
{
	self.viewController.tudouUserName = userName;
	_tudouSDK = [[TuDouSDK alloc] initWithOauthEngine:tudouOuath UserName:userName];
	_viewController.tudouSDK = _tudouSDK;
	_viewController.sinaWeiBoSDK = _sinaWeiboSDK;
	self.window.rootViewController = _navigationController;
}

@end
