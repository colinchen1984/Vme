//
//  VmeStartUp.m
//  VmeDemo
//
//  Created by user on 12-5-5.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "VmeStartUp.h"
#import "Oauth.h"
#import "SinaWeiBoOauth.h"
#import "TuDouOauth.h"
#import "SFHFKeychainUtils.h"
#import "VmeDemoViewController.h"

@interface VmeStartUpController()
@property (strong, nonatomic) OauthEngine* tudouOuath;
@property (strong, nonatomic) SinaWeiBoOauth* sinaOauth;
@property (strong, nonatomic) NSString* tudouUserName;
@property (weak, nonatomic) IBOutlet UITextField *inputTudouUserName;
@property (weak, nonatomic) IBOutlet UIButton *loginSina;
@property (strong, nonatomic) VmeDemoViewController *videoController;
@property (strong, nonatomic) TuDouSDK* tudouSDK;
@property (strong, nonatomic) SinaWeiBoSDK* sinaWeiboSDK;

@end

@implementation VmeStartUpController
@synthesize startUpView = _startUpView;
@synthesize tudouOuath = _tudouOauth;
@synthesize sinaOauth = _sinaOauth;
@synthesize tudouUserName = _tudouUserName;
@synthesize inputTudouUserName = _inputTudouUserName;
@synthesize loginSina = _loginSina;
@synthesize videoController = _videoController;
@synthesize tudouSDK = _tudouSDK;
@synthesize sinaWeiboSDK = _sinaWeiboSDK;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:@"VmeStartUpView" bundle:nil];
    if (nil == self) 
	{
        // Custom initialization
		return nil;
    }
	
	_tudouOauth = [[OauthEngine alloc] initWithProvider:[[TuDouOauth alloc] init] Delegate:self];
	_sinaOauth = [[SinaWeiBoOauth alloc] init];
	_sinaOauth.delegate = self;
	_videoController = [[VmeDemoViewController alloc] initWithNibName:@"VmeDemoViewController" bundle:nil];

    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	_inputTudouUserName.delegate = self;

	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
	_startUpView = nil;
	_loginSina = nil;
	_inputTudouUserName = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void) viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	self.navigationItem.title = @"Vme";
	[_sinaOauth loadAccessToken];
	
	[self loadTuDouUserName];
	
	if (NO != [_sinaOauth expires]) 
	{
		[self startLoginSina];
		return;
	}
	
	if(nil == _tudouUserName)
	{
		[self startloginTudou];
		return;
	}
	
}

- (void) viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	if (NO == [_sinaOauth expires] && nil != _tudouUserName) 
	{
		[self finishLogin];
		return;
	}
}

- (void) startLoginSina
{
	_inputTudouUserName.hidden = YES;
	_loginSina.hidden = NO;
}

- (void) startloginTudou
{
	_loginSina.hidden = YES;
	_inputTudouUserName.hidden = NO;	
}

- (void) finishLogin
{
	_sinaWeiboSDK = [[SinaWeiBoSDK alloc] initWithSinaWeiBoOauth:_sinaOauth];
	_videoController.tudouUserName = _tudouUserName;
	_tudouSDK = [[TuDouSDK alloc] initWithOauthEngine:_tudouOauth UserName:_tudouUserName];
	_videoController.tudouSDK = _tudouSDK;
	_videoController.sinaWeiBoSDK = _sinaWeiboSDK;
	self.navigationItem.title = nil;
	[self.navigationController pushViewController:_videoController animated:YES];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void) loadTuDouUserName
{
	return;
	_tudouUserName = [SFHFKeychainUtils getPasswordForUsername:@"TuDouUserName" andServiceName:@"TuDou" error:nil];	
}

- (void) saveTuDouUserName
{
	[SFHFKeychainUtils storeUsername:@"TuDouUserName" andPassword:_tudouUserName forServiceName:@"TuDou" updateExisting:YES error:nil];
}

- (IBAction)loginTudou:(id)sender 
{
	[_sinaOauth oauthStart];
}

- (void) OnOauthLoginSucessce
{
	if (_tudouUserName) 
	{
		[self finishLogin];
	}
	else
	{
		[self startloginTudou];
	}

}

- (void) OnOauthLoginFail
{

}

- (void) OnAlreadyLogin
{
	if (_tudouUserName) 
	{
		[self finishLogin];
	}
	else
	{
		[self startloginTudou];
	}
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	_tudouUserName = @"_79592344";
	[self saveTuDouUserName];
	[self finishLogin];
	return NO;
}
@end
