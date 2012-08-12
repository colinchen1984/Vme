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
#import "TuDouSDK.h"
#import "SinaWeiBoOauth.h"
#import "SinaWeiBoSDK.h"

@class SinaWeiBoOauth;

@interface VmeDemoAppDelegate()
@property (strong, nonatomic) UINavigationController* navigationController;
@property (strong, nonatomic) VmeStartUpController* startUpController;
@end

@implementation VmeDemoAppDelegate

@synthesize window = _window;
@synthesize startUpController = _startUpController;
@synthesize navigationController = _navigationController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
	
	self.startUpController = [[VmeStartUpController alloc] initWithNibName:@"VmeStartUp" bundle:nil];


	_navigationController = [[UINavigationController alloc] initWithRootViewController:_startUpController];
	_navigationController.navigationBar.tintColor = [UIColor colorWithRed:205.0f / 256.0f green:44.0f / 256.0f blue:36.0f / 256.0f alpha:1.0f];
	_navigationController.navigationBar.barStyle = UIBarStyleBlack;
    _navigationController.navigationBar.translucent = NO;
    [_navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
    [_navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsLandscapePhone];

    UILabel *label;
    label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, _navigationController.navigationBar.frame.size.width, _navigationController.navigationBar.frame.size.height)];
    label.backgroundColor = [UIColor colorWithRed:(165.0 / 256.0) green:(39.0 / 256.0) blue:(37.0 / 256.0) alpha:1.0f];
    [_navigationController.navigationBar addSubview:label];
    self.window.rootViewController = _navigationController;
	[self.window makeKeyAndVisible];

    return YES;
}

@end
