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

@interface VmeDemoAppDelegate()
@property (strong, nonatomic) OauthEngine* tudouOauth;
@property (strong, nonatomic) TuDouSDK* tudouSDK;
@property (strong, nonatomic) SinaWeiBoOauth* sinaWeiBoOauth;
@property (strong, nonatomic) SinaWeiBoSDK* sinaWeiboSDK;
@property (strong, nonatomic) UINavigationController* navigationController;
@end

@implementation VmeDemoAppDelegate

@synthesize window = _window;
@synthesize viewController = _viewController;
@synthesize startUpController = _startUpController;
@synthesize tudouOauth = _tudouOauth;
@synthesize tudouSDK = _tudouSDK;
@synthesize sinaWeiBoOauth = _sinaWeiBoOauth;
@synthesize sinaWeiboSDK = _sinaWeiboSDK;
@synthesize navigationController = _navigationController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
	self.viewController = [[VmeDemoViewController alloc] initWithNibName:@"VmeDemoViewController" bundle:nil];
	
	self.startUpController = [[VmeStartUpController alloc] initWithNibName:@"VmeStartUp" bundle:nil];
	self.window.rootViewController = _startUpController;
	
	_tudouOauth = [[OauthEngine alloc] initWithProvider:[[TuDouOauth alloc] init] Delegate:self];
	_tudouSDK = [[TuDouSDK alloc] initWithOauthEngine:_tudouOauth UserName:@"_79592344"];
	self.viewController.tudouUserName = @"_79592344";
	
	_sinaWeiBoOauth = [[SinaWeiBoOauth alloc] init];
	_sinaWeiBoOauth.delegate = self;
	_sinaWeiboSDK = [[SinaWeiBoSDK alloc] initWithSinaWeiBoOauth:_sinaWeiBoOauth];
	
	[_startUpController setTudouOuath:_tudouOauth];
	[_startUpController setSinaOauth:_sinaWeiBoOauth];
	
	[_viewController setTudouSDK:_tudouSDK];
	[_viewController setSinaWeiBoSDK:_sinaWeiboSDK];
	
	_navigationController = [[UINavigationController alloc] initWithRootViewController:_viewController];
	
	[self.window makeKeyAndVisible];

    return YES;
}



#pragma mark - OauthEngine delegate

- (void) OnOauthLoginSucessce
{
	self.window.rootViewController = _navigationController;
}
- (void) OnOauthLoginFail
{
	
}
- (void) OnAlreadyLogin
{
	self.window.rootViewController = _navigationController;
}

@end
